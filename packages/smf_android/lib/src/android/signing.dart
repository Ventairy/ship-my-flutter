import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_android/src/models/android_signing_credentials.dart';
import 'package:smf_engine/smf_engine.dart';

/// Temporary Android upload-key installation used for one candidate build.
final class AndroidSigningSession {
  AndroidSigningSession._({
    required this.directory,
    required this.keystorePath,
  });

  /// Private temporary directory containing generated signing inputs.
  final Directory directory;

  /// Temporary upload-keystore path.
  final String keystorePath;

  /// Installs upload-key material without changing the consumer repository.
  static Future<AndroidSigningSession> install(
    AndroidSigningCredentials credentials, {
    ProcessRunner processRunner = const SystemProcessRunner(),
  }) async {
    final directory = await Directory.systemTemp.createTemp(
      'smf-android-sign-',
    );
    final keystorePath = p.join(directory.path, 'upload-keystore');
    try {
      List<int> keystore;
      try {
        keystore = base64Decode(credentials.keystoreBase64);
      } on FormatException catch (error) {
        throw SmfError(
          'Android upload keystore is not valid Base64.',
          'INVALID_CREDENTIAL',
          cause: error,
        );
      }
      SmfError.check(
        keystore.isNotEmpty,
        'Android upload keystore decoded to an empty file.',
        'INVALID_CREDENTIAL',
      );
      await File(keystorePath).writeAsBytes(keystore, flush: true);
      await processRunner.run('/bin/chmod', <String>[
        '700',
        directory.path,
      ]);
      await processRunner.run('/bin/chmod', <String>[
        '600',
        keystorePath,
      ]);
      return AndroidSigningSession._(
        directory: directory,
        keystorePath: keystorePath,
      );
    } on Object {
      await directory.delete(recursive: true);
      rethrow;
    }
  }

  /// Removes every signing file created by SMF.
  Future<void> cleanup() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}
