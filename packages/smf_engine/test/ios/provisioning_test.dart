import 'dart:convert';
import 'dart:io';

import 'package:smf_engine/apple.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

import 'support/fake_app_store.dart';
import 'support/recording_process.dart';

AppleSigningCertificateDto certificate({
  bool isActivated = true,
  DateTime? expirationDate,
}) => AppleSigningCertificateDto(
  id: 'certificate-1',
  certificateType: 'DISTRIBUTION',
  displayName: 'Apple Distribution: Example',
  serialNumber: '00112233AABBCCDD',
  certificateContent: base64Encode(const <int>[1, 2, 3]),
  expirationDate: expirationDate ?? DateTime.utc(2027, 7, 27),
  isActivated: isActivated,
);

AppleBundleIdentifierDto bundle(String id, String identifier) =>
    AppleBundleIdentifierDto(id: id, identifier: identifier, platform: 'IOS');

AppleProvisioningProfileDto profile({
  required String id,
  required String bundleIdId,
  String certificateId = 'certificate-1',
  String? name,
  String content = 'BAUG',
  String state = 'ACTIVE',
  DateTime? createdDate,
  DateTime? expirationDate,
}) => AppleProvisioningProfileDto(
  id: id,
  name: name ?? 'Profile $id',
  profileType: 'IOS_APP_STORE',
  profileState: state,
  profileContent: content,
  uuid: 'UUID-$id',
  createdDate: createdDate ?? DateTime.utc(2026, 7, 27),
  expirationDate: expirationDate ?? DateTime.utc(2027, 7, 27),
  bundleIdId: bundleIdId,
  certificateIds: <String>[certificateId],
);

RecordingProcessRunner certificateRunner() => RecordingProcessRunner(
  handler: (invocation) async {
    if (invocation.executable == 'openssl' && invocation.arguments.first == 'x509') {
      final outputIndex = invocation.arguments.indexOf('-out');
      await File(
        invocation.arguments[outputIndex + 1],
      ).writeAsBytes(const <int>[1, 2, 3]);
    }
    return const RunResult(stdout: '', stderr: '', exitCode: 0);
  },
);

