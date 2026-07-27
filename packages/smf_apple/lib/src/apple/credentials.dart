import 'dart:convert';
import 'dart:io' as io;

import 'package:smf_apple/src/models/apple_credentials.dart';
import 'package:smf_apple/src/models/signing_credentials.dart';
import 'package:smf_engine/smf_engine.dart';

final class CredentialProvider {
  const CredentialProvider({required this.environment});

  factory CredentialProvider.system() =>
      CredentialProvider(environment: io.Platform.environment);

  final Map<String, String> environment;

  Future<AppleCredentials> appleCredentials() async {
    final privateKeyBase64 = _optional(const <String>[
      'SMF_APP_STORE_CONNECT_PRIVATE_KEY_BASE64',
    ]);
    final privateKeyPath = _optional(const <String>[
      'SMF_APP_STORE_CONNECT_PRIVATE_KEY_PATH',
    ]);
    if (privateKeyBase64 != null && privateKeyPath != null) {
      throw const SmfError(
        'Set only one App Store Connect private-key source.',
        'CONFLICTING_CREDENTIAL',
      );
    }
    final privateKey = privateKeyPath == null
        ? _decodeBase64(
            privateKeyBase64 ??
                _required(const <String>[
                  'SMF_APP_STORE_CONNECT_PRIVATE_KEY_BASE64',
                ]),
            'App Store Connect private key',
          )
        : (await io.File(privateKeyPath).readAsString()).trim();
    invariant(
      privateKey.isNotEmpty,
      'App Store Connect private key is empty.',
      'INVALID_CREDENTIAL',
    );
    return AppleCredentials(
      keyId: _required(const <String>['SMF_APP_STORE_CONNECT_KEY_ID']),
      issuerId: _required(const <String>['SMF_APP_STORE_CONNECT_ISSUER_ID']),
      privateKey: privateKey,
    );
  }

  Future<SigningCredentials> signingCredentials() async {
    final certificateBase64 = await _base64Value(
      base64Names: const <String>['SMF_IOS_CERTIFICATE_BASE64'],
      pathNames: const <String>['SMF_IOS_CERTIFICATE_PATH'],
      label: 'iOS distribution certificate',
    );
    final provisioningProfiles = await _base64Value(
      base64Names: const <String>['SMF_IOS_PROVISIONING_PROFILES_BASE64'],
      pathNames: const <String>['SMF_IOS_PROVISIONING_PROFILES_PATH'],
      label: 'iOS provisioning profiles',
    );
    return SigningCredentials(
      certificateBase64: certificateBase64,
      certificatePassword: _required(const <String>[
        'SMF_IOS_CERTIFICATE_PASSWORD',
      ]),
      provisioningProfiles: provisioningProfiles,
    );
  }

  Future<String> _base64Value({
    required List<String> base64Names,
    required List<String> pathNames,
    required String label,
  }) async {
    final encoded = _optional(base64Names);
    final path = _optional(pathNames);
    if (encoded != null && path != null) {
      throw SmfError('Set only one $label source.', 'CONFLICTING_CREDENTIAL');
    }
    if (path != null) {
      return base64Encode(await io.File(path).readAsBytes());
    }
    return encoded ?? _required(base64Names);
  }

  String _required(List<String> names) {
    final value = _optional(names);
    if (value == null) {
      throw SmfError(
        'Missing required secret ${names.first}.',
        'MISSING_CREDENTIAL',
      );
    }
    return value;
  }

  String? _optional(List<String> names) {
    for (final name in names) {
      final value = environment[name]?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }
}

Future<AppleCredentials> appleCredentialsFromEnvironment([
  Map<String, String>? environment,
]) => CredentialProvider(
  environment: environment ?? io.Platform.environment,
).appleCredentials();

Future<SigningCredentials> signingCredentialsFromEnvironment([
  Map<String, String>? environment,
]) => CredentialProvider(
  environment: environment ?? io.Platform.environment,
).signingCredentials();

String _decodeBase64(String value, String name) {
  try {
    final decoded = utf8.decode(base64Decode(value)).trim();
    invariant(
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
