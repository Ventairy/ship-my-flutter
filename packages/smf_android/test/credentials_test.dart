import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_android/smf_android.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('loads Google Play and Android secrets from Base64 values', () async {
    final serviceAccount = jsonEncode(<String, Object?>{
      'type': 'service_account',
      'client_email': 'smf@example.invalid',
      'private_key': 'secret',
    });
    final provider = AndroidCredentialProvider(
      environment: <String, String>{
        'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64': base64Encode(
          utf8.encode(serviceAccount),
        ),
        'SMF_ANDROID_KEYSTORE_BASE64': base64Encode(<int>[1, 2, 3]),
        'SMF_ANDROID_KEY_ALIAS': 'upload',
        'SMF_ANDROID_KEYSTORE_PASSWORD': 'store-secret',
        'SMF_ANDROID_KEY_PASSWORD': 'key-secret',
      },
    );

    final google = await provider.googlePlayCredentials();
    final signing = await provider.signingCredentials();

    expect(
      jsonDecode(google.serviceAccountJson),
      containsPair('type', 'service_account'),
    );
    expect(base64Decode(signing.keystoreBase64), <int>[1, 2, 3]);
    expect(signing.keyAlias, 'upload');
    expect(signing.toString(), isNot(contains('store-secret')));
    expect(google.toString(), isNot(contains('secret')));
  });

  test('loads credential files and rejects conflicting sources', () async {
    final root = await Directory.systemTemp.createTemp('smf-android-creds-');
    addTearDown(() => root.delete(recursive: true));
    final serviceAccountPath = p.join(root.path, 'service-account.json');
    final keystorePath = p.join(root.path, 'upload.jks');
    await File(serviceAccountPath).writeAsString(
      '{"type":"service_account"}',
    );
    await File(keystorePath).writeAsBytes(<int>[4, 5, 6]);

    final provider = AndroidCredentialProvider(
      environment: <String, String>{
        'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH': serviceAccountPath,
        'SMF_ANDROID_KEYSTORE_PATH': keystorePath,
        'SMF_ANDROID_KEY_ALIAS': 'upload',
        'SMF_ANDROID_KEYSTORE_PASSWORD': 'store',
        'SMF_ANDROID_KEY_PASSWORD': 'key',
      },
    );
    expect(
      jsonDecode((await provider.googlePlayCredentials()).serviceAccountJson),
      containsPair('type', 'service_account'),
    );
    expect(
      base64Decode((await provider.signingCredentials()).keystoreBase64),
      <int>[4, 5, 6],
    );

    await expectLater(
      AndroidCredentialProvider(
        environment: <String, String>{
          'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH': serviceAccountPath,
          'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64': base64Encode(
            utf8.encode('{"type":"service_account"}'),
          ),
        },
      ).googlePlayCredentials(),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'CONFLICTING_CREDENTIAL',
        ),
      ),
    );
  });

  test('rejects malformed or non-service-account Google credentials', () async {
    for (final source in <String>[
      'not-json',
      '{"type":"authorized_user"}',
    ]) {
      await expectLater(
        AndroidCredentialProvider(
          environment: <String, String>{
            'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64': base64Encode(
              utf8.encode(source),
            ),
          },
        ).googlePlayCredentials(),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'INVALID_CREDENTIAL',
          ),
        ),
      );
    }
  });
}
