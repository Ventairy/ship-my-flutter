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
    'uploads the next versionCode to internal testing and records it',
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
        InitOptions(appRoot: root.path, packageName: 'dev.example.android'),
      );
      final paths = resolveSmfPaths(root.path);
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>[
        'commit',
        '-m',
        'chore: configure releases',
      ]);
      await git(root.path, const <String>['checkout', '-b', 'smf/release']);
      final baseline = await currentSha(root.path);
      final initial = await loadManifest(root.path);
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
      await writeObject(paths.storeReleaseNotes, <String, Object?>{
        'android': <String, Object?>{
          '1.1.0': <String, Object?>{'en-US': 'Ready for internal testing.'},
        },
      });
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>[
        'commit',
        '-m',
        'chore(android): prepare release',
      ]);

      final play = FakeGooglePlayApi(
        bundles: const <GooglePlayBundle>[
          GooglePlayBundle(versionCode: 8, sha256: 'old'),
        ],
      );
      final result = await createAndroidCandidate(
        AndroidCandidateOptions(
          workingDirectory: root.path,
          googlePlayCredentials: googleCredentials,
          signingCredentials: signingCredentials,
          client: play,
          commitReceipt: false,
          dependencies: AndroidCandidateDependencies(
            runBeforeBuild: (_, _, _, _) async => false,
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
                  expect(buildNumber, '9');
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
      expect(result.artifactId, '9');
      expect(result.applicationId, 'dev.example.android');
      expect(result.testingDestinations, <String>['internal']);
      expect(play.updates.single.name, 'internal');
      expect(play.updates.single.releases.single.versionCodes, <int>[9]);
      expect(
        play.updates.single.releases.single.releaseNotes,
        <String, String>{'en-US': 'Ready for internal testing.'},
      );
      expect(play.validateCount, 1);
      expect(play.committedReviewStates, <bool>[false]);
      expect(
        (await loadCandidateReceipt(
          candidatePath(root.path, Platform.android, '1.1.0'),
        )).artifactId,
        '9',
      );
    },
  );
}
