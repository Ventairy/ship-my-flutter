import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/android.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

const encoder = JsonEncoder.withIndent('  ');

Future<void> writeObject(String path, Object? value) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString('${encoder.convert(value)}\n');
}

void main() {
  test(
    'when promotion result collections are exposed, they should reject mutation',
    () {
      final result = AndroidShipReleaseResultDto(
        version: '1.2.3',
        tag: 'example/android-v1.2.3',
        versionCode: 7,
        testingTrack: 'internal',
        githubReleaseUrl: 'https://example.invalid/release',
        testingTracks: <String>['internal'],
        shippedTracks: <String>['production'],
      );

      expect(
        <void Function()>[
          result.testingTracks.clear,
          result.shippedTracks.clear,
        ],
        everyElement(throwsUnsupportedError),
      );
    },
  );

  test('when encoding an Android ship result, it should preserve evidence', () {
    final release = AndroidShipReleaseResultDto(
      version: '1.2.3',
      tag: 'example/android-v1.2.3',
      versionCode: 7,
      testingTrack: 'internal',
      githubReleaseUrl: 'https://example.invalid/release',
      testingTracks: <String>['internal'],
      shippedTracks: <String>['production'],
      productionTrack: 'production',
    );

    expect(
      ShipPhaseResultDto(
        androidRelease: release,
      ).toJson(),
      <String, Object?>{
        'shippedReleases': <Object?>[
          <String, Object?>{
            'platform': 'android',
            'version': '1.2.3',
            'tag': 'example/android-v1.2.3',
            'artifactId': '7',
            'buildNumber': '7',
            'testingTrack': 'internal',
            'testingTracks': <String>['internal'],
            'shippedTracks': <String>['production'],
            'productionTrack': 'production',
            'githubReleaseUrl': 'https://example.invalid/release',
          },
        ],
      },
    );
  });

  test('moves the exact internal-testing versionCode to production', () async {
    final root = await Directory.systemTemp.createTemp('smf-android-promote-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'android')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 1.0.0+1\n');
    await File(p.join(root.path, 'pubspec.lock')).writeAsString('# lock\n');
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
    final remote = await Directory.systemTemp.createTemp(
      'smf-android-promote-remote-',
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
      InitOptions(
        appRoot: root.path,
        androidPackageName: 'dev.example.android',
      ),
    );
    final paths = SmfPaths.resolve(root.path);
    final configFile = File(paths.config);
    await configFile.writeAsString(
      (await configFile.readAsString()).replaceFirst(
        '    google_play:\n'
            '      release_candidate:\n'
            '        target: internal-testing',
        '    google_play:\n'
            '      release_candidate:\n'
            '        target: internal-testing\n'
            '      ship:\n'
            '        target: production',
      ),
    );
    await GitClient(root: root.path).run(const <String>['add', '.']);
    await GitClient(root: root.path).run(const <String>[
      'commit',
      '-m',
      'chore: configure releases',
    ]);
    final baseline = await GitClient(root: root.path).currentCommitHash();
    final initial = await SmfState.manifest(root.path);
    await writeObject(
      paths.manifest,
      ManifestDto(
        schemaVersion: 1,
        platforms: ManifestPlatformsDto(
          ios: initial.platforms.ios,
          android: PlatformManifestDto(
            version: '1.1.0',
            endCommitHash: baseline,
            isReleasePending: true,
          ),
        ),
      ).toJson(),
    );
    await writeObject(
      paths.changelog,
      ChangelogDto(
        schemaVersion: 1,
        platforms: ChangelogPlatformsDto(
          ios: const ChangelogPlatformDto(
            releases: <ChangelogPlatformReleaseVersionDto>[],
          ),
          android: ChangelogPlatformDto(
            releases: <ChangelogPlatformReleaseVersionDto>[
              ChangelogPlatformReleaseVersionDto(
                version: '1.1.0',
                preparedAt: DateTime.utc(2026, 7, 27),
                baseCommitHash: baseline,
                endCommitHash: baseline,
                changes: <ConventionalChangeDto>[
                  ConventionalChangeDto(
                    commitHash: baseline,
                    type: 'feat',
                    scope: 'android',
                    description: 'Android release',
                    body: null,
                    isBreaking: false,
                    versionBumpType: VersionBumpType.minor,
                    platforms: const <ReleasePlatform>[ReleasePlatform.android],
                  ),
                ],
              ),
            ],
          ),
        ),
      ).toJson(),
    );
    await writeObject(paths.storeReleaseNotes, <String, Object?>{
      'android': <String, Object?>{
        '1.1.0': <String, Object?>{'en-US': 'Ready for everyone.'},
      },
    });
    await GitClient(root: root.path).run(const <String>['add', '.']);
    await GitClient(root: root.path).run(const <String>[
      'commit',
      '-m',
      'chore(android): release 1.1.0',
    ]);
    final sourceCommitHash = await GitClient(root: root.path).currentCommitHash();
    final fingerprint = await SourceFingerprint.calculate(root.path);
    const artifactHash = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    await writeObject(
      paths.releaseCandidateReceiptPath(
        platform: ReleasePlatform.android,
        version: '1.1.0',
      ),
      ReleaseCandidateReceiptDto(
        schemaVersion: 1,
        platform: ReleasePlatform.android,
        version: '1.1.0',
        buildNumber: '9',
        artifactId: '9',
        applicationId: 'dev.example.android',
        storeApplicationId: 'dev.example.android',
        sourceCommitHash: sourceCommitHash,
        sourceFingerprint: fingerprint,
        artifactSha256: artifactHash,
        uploadedAt: DateTime.utc(2026, 7, 27),
        testingDestinations: const <String>['qa'],
        processingState: 'VALID',
      ).toJson(),
    );
    await GitClient(root: root.path).run(const <String>['add', '.']);
    await GitClient(root: root.path).run(const <String>[
      'commit',
      '-m',
      'chore(android): record release candidate',
    ]);

    final play = FakeGooglePlayApi(
      bundles: const <GooglePlayBundle>[
        GooglePlayBundle(versionCode: 9, sha256: artifactHash),
      ],
      tracks: <String, GooglePlayTrack>{
        'qa': GooglePlayTrack(
          name: 'qa',
          releases: <GooglePlayRelease>[
            GooglePlayRelease(
              status: GooglePlayReleaseStatus.completed,
              versionCodes: <int>[9],
            ),
          ],
        ),
        'production': GooglePlayTrack(name: 'production'),
      },
    );
    final github = FakeGitHubApi();
    final result = await AndroidRelease.promote(
      AndroidPromotionOptions(
        workingDirectory: root.path,
        googlePlayCredentials: const GooglePlayCredentials(
          serviceAccountJson: '{"type":"service_account"}',
        ),
        github: const GitHubContext(
          owner: 'example',
          repo: 'app',
          token: 'unused',
        ),
        client: play,
        githubApi: github,
      ),
    );

    expect(result.toJson(), containsPair('artifactId', '9'));
    expect(result.productionTrack, 'production');
    expect(play.updates.single.name, 'production');
    expect(play.updates.single.releases.single.versionCodes, <int>[9]);
    expect(
      play.updates.single.releases.single.releaseNotes,
      <String, String>{'en-US': 'Ready for everyone.'},
    );
    expect(play.committedReviewStates, <bool>[false]);
    expect(github.createdTags, <String>['example/android-v1.1.0']);
  });
}
