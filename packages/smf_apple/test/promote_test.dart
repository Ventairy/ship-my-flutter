import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_apple/smf_apple.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

import 'support/fake_app_store.dart';
import 'support/fake_github.dart';

const encoder = JsonEncoder.withIndent('  ');

Future<void> writeObject(String path, Object? value) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString('${encoder.convert(value)}\n');
}

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
      await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
      await GitClient(root: root.path).run(const <String>['config', 'user.name', 'Test']);
      await GitClient(root: root.path).run(const <String>[
        'config',
        'user.email',
        'test@example.com',
      ]);
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>['commit', '-m', 'chore: bootstrap']);
      await RepositoryInitializer.initialize(
        InitOptions(appRoot: root.path, iosBundleId: 'dev.example.app'),
      );
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>[
        'commit',
        '-m',
        'chore: configure releases',
      ]);
      final paths = SmfPaths.resolve(root.path);
      final configFile = File(paths.config);
      await configFile.writeAsString(
        (await configFile.readAsString()).replaceFirst(
          '        wait_timeout_minutes: 45',
          '        wait_timeout_minutes: 45\n'
              '      ship:\n'
              '        target: production',
        ),
      );
      final baselineSha = await GitClient(root: root.path).currentSha();
      final manifest = SmfManifest(
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
                versionBump: VersionBump.minor,
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
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>[
        'commit',
        '-m',
        'chore(ios): release 1.1.0',
      ]);
      final sourceSha = await GitClient(root: root.path).currentSha();
      final fingerprint = await SourceFingerprint.calculate(root.path);
      final receipt = CandidateReceipt(
        platform: Platform.ios,
        version: '1.1.0',
        buildNumber: '7',
        artifactId: 'build-7',
        applicationId: 'dev.example.app',
        storeApplicationId: 'app-1',
        sourceSha: sourceSha,
        sourceFingerprint: fingerprint,
        artifactSha256: List<String>.filled(64, 'a').join(),
        uploadedAt: DateTime.utc(2026, 7, 26),
        testingDestinations: const <String>['Internal'],
      );
      await writeObject(
        paths.candidatePath(
          platform: Platform.ios,
          version: '1.1.0',
        ),
        receipt.toJson(),
      );
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>[
        'commit',
        '-m',
        'chore(ios): record candidate',
      ]);

      final appStore = FakeAppStoreConnectApi(
        builds: const <ApiResource<BuildAttributes>>[
          ApiResource<BuildAttributes>(
            type: 'builds',
            id: 'build-7',
            attributes: BuildAttributes(
              version: '7',
              processingState: BuildProcessingState.valid,
            ),
          ),
        ],
        appStoreVersion: const ApiResource<AppStoreVersionAttributes>(
          type: 'appStoreVersions',
          id: 'version-1',
          attributes: AppStoreVersionAttributes(
            platform: ApplePlatform.ios,
            versionString: '1.1.0',
            appVersionState: AppVersionState.prepareForSubmission,
            releaseType: AppStoreReleaseType.manual,
          ),
        ),
      );
      final github = FakeGitHubApi();
      final result = await AppleRelease.promote(
        ApplePromotionOptions(
          workingDirectory: root.path,
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
      expect(result.artifactId, 'build-7');
      expect(result.appStoreVersionId, 'version-1');
      expect(result.reviewSubmissionId, 'submission-1');
      expect(appStore.attachedBuildId, 'build-7');
      expect(appStore.storeNotes.single.whatsNew, 'Ready for launch.');
      expect(appStore.submitted, isTrue);
      expect(appStore.releaseAutomatically, isTrue);
      expect(appStore.closed, isFalse);
      expect(github.releases.single.tag, 'example/ios-v1.1.0');

      await configFile.writeAsString(
        (await configFile.readAsString()).replaceFirst(
          '      ship:\n'
              '        target: production',
          '      ship:\n'
              '        target: external-testing\n'
              '        groups:\n'
              '          - Public Beta',
        ),
      );
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>[
        'commit',
        '-m',
        'chore(ios): ship candidate to external testing',
      ]);
      github.existingRelease = const GitHubRelease(
        htmlUrl: 'https://github.com/example/app/releases/tag/example/ios-v1.1.0',
      );

      final externalResult = await AppleRelease.promote(
        ApplePromotionOptions(
          workingDirectory: root.path,
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

      expect(externalResult.appStoreVersionId, isNull);
      expect(
        externalResult.betaReviewSubmissionId,
        'beta-submission-1',
      );
      expect(appStore.groupAssignments.single.groups, <String>['Public Beta']);
      expect(appStore.betaSubmitted, isTrue);

      await File(p.join(root.path, 'app.txt')).writeAsString('untested\n');
      await GitClient(root: root.path).run(const <String>['add', 'app.txt']);
      await GitClient(root: root.path).run(const <String>[
        'commit',
        '-m',
        'fix: untested change',
      ]);
      await expectLater(
        AppleRelease.promote(
          ApplePromotionOptions(
            workingDirectory: root.path,
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
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'UNTESTED_SOURCE',
          ),
        ),
      );
    },
  );
}
