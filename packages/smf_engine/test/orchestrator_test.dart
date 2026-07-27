import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

String repeated(String value, int count) =>
    List<String>.filled(count, value).join();

Future<Directory> repository() async {
  final root = await Directory.systemTemp.createTemp('smf-orchestrator-');
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
    InitOptions(appRoot: root.path, bundleId: 'dev.example.app'),
  );
  await git(root.path, const <String>['add', '.']);
  await git(root.path, const <String>[
    'commit',
    '-m',
    'chore: configure releases',
  ]);
  return root;
}

const context = GitHubContext(owner: 'example', repo: 'app', token: 'unused');

void main() {
  group('workflow routing', () {
    test(
      'routes only configured pending release branch to release-candidate',
      () async {
        final root = await repository();
        await git(root.path, const <String>['checkout', '-b', 'smf/ios']);
        final paths = resolveSmfPaths(root.path);
        final initial = await loadManifest(root.path);
        final manifest = SmfManifest(
          ios: PlatformManifest(
            version: '1.1.0',
            baselineSha: initial.ios.baselineSha,
            pendingRelease: true,
          ),
        );
        const encoder = JsonEncoder.withIndent('  ');
        await File(
          paths.manifest,
        ).writeAsString('${encoder.convert(manifest.toJson())}\n');
        final changelog = ChangelogManifest(
          iosReleases: <String, ChangelogRelease>{
            '1.1.0': ChangelogRelease(
              version: '1.1.0',
              preparedAt: DateTime.utc(2026, 7, 26),
              baseSha: initial.ios.baselineSha,
              headSha: initial.ios.baselineSha,
              changes: <ConventionalChange>[
                ConventionalChange(
                  sha: initial.ios.baselineSha,
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
        await File(
          paths.changelog,
        ).writeAsString('${encoder.convert(changelog.toJson())}\n');
        await git(root.path, const <String>['add', '.']);
        await git(root.path, const <String>[
          'commit',
          '-m',
          'chore(ios): release 1.1.0',
        ]);

        final result = await planGitHubRelease(
          workingDirectory: root.path,
          github: context,
        );
        expect(result.toJson(), <String, Object?>{
          'phase': 'release-candidate',
          'platform': 'ios',
          'version': '1.1.0',
          'branch': 'smf/ios',
        });

        await git(root.path, const <String>['tag', 'ios-v1.1.0']);
        expect(
          (await planGitHubRelease(
            workingDirectory: root.path,
            github: context,
          )).toJson(),
          <String, Object?>{'phase': 'noop'},
        );
      },
    );

    test('does nothing on unrelated branches', () async {
      final root = await repository();
      await git(root.path, const <String>['checkout', '-b', 'docs']);
      expect(
        (await planGitHubRelease(
          workingDirectory: root.path,
          github: context,
        )).toJson(),
        <String, Object?>{'phase': 'noop'},
      );
    });

    test('does nothing when iOS delivery is disabled', () async {
      final root = await repository();
      final configFile = File(resolveSmfPaths(root.path).config);
      final config = await configFile.readAsString();
      await configFile.writeAsString(
        config.replaceFirst('enabled: true', 'enabled: false'),
      );
      expect(
        (await planGitHubRelease(
          workingDirectory: root.path,
          github: context,
        )).toJson(),
        <String, Object?>{'phase': 'noop'},
      );
    });
  });
}
