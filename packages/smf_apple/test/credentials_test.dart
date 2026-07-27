import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_apple/smf_apple.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  group('credential environment', () {
    test(
      'loads preferred App Store Connect values from a private-key path',
      () async {
        final root = await Directory.systemTemp.createTemp('smf-credentials-');
        addTearDown(() => root.delete(recursive: true));
        final keyPath = p.join(root.path, 'AuthKey_TEST.p8');
        await File(keyPath).writeAsString('  private-key  \n');
        final credentials = await appleCredentialsFromEnvironment(
          <String, String>{
            'SMF_APP_STORE_CONNECT_KEY_ID': 'KEY123',
            'SMF_APP_STORE_CONNECT_ISSUER_ID': 'issuer',
            'SMF_APP_STORE_CONNECT_PRIVATE_KEY_PATH': keyPath,
          },
        );
        expect(credentials.keyId, 'KEY123');
        expect(credentials.issuerId, 'issuer');
        expect(credentials.privateKey, 'private-key');
      },
    );

    test('keeps legacy SMF variables compatible', () async {
      final credentials = await appleCredentialsFromEnvironment(
        <String, String>{
          'SMF_APP_STORE_CONNECT_KEY_ID': 'KEY123',
          'SMF_APP_STORE_CONNECT_ISSUER_ID': 'issuer',
          'SMF_APP_STORE_CONNECT_PRIVATE_KEY_BASE64': base64Encode(
            utf8.encode('private-key'),
          ),
        },
      );
      expect(credentials.privateKey, 'private-key');
    });

    test(
      'loads binary signing assets from files without decoding them',
      () async {
        final root = await Directory.systemTemp.createTemp('smf-credentials-');
        addTearDown(() => root.delete(recursive: true));
        final certificate = p.join(root.path, 'distribution.p12');
        final profile = p.join(root.path, 'profile.mobileprovision');
        await File(certificate).writeAsBytes(const <int>[0, 1, 2, 255]);
        await File(profile).writeAsBytes(const <int>[3, 4, 5, 254]);
        final credentials = await signingCredentialsFromEnvironment(
          <String, String>{
            'SMF_IOS_CERTIFICATE_PATH': certificate,
            'SMF_IOS_CERTIFICATE_PASSWORD': 'password',
            'SMF_IOS_PROVISIONING_PROFILES_PATH': profile,
          },
        );
        expect(base64Decode(credentials.certificateBase64), <int>[
          0,
          1,
          2,
          255,
        ]);
        expect(base64Decode(credentials.provisioningProfiles), <int>[
          3,
          4,
          5,
          254,
        ]);
      },
    );

    test('rejects ambiguous credential sources', () async {
      await expectLater(
        appleCredentialsFromEnvironment(<String, String>{
          'SMF_APP_STORE_CONNECT_KEY_ID': 'KEY123',
          'SMF_APP_STORE_CONNECT_ISSUER_ID': 'issuer',
          'SMF_APP_STORE_CONNECT_PRIVATE_KEY_BASE64': base64Encode(
            utf8.encode('private-key'),
          ),
          'SMF_APP_STORE_CONNECT_PRIVATE_KEY_PATH': '/tmp/key.p8',
        }),
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
