import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

import 'support/fake_app_store.dart';
import 'support/fake_github.dart';

const encoder = JsonEncoder.withIndent('  ');

Future<void> writeObject(String path, Object? value) =>
    File(path).writeAsString('${encoder.convert(value)}\n');

void main() {
  test(
    'promotes only the exact tested build and creates a GitHub release',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-promote-');
      addTearDown(() => root.delete(recursive: true));
      await Directory(p.join(root.path, 'ios')).create();
      await File(
        p.join(root.path, 'pubspec.yaml'),
      ).writeAsString('name: example\nversion: 1.0.0+1\n');
      await File(
        p.join(root.path, 'pubspec.lock'),
      ).writeAsString('# fixture lockfile\n');
      await File(p.join(root.path, 'app.txt')).writeAsString('tested\n');
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
      final paths = resolveShipPaths(root.path);
      final configFile = File(paths.config);
      await configFile.writeAsString(
        (await configFile.readAsString()).replaceFirst(
          'mode: upload',
          'mode: auto',
        ),
      );
      final baselineSha = await currentSha(root.path);
      final manifest = ShipManifest(
        ios: PlatformManifest(
          version: '1.1.0',
          baselineSha: baselineSha,
          pendingRelease: true,
        ),
      );
      await writeObject(paths.manifest, manifest.toJson());
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
                description: 'Tested release',
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
      await writeObject(paths.storeReleaseNotes, <String, Object?>{
        'ios': <String, Object?>{
          '1.1.0': <String, Object?>{'en-US': 'Ready for launch.'},
        },
      });
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
        testflightGroups: const <String>['Internal'],
      );
      await writeObject(
        candidatePath(root.path, Platform.ios, '1.1.0'),
        receipt.toJson(),
      );
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>[
        'commit',
        '-m',
        'chore(ios): release 1.1.0',
      ]);

      final appStore = FakeAppStoreConnectApi(
        builds: const <ApiResource<BuildAttributes>>[
          ApiResource<BuildAttributes>(
            type: 'builds',
            id: 'build-7',
            attributes: BuildAttributes(version: '7', processingState: 'VALID'),
          ),
        ],
        appStoreVersion: const ApiResource<AppStoreVersionAttributes>(
          type: 'appStoreVersions',
          id: 'version-1',
          attributes: AppStoreVersionAttributes(
            platform: 'IOS',
            versionString: '1.1.0',
            appStoreState: 'PREPARE_FOR_SUBMISSION',
            releaseType: 'MANUAL',
          ),
        ),
      );
      final github = FakeGitHubApi();
      final result = await promoteIosRelease(
        PromotionOptions(
          root: root.path,
          appleCredentials: const AppleCredentials(
            keyId: 'unused',
            issuerId: 'unused',
            privateKey: 'unused',
          ),
          github: const GitHubContext(
            owner: 'example',
            repo: 'app',
            token: 'unused',
          ),
          client: appStore,
          githubApi: github,
        ),
      );

      expect(result.version, '1.1.0');
      expect(result.buildId, 'build-7');
      expect(result.appStoreVersionId, 'version-1');
      expect(result.reviewSubmissionId, 'submission-1');
      expect(appStore.attachedBuildId, 'build-7');
      expect(appStore.storeNotes.single.whatsNew, 'Ready for launch.');
      expect(appStore.submitted, isTrue);
      expect(appStore.releaseAutomatically, isTrue);
      expect(github.releases.single.tag, 'ios-v1.1.0');

      await File(p.join(root.path, 'app.txt')).writeAsString('untested\n');
      await git(root.path, const <String>['add', 'app.txt']);
      await git(root.path, const <String>[
        'commit',
        '-m',
        'fix: untested change',
      ]);
      await expectLater(
        promoteIosRelease(
          PromotionOptions(
            root: root.path,
            appleCredentials: const AppleCredentials(
              keyId: 'unused',
              issuerId: 'unused',
              privateKey: 'unused',
            ),
            github: const GitHubContext(
              owner: 'example',
              repo: 'app',
              token: 'unused',
            ),
            client: appStore,
            githubApi: github,
          ),
        ),
        throwsA(
          isA<ShipError>().having(
            (ShipError error) => error.code,
            'code',
            'UNTESTED_SOURCE',
          ),
        ),
      );
    },
  );
}
