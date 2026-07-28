import 'dart:convert';
import 'dart:io' as io;

import 'package:smf_apple/src/models/apple_credentials.dart';
import 'package:smf_apple/src/models/signing_credentials.dart';
import 'package:smf_engine/smf_engine.dart';

final class AppleCredentialProvider {
  const AppleCredentialProvider({required this.environment});

  factory AppleCredentialProvider.system() => AppleCredentialProvider(environment: io.Platform.environment);

  final Map<String, String> environment;

  Future<AppleCredentials> appleCredentials() async {
    final privateKey = _decodeBase64(
      _required(
        'SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64',
        'app-store-connect-auth-key-base64',
      ),
      'App Store Connect auth key',
    );
    SmfError.check(
      privateKey.isNotEmpty,
      'App Store Connect auth key is empty.',
      'INVALID_CREDENTIAL',
    );
    return AppleCredentials(
      keyId: _required(
        'SMF_APP_STORE_CONNECT_KEY_ID',
        'app-store-connect-key-id',
      ),
      issuerId: _required(
        'SMF_APP_STORE_CONNECT_ISSUER_ID',
        'app-store-connect-issuer-id',
      ),
      privateKey: privateKey,
    );
  }

  Future<AppleSigningCredentials> signingCredentials() async {
    return AppleSigningCredentials(
      certificateBase64: _required(
        'SMF_IOS_CERTIFICATE_BASE64',
        'ios-certificate-base64',
      ),
      certificatePassword: _required(
        'SMF_IOS_CERTIFICATE_PASSWORD',
        'ios-certificate-password',
      ),
    );
  }

  String _required(String name, String option) {
    final value = _optional(name);
    if (value == null) {
      throw SmfError(
        'Missing required credential. Set --$option or $name.',
        'MISSING_CREDENTIAL',
      );
    }
    return value;
  }

  String? _optional(String name) {
    final value = environment[name]?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static String _decodeBase64(String value, String name) {
    try {
      final decoded = utf8.decode(base64Decode(value)).trim();
      SmfError.check(
        decoded.isNotEmpty,
        '$name decoded to an empty value.',
        'INVALID_CREDENTIAL',
      );
      return decoded;
    } on FormatException catch (error) {
      throw SmfError(
        '$name is not valid Base64-encoded UTF-8.',
        'INVALID_CREDENTIAL',
        cause: error,
      );
    }
  }
}