void main() {
  test(
    'downloads exact profiles for the certificate and every bundle ID',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-provisioning-');
      addTearDown(() => root.delete(recursive: true));
      final runner = certificateRunner();
      final client = FakeAppStoreConnectApi(
        signingCertificates: <AppleSigningCertificateDto>[certificate()],
        bundleIds: <AppleBundleIdentifierDto>[
          bundle('bundle-main', 'dev.example.app'),
          bundle('bundle-share', 'dev.example.app.ShareExtension'),
        ],
        profiles: <AppleProvisioningProfileDto>[
          profile(
            id: 'profile-main',
            bundleIdId: 'bundle-main',
            content: 'AQI=',
          ),
          profile(
            id: 'profile-share',
            bundleIdId: 'bundle-share',
            content: 'AwQ=',
          ),
        ],
      );

      final resolved = await AppleProvisioning.resolve(
        credentials: AppleSigningCredentials(
          certificateBase64: base64Encode(const <int>[9, 8, 7]),
          certificatePassword: 'secret password',
        ),
        bundleIds: const <String>{
          'dev.example.app',
          'dev.example.app.ShareExtension',
        },
        client: client,
        processRunner: runner,
        temporaryRoot: root,
        currentTime: () => DateTime.utc(2026, 7, 27),
      );

      expect(resolved.profilesByBundleId, <String, String>{
        'dev.example.app': 'AQI=',
        'dev.example.app.ShareExtension': 'AwQ=',
      });
      expect(client.createdProfiles, isEmpty);
      final pkcs12 = runner.invocations.firstWhere(
        (invocation) => invocation.executable == 'openssl' && invocation.arguments.first == 'pkcs12',
      );
      expect(pkcs12.arguments, isNot(contains('secret password')));
      expect(pkcs12.options.input, 'secret password\n');
      expect(await root.list().toList(), isEmpty);
    },
  );

  test(
    'creates only a missing exact profile and avoids name collisions',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-provisioning-');
      addTearDown(() => root.delete(recursive: true));
      const expectedName = 'SMF App Store dev.example.app AABBCCDD 2';
      final client = FakeAppStoreConnectApi(
        signingCertificates: <AppleSigningCertificateDto>[certificate()],
        bundleIds: <AppleBundleIdentifierDto>[
          bundle('bundle-main', 'dev.example.app'),
        ],
        profiles: <AppleProvisioningProfileDto>[
          profile(
            id: 'old-profile',
            bundleIdId: 'bundle-main',
            certificateId: 'old-certificate',
            name: 'SMF App Store dev.example.app AABBCCDD',
          ),
        ],
        createdProfile: profile(
          id: 'new-profile',
          bundleIdId: 'bundle-main',
          name: expectedName,
        ),
      );

      final resolved = await AppleProvisioning.resolve(
        credentials: AppleSigningCredentials(
          certificateBase64: base64Encode(const <int>[9, 8, 7]),
          certificatePassword: 'password',
        ),
        bundleIds: const <String>{'dev.example.app'},
        client: client,
        processRunner: certificateRunner(),
        temporaryRoot: root,
        currentTime: () => DateTime.utc(2026, 7, 27),
      );

      expect(client.createdProfiles.single.name, expectedName);
      expect(client.createdProfiles.single.bundleIdId, 'bundle-main');
      expect(client.createdProfiles.single.certificateId, 'certificate-1');
      expect(resolved.profilesByBundleId, <String, String>{
        'dev.example.app': 'BAUG',
      });
    },
  );

  test('skips malformed and near-expiry profiles', () async {
    final root = await Directory.systemTemp.createTemp('smf-provisioning-');
    addTearDown(() => root.delete(recursive: true));
    final client = FakeAppStoreConnectApi(
      signingCertificates: <AppleSigningCertificateDto>[certificate()],
      bundleIds: <AppleBundleIdentifierDto>[
        bundle('bundle-main', 'dev.example.app'),
      ],
      profiles: <AppleProvisioningProfileDto>[
        profile(
          id: 'newest-malformed',
          bundleIdId: 'bundle-main',
          content: 'not base64!',
          createdDate: DateTime.utc(2026, 7, 27, 12),
        ),
        profile(
          id: 'near-expiry',
          bundleIdId: 'bundle-main',
          content: 'AQI=',
          createdDate: DateTime.utc(2026, 7, 27, 11),
          expirationDate: DateTime.utc(2026, 7, 28, 11),
        ),
        profile(
          id: 'older-valid',
          bundleIdId: 'bundle-main',
          content: 'AwQ=',
          createdDate: DateTime.utc(2026, 7, 26),
        ),
      ],
    );

    final resolved = await AppleProvisioning.resolve(
      credentials: AppleSigningCredentials(
        certificateBase64: base64Encode(const <int>[9, 8, 7]),
        certificatePassword: 'password',
      ),
      bundleIds: const <String>{'dev.example.app'},
      client: client,
      processRunner: certificateRunner(),
      temporaryRoot: root,
      currentTime: () => DateTime.utc(2026, 7, 27, 12),
    );

    expect(resolved.profilesByBundleId, <String, String>{
      'dev.example.app': 'AwQ=',
    });
    expect(client.createdProfiles, isEmpty);
  });

  test(
    'reconciles a profile created despite a failed mutation response',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-provisioning-');
      addTearDown(() => root.delete(recursive: true));
      final racedProfile = profile(
        id: 'profile-from-concurrent-run',
        bundleIdId: 'bundle-main',
        content: 'AQI=',
      );
      final client = FakeAppStoreConnectApi(
        signingCertificates: <AppleSigningCertificateDto>[certificate()],
        bundleIds: <AppleBundleIdentifierDto>[
          bundle('bundle-main', 'dev.example.app'),
        ],
        profileCreationError: const SmfError(
          'Apple profile creation response was lost.',
          SmfErrorCode.appStoreConnectApi,
        ),
        profileCreatedBeforeError: racedProfile,
      );

      final resolved = await AppleProvisioning.resolve(
        credentials: AppleSigningCredentials(
          certificateBase64: base64Encode(const <int>[9, 8, 7]),
          certificatePassword: 'password',
        ),
        bundleIds: const <String>{'dev.example.app'},
        client: client,
        processRunner: certificateRunner(),
        temporaryRoot: root,
        currentTime: () => DateTime.utc(2026, 7, 27),
      );

      expect(resolved.profilesByBundleId, <String, String>{
        'dev.example.app': 'AQI=',
      });
      expect(client.createdProfiles, hasLength(1));
    },
  );

  test('preserves an unreconciled profile-creation failure', () async {
    final root = await Directory.systemTemp.createTemp('smf-provisioning-');
    addTearDown(() => root.delete(recursive: true));
    final client = FakeAppStoreConnectApi(
      signingCertificates: <AppleSigningCertificateDto>[certificate()],
      bundleIds: <AppleBundleIdentifierDto>[
        bundle('bundle-main', 'dev.example.app'),
      ],
      profileCreationError: const SmfError(
        'Apple rejected profile creation.',
        SmfErrorCode.originalCreationFailure,
      ),
    );

    await expectLater(
      AppleProvisioning.resolve(
        credentials: AppleSigningCredentials(
          certificateBase64: base64Encode(const <int>[9, 8, 7]),
          certificatePassword: 'password',
        ),
        bundleIds: const <String>{'dev.example.app'},
        client: client,
        processRunner: certificateRunner(),
        temporaryRoot: root,
        currentTime: () => DateTime.utc(2026, 7, 27),
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          SmfErrorCode.originalCreationFailure,
        ),
      ),
    );
  });

  test('rejects a p12 certificate from another Apple developer team', () async {
    final root = await Directory.systemTemp.createTemp('smf-provisioning-');
    addTearDown(() => root.delete(recursive: true));
    final client = FakeAppStoreConnectApi(
      signingCertificates: <AppleSigningCertificateDto>[
        certificate().copyWith(
          certificateContent: base64Encode(<int>[4, 5, 6]),
        ),
      ],
    );

    await expectLater(
      AppleProvisioning.resolve(
        credentials: AppleSigningCredentials(
          certificateBase64: base64Encode(const <int>[9, 8, 7]),
          certificatePassword: 'password',
        ),
        bundleIds: const <String>{'dev.example.app'},
        client: client,
        processRunner: certificateRunner(),
        temporaryRoot: root,
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          SmfErrorCode.appleCertificateNotFound,
        ),
      ),
    );
  });

  test('rejects a distribution certificate expiring within 24 hours', () async {
    final root = await Directory.systemTemp.createTemp('smf-provisioning-');
    addTearDown(() => root.delete(recursive: true));
    final client = FakeAppStoreConnectApi(
      signingCertificates: <AppleSigningCertificateDto>[
        certificate(expirationDate: DateTime.utc(2026, 7, 28, 11)),
      ],
    );

    await expectLater(
      AppleProvisioning.resolve(
        credentials: AppleSigningCredentials(
          certificateBase64: base64Encode(const <int>[9, 8, 7]),
          certificatePassword: 'password',
        ),
        bundleIds: const <String>{'dev.example.app'},
        client: client,
        processRunner: certificateRunner(),
        temporaryRoot: root,
        currentTime: () => DateTime.utc(2026, 7, 27, 12),
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          SmfErrorCode.appleCertificateInvalid,
        ),
      ),
    );
  });
}
