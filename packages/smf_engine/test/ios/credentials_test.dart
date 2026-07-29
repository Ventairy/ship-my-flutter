import 'dart:convert';

import 'package:smf_engine/apple.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  group('credential environment', () {
    test('loads encoded App Store Connect and signing values', () async {
      final provider = AppleCredentialProvider(
        environment: <String, String>{
          'SMF_APP_STORE_CONNECT_KEY_ID': 'KEY123',
          'SMF_APP_STORE_CONNECT_ISSUER_ID': 'issuer',
          'SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64': base64Encode(
            utf8.encode('private-key'),
          ),
          'SMF_IOS_CERTIFICATE_BASE64': base64Encode(
            const <int>[0, 1, 2, 255],
          ),
          'SMF_IOS_CERTIFICATE_PASSWORD': 'password',
        },
      );

      final api = await provider.appleCredentials();
      final signing = await provider.signingCredentials();

      expect(api.keyId, 'KEY123');
      expect(api.issuerId, 'issuer');
      expect(api.privateKey, 'private-key');
      expect(base64Decode(signing.certificateBase64), <int>[0, 1, 2, 255]);
    });

    test('missing credentials name the CLI and environment options', () async {
      await expectLater(
        const AppleCredentialProvider(
          environment: <String, String>{},
        ).appleCredentials(),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('--app-store-connect-auth-key-base64'),
              contains('SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64'),
            ),
          ),
        ),
      );
    });
  });
}
