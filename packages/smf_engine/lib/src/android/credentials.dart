import 'dart:convert';
import 'dart:io' as io;

import 'package:smf_engine/smf_engine.dart';
import 'package:smf_engine/src/android/models/android_signing_credentials.dart';
import 'package:smf_engine/src/android/models/google_play_credentials.dart';

/// Loads Google Play and Android signing credentials from environment values.
final class AndroidCredentialProvider {
  /// Creates a credential provider over [environment].
  const AndroidCredentialProvider({required this.environment});

  /// Creates a provider using the current process environment.
  factory AndroidCredentialProvider.system() => AndroidCredentialProvider(environment: io.Platform.environment);

  /// Environment containing credential values.
  final Map<String, String> environment;

  /// Loads the service-account JSON.
  Future<GooglePlayCredentials> googlePlayCredentials() async {
    final value = _required(
      'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON',
      'google-play-service-account-json',
    );
    try {
      final json = jsonDecode(value);
      SmfError.check(
        json is Map<Object?, Object?> &&
            json['type'] == 'service_account' &&
            _isNonEmptyString(json['client_id']) &&
            _isNonEmptyString(json['client_email']) &&
            _isNonEmptyString(json['private_key']),
        'Google Play credentials must be a complete service-account JSON '
        'document.',
        SmfErrorCode.invalidCredential,
      );
    } on FormatException catch (error) {
      throw SmfError(
        'Google Play service-account JSON is malformed.',
        SmfErrorCode.invalidCredential,
        cause: error,
      );
    }
    return GooglePlayCredentials(serviceAccountJson: value);
  }

  /// Loads one upload-keystore source and its passwords.
  Future<AndroidSigningCredentials> signingCredentials() async {
    final keystoreBase64 = _required(
      'SMF_ANDROID_KEYSTORE_BASE64',
      'android-keystore-base64',
    );
    try {
      SmfError.check(
        base64Decode(keystoreBase64).isNotEmpty,
        'Android upload keystore decoded to an empty file.',
        SmfErrorCode.invalidCredential,
      );
    } on FormatException catch (error) {
      throw SmfError(
        'Android upload keystore is not valid Base64.',
        SmfErrorCode.invalidCredential,
        cause: error,
      );
    }
    return AndroidSigningCredentials(
      keystoreBase64: keystoreBase64,
      keyAlias: _required('SMF_ANDROID_KEY_ALIAS', 'android-key-alias'),
      keystorePassword: _required(
        'SMF_ANDROID_KEYSTORE_PASSWORD',
        'android-keystore-password',
      ),
      keyPassword: _required(
        'SMF_ANDROID_KEY_PASSWORD',
        'android-key-password',
      ),
    );
  }

  String _required(String name, String option) {
    final value = _optional(name);
    if (value == null) {
      throw SmfError(
        'Missing required credential. Set --$option or $name.',
        SmfErrorCode.missingCredential,
      );
    }
    return value;
  }

  String? _optional(String name) {
    final value = environment[name]?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static bool _isNonEmptyString(Object? value) {
    return value is String && value.trim().isNotEmpty;
  }
}
