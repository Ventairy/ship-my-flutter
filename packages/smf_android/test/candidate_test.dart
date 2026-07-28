import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_android/smf_android.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

const encoder = JsonEncoder.withIndent('  ');
const signingCredentials = AndroidSigningCredentials(
  keystoreBase64: 'AQID',
  keyAlias: 'upload',
  keystorePassword: 'store',
  keyPassword: 'key',
);
const googleCredentials = GooglePlayCredentials(
  serviceAccountJson: '{"type":"service_account"}',
);

Future<void> writeObject(String path, Object? value) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString('${encoder.convert(value)}\n');
}

void main() {
  test(
    'when an older APK has the highest code, it should upload the next versionCode to every configured track',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'smf-android-candidate-',
      );
      addTearDown(() => root.delete(recursive: true));
      await Directory(p.join(root.path, 'android')).create();
      await File(p.join(root.path, '.gitignore')).writeAsString('/build/\n');
      await File(
        p.join(root.path, 'pubspec.yaml'),
      ).writeAsString('name: example\nversion: 1.0.0+1\n');
      await File(p.join(root.path, 'pubspec.lock')).writeAsString('# lock\n');
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
        InitOptions(
          appRoot: root.path,
          androidPackageName: 'dev.example.android',
        ),
      );
      final paths = SmfPaths.resolve(root.path);
      final configFile = File(paths.config);
      await configFile.writeAsString(
        (await configFile.readAsString()).replaceFirst(
          '        target: internal-testing',
          '        target: closed-testing\n'
              '        tracks:\n'
              '          - internal-qa\n'
              '          - trusted-users',
        ),
      );
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>[
        'commit',
        '-m',
        'chore: configure releases',
      ]);
      await GitClient(root: root.path).run(
        const <String>['checkout', '-b', 'smf/example/release'],
      );
      final baseline = await GitClient(root: root.path).currentSha();
      final initial = await SmfState.manifest(root.path);
      await writeObject(
        paths.manifest,
        SmfManifest(
          ios: initial.ios,
          android: PlatformManifest(
            version: '1.1.0',
            baselineSha: baseline,
            pendingRelease: true,
          ),
        ).toJson(),
      );
      await writeObject(
        paths.changelog,
        ChangelogManifest(
          iosReleases: const <String, ChangelogRelease>{},
          androidReleases: <String, ChangelogRelease>{
            '1.1.0': ChangelogRelease(
              version: '1.1.0',
              preparedAt: DateTime.utc(2026, 7, 28),
              baseSha: baseline,
              headSha: baseline,
              changes: <ConventionalChange>[
                ConventionalChange(
                  sha: baseline,
                  type: 'feat',
                  scope: 'android',
                  description: 'Prepare Android candidate',
                  body: null,
                  breaking: false,
                  versionBump: VersionBump.minor,
                  platforms: const <Platform>[Platform.android],
                ),
              ],
            ),
          },
        ).toJson(),
      );
      await writeObject(paths.storeReleaseNotes, <String, Object?>{
        'android': <String, Object?>{
          '1.1.0': <String, Object?>{'en-US': 'Ready for internal testing.'},
        },
      });
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>[
        'commit',
        '-m',
        'chore(android): prepare release',
      ]);

      final play = FakeGooglePlayApi(
        bundles: const <GooglePlayBundle>[
          GooglePlayBundle(versionCode: 8, sha256: 'old'),
        ],
        artifactVersionCodes: <int>{8, 41},
      );
      final result = await AndroidCandidate.create(
        AndroidCandidateOptions(
          workingDirectory: root.path,
          googlePlayCredentials: googleCredentials,
          signingCredentials: signingCredentials,
          client: play,
          commitReceipt: false,
          dependencies: AndroidCandidateDependencies(
            runBeforeBuild: ({required workingDirectory}) async => false,
            buildAab:
                ({
                  required projectRoot,
                  required command,
                  required aabOutputPath,
                  required version,
                  required buildNumber,
                  required signing,
                  required credentials,
                  flavor,
                }) async {
                  expect(version, '1.1.0');
                  expect(buildNumber, '42');
                  expect(command, 'flutter build appbundle --release');
                  final artifact = File(
                    p.join(projectRoot, 'build', 'app-release.aab'),
                  );
                  await artifact.parent.create(recursive: true);
                  await artifact.writeAsBytes(<int>[9, 9, 9]);
                  return artifact.path;
                },
            currentTime: () => DateTime.utc(2026, 7, 27),
          ),
        ),
      );

      expect(result.platform, Platform.android);
      expect(result.version, '1.1.0');
      expect(result.artifactId, '42');
      expect(result.applicationId, 'dev.example.android');
      expect(result.testingDestinations, <String>[
        'internal-qa',
        'trusted-users',
      ]);
      expect(
        play.updates.map((track) => track.name),
        <String>['internal-qa', 'trusted-users'],
      );
      for (final track in play.updates) {
        expect(track.releases.single.versionCodes, <int>[42]);
        expect(
          track.releases.single.releaseNotes,
          <String, String>{'en-US': 'Ready for internal testing.'},
        );
      }
      expect(play.validateCount, 1);
      expect(play.committedReviewStates, <bool>[false]);
      expect(
        (await CandidateReceipt.read(
          paths.candidatePath(
            platform: Platform.android,
            version: '1.1.0',
          ),
        )).artifactId,
        '42',
      );
    },
  );
}
