import 'dart:convert';
import 'dart:io' as io;

import 'package:smf_android/src/models/android_signing_credentials.dart';
import 'package:smf_android/src/models/google_play_credentials.dart';
import 'package:smf_engine/smf_engine.dart';

/// Loads Google Play and Android signing credentials from environment values.
final class AndroidCredentialProvider {
  /// Creates a credential provider over [environment].
  const AndroidCredentialProvider({required this.environment});

  /// Creates a provider using the current process environment.
  factory AndroidCredentialProvider.system() =>
      AndroidCredentialProvider(environment: io.Platform.environment);

  /// Environment containing secret values or file paths.
  final Map<String, String> environment;

  /// Loads one service-account JSON source.
  Future<GooglePlayCredentials> googlePlayCredentials() async {
    final encoded = _optional('SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64');
    final path = _optional('SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH');
    if (encoded != null && path != null) {
      throw const SmfError(
        'Set only one Google Play service-account JSON source.',
        'CONFLICTING_CREDENTIAL',
      );
    }
    final value = path == null
        ? _decodeBase64(
            encoded ?? _required('SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64'),
            'Google Play service-account JSON',
          )
        : (await io.File(path).readAsString()).trim();
    try {
      final json = jsonDecode(value);
      invariant(
        json is Map<Object?, Object?> && json['type'] == 'service_account',
        'Google Play credentials must be a service-account JSON document.',
        'INVALID_CREDENTIAL',
      );
    } on FormatException catch (error) {
      throw SmfError(
        'Google Play service-account JSON is malformed.',
        'INVALID_CREDENTIAL',
        cause: error,
      );
    }
    return GooglePlayCredentials(serviceAccountJson: value);
  }

  /// Loads one upload-keystore source and its passwords.
  Future<AndroidSigningCredentials> signingCredentials() async {
    final encoded = _optional('SMF_ANDROID_KEYSTORE_BASE64');
    final path = _optional('SMF_ANDROID_KEYSTORE_PATH');
    if (encoded != null && path != null) {
      throw const SmfError(
        'Set only one Android upload-keystore source.',
        'CONFLICTING_CREDENTIAL',
      );
    }
    final keystoreBase64 = path == null
        ? encoded ?? _required('SMF_ANDROID_KEYSTORE_BASE64')
        : base64Encode(await io.File(path).readAsBytes());
    try {
      invariant(
        base64Decode(keystoreBase64).isNotEmpty,
        'Android upload keystore decoded to an empty file.',
        'INVALID_CREDENTIAL',
      );
    } on FormatException catch (error) {
      throw SmfError(
        'Android upload keystore is not valid Base64.',
        'INVALID_CREDENTIAL',
        cause: error,
      );
    }
    return AndroidSigningCredentials(
      keystoreBase64: keystoreBase64,
      keyAlias: _required('SMF_ANDROID_KEY_ALIAS'),
      keystorePassword: _required('SMF_ANDROID_KEYSTORE_PASSWORD'),
      keyPassword: _required('SMF_ANDROID_KEY_PASSWORD'),
    );
  }

  String _required(String name) {
    final value = _optional(name);
    if (value == null) {
      throw SmfError(
        'Missing required secret $name.',
        'MISSING_CREDENTIAL',
      );
    }
    return value;
  }

  String? _optional(String name) {
    final value = environment[name]?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}

/// Loads Google Play credentials from [environment].
Future<GooglePlayCredentials> googlePlayCredentialsFromEnvironment([
  Map<String, String>? environment,
]) => AndroidCredentialProvider(
  environment: environment ?? io.Platform.environment,
).googlePlayCredentials();

/// Loads Android upload-key credentials from [environment].
Future<AndroidSigningCredentials> androidSigningCredentialsFromEnvironment([
  Map<String, String>? environment,
]) => AndroidCredentialProvider(
  environment: environment ?? io.Platform.environment,
).signingCredentials();

String _decodeBase64(String value, String label) {
  try {
    final decoded = utf8.decode(base64Decode(value)).trim();
    invariant(
      decoded.isNotEmpty,
      '$label decoded to an empty value.',
      'INVALID_CREDENTIAL',
    );
    return decoded;
  } on FormatException catch (error) {
    throw SmfError(
      '$label is not valid Base64-encoded UTF-8.',
      'INVALID_CREDENTIAL',
      cause: error,
    );
  }
}
