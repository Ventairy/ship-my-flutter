import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf/smf.dart';
import 'package:test/test.dart';

void main() {
  test(
    'initializer creates only configuration and the complete workflow',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-init-');
      addTearDown(() => root.delete(recursive: true));
      await Directory(p.join(root.path, 'ios')).create();
      await File(
        p.join(root.path, 'pubspec.yaml'),
      ).writeAsString('name: example\nversion: 3.2.1+42\n');
      await git(root.path, const <String>['init', '-b', 'main']);
      await git(root.path, const <String>['config', 'user.name', 'Test']);
      await git(root.path, const <String>[
        'config',
        'user.email',
        'test@example.com',
      ]);
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>['commit', '-m', 'chore: bootstrap']);
      final baselineSha = await currentSha(root.path);

      await initialize(
        InitOptions(appRoot: root.path, bundleId: 'dev.example.app'),
      );

      final manifest = await loadManifest(root.path);
      expect(manifest.ios.version, '3.2.1');
      expect(manifest.ios.baselineSha, baselineSha);
      expect(manifest.ios.pendingRelease, isFalse);
      final config = await loadConfig(root.path);
      expect(config.schemaVersion, 1);
      expect(config.ios.initialVersion, '3.2.1');
      expect(config.ios.buildCommand, isNull);
      expect(config.ios.appStore.mode, ReleaseMode.upload);
      final configText = await File(
        resolveSmfPaths(root.path).config,
      ).readAsString();
      expect(
        configText,
        contains(
          '# yaml-language-server: \$schema='
          'https://raw.githubusercontent.com/Ventairy/smf/main/'
          'schemas/config.schema.json',
        ),
      );
      expect(configText, isNot(contains('build_command:')));
      expect(configText, isNot(contains('ipa_output_path:')));
      expect(configText, isNot(contains('app_path:')));
      expect(configText, isNot(contains('hooks:')));
      expect(config.ios.ipaOutputPath, 'build/ios/ipa');
      final paths = resolveSmfPaths(root.path);
      expect(await File(paths.manifest).exists(), isFalse);
      expect(await File(paths.changelog).exists(), isFalse);
      expect(await File(paths.storeReleaseNotes).exists(), isFalse);
      expect(await Directory(paths.candidates).exists(), isFalse);
      expect((await loadChangelog(root.path)).iosReleases, isEmpty);
      expect(await loadStoreReleaseNotes(root.path), isEmpty);
      final workflow = await File(
        p.join(root.path, '.github', 'workflows', 'smf.yml'),
      ).readAsString();
      expect(workflow, await File('templates/smf.yml').readAsString());
      expect(workflow, contains('Ventairy/smf-action@v1'));
      expect(workflow, contains('subosito/flutter-action@'));
      expect(
        workflow,
        contains("hashFiles('**/.fvmrc', '**/.fvm/fvm_config.json')"),
      );
      expect(workflow, contains('dart pub global activate fvm 4.1.2'));
      expect(workflow, contains('runs-on: macos-26'));
      expect(workflow, contains('  pull_request:'));
      expect(workflow, contains('  release_candidate:'));
      expect(workflow, contains('  ship:'));
      expect(workflow, contains('phase: pull-request'));
      expect(workflow, contains('phase: release-candidate'));
      expect(workflow, contains('phase: ship'));
      expect(workflow, isNot(contains('phase: plan')));
      expect(workflow, isNot(contains('phase: candidate')));
      expect(workflow, isNot(contains('phase: promote')));
      expect(
        RegExp('persist-credentials: false').allMatches(workflow),
        hasLength(3),
      );
    },
  );

  test('initializes a nested Flutter app without an app_path field', () async {
    final repository = await Directory.systemTemp.createTemp('smf-init-');
    addTearDown(() => repository.delete(recursive: true));
    final app = Directory(p.join(repository.path, 'apps', 'mobile'));
    await Directory(p.join(app.path, 'ios')).create(recursive: true);
    await File(
      p.join(app.path, 'pubspec.yaml'),
    ).writeAsString('name: mobile\nversion: 2.0.0+1\n');
    await git(repository.path, const <String>['init', '-b', 'main']);

    await initialize(InitOptions(appRoot: app.path));

    final configPath = p.join(app.path, 'smf', 'config.yaml');
    expect(await File(configPath).exists(), isTrue);
    expect(await File(configPath).readAsString(), isNot(contains('app_path')));
    expect(
      await File(
        p.join(repository.path, '.github', 'workflows', 'smf.yml'),
      ).exists(),
      isTrue,
    );
    final paths = resolveSmfPaths(repository.path);
    expect(paths.appRoot, app.path);
    expect(paths.repositoryRoot, repository.path);
  });
}
