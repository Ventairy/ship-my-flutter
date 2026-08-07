import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

Future<Directory> repository() async {
  final root = await Directory.systemTemp.createTemp('smf-orchestrator-');
  addTearDown(() => root.delete(recursive: true));
  final origin = await Directory.systemTemp.createTemp(
    'smf-orchestrator-origin-',
  );
  addTearDown(() => origin.delete(recursive: true));
  await GitClient(root: origin.path).run(
    const <String>['init', '--bare', '-b', 'main'],
  );
  await Directory(p.join(root.path, 'ios')).create();
  await File(
    p.join(root.path, 'pubspec.yaml'),
  ).writeAsString('name: example\nversion: 1.0.0+1\n');
  await File(
    p.join(root.path, 'pubspec.lock'),
  ).writeAsString('# fixture lockfile\n');
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
  await GitClient(root: root.path).run(<String>[
    'remote',
    'add',
    'origin',
    origin.path,
  ]);
  await GitClient(root: root.path).run(
    const <String>['push', '-u', 'origin', 'main'],
  );
  return root;
}

const context = GitHubContext(owner: 'example', repo: 'app', token: 'unused');

void main() {
  group('workflow routing', () {
    test(
      'routes only configured pending release branch to release-candidate',
      () async {
        final root = await repository();
        await GitClient(root: root.path).run(
          const <String>['checkout', '-b', 'smf/example/release'],
        );
        final paths = SmfPaths.resolve(root.path);
        final initial = await SmfState.manifest(root.path);
        final manifest = ManifestDto(
          schemaVersion: 1,
          platforms: ManifestPlatformsDto(
            ios: PlatformManifestDto(
              version: '1.1.0',
              endCommitHash: initial.platforms.ios.endCommitHash,
              isReleasePending: true,
            ),
            android: initial.platforms.android,
          ),
        );
        const encoder = JsonEncoder.withIndent('  ');
        await File(
          paths.manifest,
        ).writeAsString('${encoder.convert(manifest.toJson())}\n');
        final changelog = ChangelogDto(
          schemaVersion: 1,
          platforms: ChangelogPlatformsDto(
            ios: ChangelogPlatformDto(
              releases: <ChangelogPlatformReleaseVersionDto>[
                ChangelogPlatformReleaseVersionDto(
                  version: '1.1.0',
                  preparedAt: DateTime.utc(2026, 7, 26),
                  baseCommitHash: initial.platforms.ios.endCommitHash,
                  endCommitHash: initial.platforms.ios.endCommitHash,
                  changes: <ConventionalChangeDto>[
                    ConventionalChangeDto(
                      commitHash: initial.platforms.ios.endCommitHash,
                      type: 'feat',
                      scope: 'ios',
                      description: 'Fixture release',
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
        await File(
          paths.changelog,
        ).writeAsString('${encoder.convert(changelog.toJson())}\n');
        await GitClient(root: root.path).run(const <String>['add', '.']);
        await GitClient(root: root.path).run(const <String>[
          'commit',
          '-m',
          'chore(ios): release 1.1.0',
        ]);

        final result = await const ReleaseOrchestrator().plan(
          workingDirectory: root.path,
          github: context,
        );
        expect(result.toJson(), <String, Object?>{
          'nextPhase': 'release-candidate',
          'targets': <Object?>[
            <String, Object?>{'platform': 'ios', 'version': '1.1.0'},
          ],
          'releaseBranch': 'smf/example/release',
        });
        expect(
          (await const ReleaseOrchestrator().plan(
            workingDirectory: root.path,
            github: context,
            selectedPlatform: ReleasePlatform.android,
          )).toJson(),
          <String, Object?>{'nextPhase': 'noop'},
        );

        await GitClient(root: root.path).run(
          const <String>['tag', 'example/ios-v1.1.0'],
        );
        await GitClient(root: root.path).run(
          const <String>['push', 'origin', 'example/ios-v1.1.0'],
        );
        expect(
          (await const ReleaseOrchestrator().plan(
            workingDirectory: root.path,
            github: context,
          )).toJson(),
          <String, Object?>{'nextPhase': 'noop'},
        );
      },
    );

    test('does nothing on unrelated branches', () async {
      final root = await repository();
      await GitClient(root: root.path).run(const <String>['checkout', '-b', 'docs']);
      expect(
        (await const ReleaseOrchestrator().plan(
          workingDirectory: root.path,
          github: context,
        )).toJson(),
        <String, Object?>{'nextPhase': 'noop'},
      );
    });

    test('does nothing when iOS delivery is disabled', () async {
      final root = await repository();
      await Directory(p.join(root.path, 'android')).create();
      final configFile = File(SmfPaths.resolve(root.path).config);
      await configFile.writeAsString('''
schema_version: 1
app_id: example
platforms:
  ios:
    enabled: false
  android:
    enabled: true
''');
      expect(
        (await const ReleaseOrchestrator().plan(
          workingDirectory: root.path,
          github: context,
        )).toJson(),
        <String, Object?>{'nextPhase': 'noop'},
      );
    });
  });
}
