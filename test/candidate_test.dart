import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

import 'support/fake_app_store.dart';

const encoder = JsonEncoder.withIndent('  ');

Future<void> writeObject(String path, Object? value) =>
    File(path).writeAsString('${encoder.convert(value)}\n');

void main() {
  test(
    'refreshes notes when reusing the exact valid TestFlight build',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-candidate-');
      addTearDown(() => root.delete(recursive: true));
      await Directory(p.join(root.path, 'ios')).create();
      await File(
        p.join(root.path, 'pubspec.yaml'),
      ).writeAsString('name: example\nversion: 1.0.0+1\n');
      await File(
        p.join(root.path, 'pubspec.lock'),
      ).writeAsString('# fixture lockfile\n');
      await git(root.path, const <String>['init', '-b', 'main']);
      await git(root.path, const <String>['config', 'user.name', 'Test']);
      await git(root.path, const <String>[
        'config',
        'user.email',
        'test@example.com',
      ]);
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>['commit', '-m', 'chore: bootstrap']);
      await initialize(
        InitOptions(root: root.path, bundleId: 'dev.example.app'),
      );
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>[
        'commit',
        '-m',
        'chore: configure releases',
      ]);
      await git(root.path, const <String>[
        'checkout',
        '-b',
        'ship-my-flutter/ios',
      ]);
      final baselineSha = await currentSha(root.path);
      final paths = resolveShipPaths(root.path);
      final manifest = ShipManifest(
        ios: PlatformManifest(
          version: '1.1.0',
          baselineSha: baselineSha,
          pendingRelease: true,
        ),
      );
      await writeObject(paths.manifest, manifest.toJson());
      await writeObject(paths.storeReleaseNotes, <String, Object?>{
        'ios': <String, Object?>{
          '1.1.0': <String, Object?>{'en-US': 'Try the refreshed notes.'},
        },
      });
      final changelog = ChangelogManifest(
        iosReleases: <String, ChangelogRelease>{
          '1.1.0': ChangelogRelease(
            version: '1.1.0',
            preparedAt: DateTime.utc(2026, 7, 26),
            baseSha: baselineSha,
            headSha: baselineSha,
            changes: <ConventionalChange>[
              ConventionalChange(
                sha: baselineSha,
                type: 'feat',
                scope: 'ios',
                description: 'Fixture release',
                body: null,
                breaking: false,
                bump: Bump.minor,
                platforms: const <Platform>[Platform.ios],
              ),
            ],
          ),
        },
      );
      await writeObject(paths.changelog, changelog.toJson());
      final fingerprint = await sourceFingerprint(root.path);
      final receipt = CandidateReceipt(
        version: '1.1.0',
        buildNumber: '7',
        buildId: 'build-7',
        appId: 'app-1',
        bundleId: 'dev.example.app',
        sourceSha: baselineSha,
        sourceFingerprint: fingerprint,
        ipaSha256: List<String>.filled(64, 'a').join(),
        uploadedAt: DateTime.utc(2026, 7, 26),
        testflightGroups: const <String>[],
      );
      await writeObject(
        candidatePath(root.path, Platform.ios, '1.1.0'),
        receipt.toJson(),
      );
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>[
        'commit',
        '-m',
        'chore(ios): prepare fixture release',
      ]);
      final client = FakeAppStoreConnectApi(
        directBuild: const ApiResource<BuildAttributes>(
          type: 'builds',
          id: 'build-7',
          attributes: BuildAttributes(version: '7', processingState: 'VALID'),
        ),
      );

      final reused = await createIosCandidate(
        CandidateOptions(
          root: root.path,
          appleCredentials: const AppleCredentials(
            keyId: 'unused',
            issuerId: 'unused',
            privateKey: 'unused',
          ),
          signingCredentials: const SigningCredentials(
            certificateBase64: 'unused',
            certificatePassword: 'unused',
            provisioningProfiles: 'unused',
          ),
          client: client,
        ),
      );

      expect(reused.toJson(), receipt.toJson());
      expect(client.betaNotes.single.locale, 'en-US');
      expect(client.betaNotes.single.whatsNew, 'Try the refreshed notes.');

      await git(root.path, const <String>['checkout', 'main']);
      await expectLater(
        createIosCandidate(
          CandidateOptions(
            root: root.path,
            appleCredentials: const AppleCredentials(
              keyId: 'unused',
              issuerId: 'unused',
              privateKey: 'unused',
            ),
            signingCredentials: const SigningCredentials(
              certificateBase64: 'unused',
              certificatePassword: 'unused',
              provisioningProfiles: 'unused',
            ),
            client: client,
          ),
        ),
        throwsA(
          isA<ShipError>().having(
            (ShipError error) => error.message,
            'message',
            contains('only runs on ship-my-flutter/ios'),
          ),
        ),
      );
    },
  );
}
