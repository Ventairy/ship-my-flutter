import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

void main() {
  test('initializer creates tracked state and the complete workflow', () async {
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

    await initialize(InitOptions(root: root.path, bundleId: 'dev.example.app'));

    final manifest = await loadManifest(root.path);
    expect(manifest.ios.version, '3.2.1');
    expect(manifest.ios.baselineSha, baselineSha);
    expect(manifest.ios.pendingRelease, isFalse);
    final config = await loadConfig(root.path);
    expect(config.schemaVersion, 4);
    expect(config.appPath, '.');
    expect(config.ios.buildCommand, isNull);
    expect(config.ios.appStore.mode, ReleaseMode.upload);
    final configText = await File(
      resolveShipPaths(root.path).config,
    ).readAsString();
    expect(
      configText,
      contains(
        '# yaml-language-server: \$schema='
        'https://raw.githubusercontent.com/Ventairy/ship-my-flutter/main/'
        'schemas/config.schema.json',
      ),
    );
    expect(configText, isNot(contains('build_command:')));
    expect(configText, isNot(contains('ipa_output_path:')));
    expect(config.ios.ipaOutputPath, 'build/ios/ipa');
    expect(
      await File(
        p.join(root.path, '.ship-my-flutter', 'candidates', '.gitkeep'),
      ).exists(),
      isTrue,
    );
    final workflow = await File(
      p.join(root.path, '.github', 'workflows', 'ship-my-flutter.yml'),
    ).readAsString();
    expect(workflow, contains('Ventairy/ship-my-flutter-action@v1'));
    expect(workflow, contains('subosito/flutter-action@'));
    expect(workflow, contains("hashFiles('.fvmrc', '.fvm/fvm_config.json')"));
    expect(workflow, contains('dart pub global activate fvm 4.1.2'));
    expect(workflow, contains('runs-on: macos-26'));
    expect(
      RegExp('persist-credentials: false').allMatches(workflow),
      hasLength(3),
    );
  });
}
