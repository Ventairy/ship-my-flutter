import 'dart:convert';

import 'package:smf_android/smf_android.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('loads pasted Google Play JSON and Base64 Android secrets', () async {
    const serviceAccount = '''
{
  "type": "service_account",
  "client_id": "1234567890",
  "client_email": "smf@example.invalid",
  "private_key": "secret"
}
''';
    final provider = AndroidCredentialProvider(
      environment: <String, String>{
        'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON': serviceAccount,
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

  test('missing credentials name the CLI and environment options', () async {
    await expectLater(
      const AndroidCredentialProvider(
        environment: <String, String>{},
      ).googlePlayCredentials(),
      throwsA(
        isA<SmfError>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('--google-play-service-account-json'),
            contains('SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON'),
          ),
        ),
      ),
    );
  });

  test('rejects malformed or non-service-account Google credentials', () async {
    for (final source in <String>[
      'not-json',
      '[]',
      '{"type":"authorized_user"}',
      '{"type":"service_account"}',
    ]) {
      await expectLater(
        AndroidCredentialProvider(
          environment: <String, String>{
            'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON': source,
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
