import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/apple.dart';
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
      final remote = await Directory.systemTemp.createTemp(
        'smf-promote-remote-',
      );
      addTearDown(() => remote.delete(recursive: true));
      await GitClient(root: remote.path).run(const <String>['init', '--bare']);
      await GitClient(root: root.path).run(<String>[
        'remote',
        'add',
        'origin',
        remote.path,
      ]);
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
      final endCommitHash = await GitClient(root: root.path).currentCommitHash();
      final manifest = ManifestDto(
        schemaVersion: 1,
        platforms: ManifestPlatformsDto(
          ios: PlatformManifestDto(
            version: '1.1.0',
            endCommitHash: endCommitHash,
            isReleasePending: true,
          ),
          android: PlatformManifestDto(
            version: '0.0.0',
            endCommitHash: endCommitHash,
            isReleasePending: false,
          ),
        ),
      );
      await writeObject(paths.manifest, manifest.toJson());
      final changelog = ChangelogDto(
        schemaVersion: 1,
        platforms: ChangelogPlatformsDto(
          ios: ChangelogPlatformDto(
            releases: <ChangelogPlatformReleaseVersionDto>[
              ChangelogPlatformReleaseVersionDto(
                version: '1.1.0',
                preparedAt: DateTime.utc(2026, 7, 26),
                baseCommitHash: endCommitHash,
                endCommitHash: endCommitHash,
                changes: <ConventionalChangeDto>[
                  ConventionalChangeDto(
                    commitHash: endCommitHash,
                    type: 'feat',
                    scope: 'ios',
                    description: 'Tested release',
                    body: null,
                    isBreaking: false,
                    versionBumpType: VersionBumpType.minor,
                    platforms: const <ReleasePlatform>[ReleasePlatform.ios],
                  ),
                ],
              ),
            ],
          ),
          android: const ChangelogPlatformDto(
            releases: <ChangelogPlatformReleaseVersionDto>[],
          ),
        ),
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
      final sourceCommitHash = await GitClient(root: root.path).currentCommitHash();
      final fingerprint = await SourceFingerprint.calculate(root.path);
      final receipt = ReleaseCandidateReceiptDto(
        schemaVersion: 1,
        platform: ReleasePlatform.ios,
        version: '1.1.0',
        buildNumber: '7',
        artifactId: 'build-7',
        applicationId: 'dev.example.app',
        storeApplicationId: 'app-1',
        sourceCommitHash: sourceCommitHash,
        sourceFingerprint: fingerprint,
        artifactSha256: List<String>.filled(64, 'a').join(),
        uploadedAt: DateTime.utc(2026, 7, 26),
        testingDestinations: const <String>['Internal'],
        processingState: 'VALID',
      );
      await writeObject(
        paths.releaseCandidateReceiptPath(
          platform: ReleasePlatform.ios,
          version: '1.1.0',
        ),
        receipt.toJson(),
      );
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>[
        'commit',
        '-m',
        'chore(ios): record release candidate',
      ]);

      final appStore = FakeAppStoreConnectApi(
        builds: const <ApiResourceDto<BuildAttributesDto>>[
          ApiResourceDto<BuildAttributesDto>(
            type: 'builds',
            id: 'build-7',
            attributes: BuildAttributesDto(
              version: '7',
              processingState: BuildProcessingState.valid,
            ),
          ),
        ],
        appStoreVersion: const ApiResourceDto<AppStoreVersionAttributesDto>(
          type: 'appStoreVersions',
          id: 'version-1',
          attributes: AppStoreVersionAttributesDto(
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
      expect(appStore.isSubmitted, isTrue);
      expect(appStore.shouldReleaseAutomatically, isTrue);
      expect(appStore.isClosed, isFalse);
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
        'chore(ios): ship release candidate to external testing',
      ]);
      github.existingRelease = GitHubReleaseDto(
        htmlUrl: 'https://github.com/example/app/releases/tag/example/ios-v1.1.0',
        tagName: 'example/ios-v1.1.0',
        targetCommitish: await GitClient(root: root.path).currentCommitHash(),
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
      expect(appStore.isBetaSubmitted, isTrue);

      await GitClient(root: root.path).run(<String>[
        'push',
        'origin',
        '$endCommitHash:refs/tags/example/ios-v1.1.0',
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
            SmfErrorCode.remoteTagMismatch,
          ),
        ),
      );
      await GitClient(root: root.path).run(const <String>[
        'push',
        'origin',
        ':refs/tags/example/ios-v1.1.0',
      ]);

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
            SmfErrorCode.untestedSource,
          ),
        ),
      );
    },
  );
}
