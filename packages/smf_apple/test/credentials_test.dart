import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_apple/smf_apple.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  group('credential environment', () {
    test(
      'loads App Store Connect values from an auth-key path',
      () async {
        final root = await Directory.systemTemp.createTemp('smf-credentials-');
        addTearDown(() => root.delete(recursive: true));
        final keyPath = p.join(root.path, 'AuthKey_TEST.p8');
        await File(keyPath).writeAsString('  private-key  \n');
        final credentials = await AppleCredentialProvider(
          environment: <String, String>{
            'SMF_APP_STORE_CONNECT_KEY_ID': 'KEY123',
            'SMF_APP_STORE_CONNECT_ISSUER_ID': 'issuer',
            'SMF_APP_STORE_CONNECT_AUTH_KEY_PATH': keyPath,
          },
        ).appleCredentials();
        expect(credentials.keyId, 'KEY123');
        expect(credentials.issuerId, 'issuer');
        expect(credentials.privateKey, 'private-key');
      },
    );

    test('loads an encoded App Store Connect auth key', () async {
      final credentials = await AppleCredentialProvider(
        environment: <String, String>{
          'SMF_APP_STORE_CONNECT_KEY_ID': 'KEY123',
          'SMF_APP_STORE_CONNECT_ISSUER_ID': 'issuer',
          'SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64': base64Encode(
            utf8.encode('private-key'),
          ),
        },
      ).appleCredentials();
      expect(credentials.privateKey, 'private-key');
    });

    test('loads the binary signing certificate without decoding it', () async {
      final root = await Directory.systemTemp.createTemp('smf-credentials-');
      addTearDown(() => root.delete(recursive: true));
      final certificate = p.join(root.path, 'distribution.p12');
      await File(certificate).writeAsBytes(const <int>[0, 1, 2, 255]);
      final credentials = await AppleCredentialProvider(
        environment: <String, String>{
          'SMF_IOS_CERTIFICATE_PATH': certificate,
          'SMF_IOS_CERTIFICATE_PASSWORD': 'password',
        },
      ).signingCredentials();
      expect(base64Decode(credentials.certificateBase64), <int>[
        0,
        1,
        2,
        255,
      ]);
    });

    test('rejects ambiguous credential sources', () async {
      await expectLater(
        AppleCredentialProvider(
          environment: <String, String>{
            'SMF_APP_STORE_CONNECT_KEY_ID': 'KEY123',
            'SMF_APP_STORE_CONNECT_ISSUER_ID': 'issuer',
            'SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64': base64Encode(
              utf8.encode('private-key'),
            ),
            'SMF_APP_STORE_CONNECT_AUTH_KEY_PATH': '/tmp/key.p8',
          },
        ).appleCredentials(),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'CONFLICTING_CREDENTIAL',
          ),
        ),
      );
    });
  });
}
