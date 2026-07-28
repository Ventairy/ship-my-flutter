import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('initializer supports a CLI-only repository without a workflow', () async {
    final root = await Directory.systemTemp.createTemp('smf-init-manual-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: manual_app\nversion: 1.0.0+1\n');
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);

    await RepositoryInitializer.initialize(
      InitOptions(
        appRoot: root.path,
        iosBundleId: 'dev.example.manual',
        githubActions: false,
      ),
    );

    expect(
      await File(p.join(root.path, 'smf', 'config.yaml')).exists(),
      isTrue,
    );
    expect(
      await Directory(p.join(root.path, '.github', 'workflows')).exists(),
      isFalse,
    );
  });

  test(
    'initializer creates only configuration and the complete workflow',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-init-');
      addTearDown(() => root.delete(recursive: true));
      await Directory(p.join(root.path, 'ios')).create();
      await File(
        p.join(root.path, 'pubspec.yaml'),
      ).writeAsString('name: example\nversion: 3.2.1+42\n');
      await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
      await GitClient(root: root.path).run(const <String>['config', 'user.name', 'Test']);
      await GitClient(root: root.path).run(const <String>[
        'config',
        'user.email',
        'test@example.com',
      ]);
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>['commit', '-m', 'chore: bootstrap']);
      final baselineSha = await GitClient(root: root.path).currentSha();

      await RepositoryInitializer.initialize(
        InitOptions(appRoot: root.path, iosBundleId: 'dev.example.app'),
      );

      final manifest = await SmfState.manifest(root.path);
      expect(manifest.ios.version, '3.2.1');
      expect(manifest.ios.baselineSha, baselineSha);
      expect(manifest.ios.pendingRelease, isFalse);
      final config = await SmfState.config(root.path);
      expect(config.schemaVersion, 1);
      expect(config.appId, 'example');
      expect(config.ios.initialVersion, '3.2.1');
      expect(config.android.enabled, isFalse);
      expect(config.ios.buildCommand, isNull);
      expect(
        config.ios.appStore.releaseCandidate.target,
        AppleReleaseCandidateTarget.internalTesting,
      );
      expect(config.ios.appStore.ship, isNull);
      final configText = await File(
        SmfPaths.resolve(root.path).config,
      ).readAsString();
      expect(
        configText,
        contains(r'# yaml-language-server: $schema='),
      );
      expect(
        configText,
        contains(
          'https://raw.githubusercontent.com/Ventairy/smf/main/'
          'packages/smf_engine/schemas/config.schema.json',
        ),
      );
      expect(configText, isNot(contains('build_command:')));
      expect(configText, isNot(contains('ipa_output_path:')));
      expect(configText, isNot(contains('app_path:')));
      expect(configText, isNot(contains('hooks:')));
      expect(configText, isNot(contains('  android:')));
      expect(
        RegExp('initial_version:').allMatches(configText),
        hasLength(1),
      );
      expect(config.ios.ipaOutputPath, 'build/ios/ipa');
      final paths = SmfPaths.resolve(root.path);
      expect(await File(paths.manifest).exists(), isFalse);
      expect(await File(paths.changelog).exists(), isFalse);
      expect(await File(paths.storeReleaseNotes).exists(), isFalse);
      expect(await Directory(paths.candidates).exists(), isFalse);
      expect((await SmfState.changelog(root.path)).iosReleases, isEmpty);
      expect(await SmfState.storeReleaseNotes(root.path), isEmpty);
      final workflow = await File(
        p.join(root.path, '.github', 'workflows', 'smf-example.yml'),
      ).readAsString();
      expect(workflow, await File('templates/smf.yml').readAsString());
      expect(workflow, contains('SMF_PATH: "smf"'));
      expect(
        RegExp(r'smf-path: \$\{\{ env\.SMF_PATH \}\}').allMatches(workflow),
        hasLength(5),
      );
      expect(workflow, contains('Ventairy/smf-action@v1'));
      expect(
        workflow,
        contains('Ventairy/smf-action/resolve-project@v1'),
      );
      expect(
        workflow,
        contains('Ventairy/smf-action/setup-flutter@v1'),
      );
      expect(workflow, contains(r'include: ${{ fromJSON('));
      expect(workflow, contains(r'platform: ${{ matrix.platform }}'));
      expect(workflow, isNot(contains('find . -type f')));
      expect(workflow, contains("'macos-26' || 'ubuntu-latest'"));
      expect(workflow, contains('  pull_request:'));
      expect(workflow, contains('  release_candidate:'));
      expect(workflow, contains('  ship:'));
      expect(workflow, contains('phase: pull-request'));
      expect(workflow, contains('phase: release-candidate'));
      expect(workflow, contains('phase: ship'));
      expect(workflow, isNot(contains('IOS_PROVISIONING_PROFILES_BASE64')));
      expect(
        workflow,
        contains(
          r'ios-certificate-base64: ${{ secrets.SMF_IOS_CERTIFICATE_BASE64 }}',
        ),
      );
      expect(
        workflow,
        isNot(matches(RegExp(r'secrets\.(?!SMF_)'))),
      );
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
    await GitClient(root: repository.path).run(const <String>['init', '-b', 'main']);

    await RepositoryInitializer.initialize(InitOptions(appRoot: app.path));

    final configPath = p.join(app.path, 'smf', 'config.yaml');
    expect(await File(configPath).exists(), isTrue);
    expect(await File(configPath).readAsString(), isNot(contains('app_path')));
    expect(
      await File(
        p.join(repository.path, '.github', 'workflows', 'smf-mobile.yml'),
      ).exists(),
      isTrue,
    );
    final paths = SmfPaths.resolve(repository.path);
    expect(paths.appRoot, app.path);
    expect(paths.repositoryRoot, repository.path);
    final workflow = await File(
      p.join(repository.path, '.github', 'workflows', 'smf-mobile.yml'),
    ).readAsString();
    expect(workflow, contains('SMF_PATH: "apps/mobile/smf"'));
  });

  test('initializes independent workflows for multiple nested apps', () async {
    final repository = await Directory.systemTemp.createTemp('smf-init-');
    addTearDown(() => repository.delete(recursive: true));
    await GitClient(root: repository.path).run(const <String>['init', '-b', 'main']);
    for (final appId in <String>['customer', 'driver']) {
      final app = p.join(repository.path, 'apps', appId);
      await Directory(p.join(app, 'ios')).create(recursive: true);
      await File(
        p.join(app, 'pubspec.yaml'),
      ).writeAsString('name: $appId\nversion: 1.0.0+1\n');
      await RepositoryInitializer.initialize(InitOptions(appRoot: app));
    }

    for (final appId in <String>['customer', 'driver']) {
      final config = await SmfState.config(
        p.join(repository.path, 'apps', appId, 'smf'),
      );
      expect(config.appId, appId);
      final workflow = await File(
        p.join(
          repository.path,
          '.github',
          'workflows',
          'smf-$appId.yml',
        ),
      ).readAsString();
      expect(workflow, contains('name: SMF ($appId)'));
      expect(workflow, contains('environment: smf-$appId'));
      expect(
        workflow,
        contains('SMF_PATH: "apps/$appId/smf"'),
      );
    }
  });

  test('rejects an app ID already owned by another app', () async {
    final repository = await Directory.systemTemp.createTemp('smf-init-');
    addTearDown(() => repository.delete(recursive: true));
    await GitClient(root: repository.path).run(const <String>['init', '-b', 'main']);
    for (final app in <String>['customer', 'driver']) {
      final root = p.join(repository.path, 'apps', app);
      await Directory(p.join(root, 'ios')).create(recursive: true);
      await File(
        p.join(root, 'pubspec.yaml'),
      ).writeAsString('name: $app\nversion: 1.0.0+1\n');
    }
    await RepositoryInitializer.initialize(
      InitOptions(
        appRoot: p.join(repository.path, 'apps', 'customer'),
        appId: 'mobile',
      ),
    );

    await expectLater(
      RepositoryInitializer.initialize(
        InitOptions(
          appRoot: p.join(repository.path, 'apps', 'driver'),
          appId: 'mobile',
        ),
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'APP_ID_CONFLICT',
        ),
      ),
    );
  });

  test('does not change an initialized app ID through force', () async {
    final root = await Directory.systemTemp.createTemp('smf-init-');
    addTearDown(() => root.delete(recursive: true));
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: customer\nversion: 1.0.0+1\n');
    await RepositoryInitializer.initialize(InitOptions(appRoot: root.path));

    await expectLater(
      RepositoryInitializer.initialize(
        InitOptions(
          appRoot: root.path,
          appId: 'renamed',
          force: true,
        ),
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'APP_ID_IMMUTABLE',
        ),
      ),
    );
  });

  test('prefers detected platform versions over pubspec', () async {
    final root = await Directory.systemTemp.createTemp('smf-init-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'ios')).create();
    await Directory(p.join(root.path, 'android')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 9.0.0+1\n');
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);

    await RepositoryInitializer.initialize(
      InitOptions(
        appRoot: root.path,
        platformVersionDetectors: <Platform, Future<String?> Function(String appRoot)>{
          Platform.ios: (_) async => '2.4.0',
          Platform.android: (_) async => '3.1.2',
        },
      ),
    );

    final config = await SmfState.config(root.path);
    expect(config.ios.initialVersion, '2.4.0');
    expect(config.android.initialVersion, '3.1.2');
  });

  test('defaults an undetectable version to 0.0.0', () async {
    final root = await Directory.systemTemp.createTemp('smf-init-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: example\n');
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);

    await RepositoryInitializer.initialize(InitOptions(appRoot: root.path));

    expect((await SmfState.config(root.path)).ios.initialVersion, '0.0.0');
  });

  test('uses independent platform version baselines', () async {
    final root = await Directory.systemTemp.createTemp('smf-init-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'ios')).create();
    await Directory(p.join(root.path, 'android')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 9.0.0+1\n');
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);

    await RepositoryInitializer.initialize(
      InitOptions(
        appRoot: root.path,
        platformVersions: const <Platform, String>{
          Platform.ios: '2.4.0',
          Platform.android: '3.1.2',
        },
      ),
    );

    final config = await SmfState.config(root.path);
    expect(config.ios.initialVersion, '2.4.0');
    expect(config.android.initialVersion, '3.1.2');
  });

  test('rejects options for a platform the app does not contain', () async {
    final root = await Directory.systemTemp.createTemp('smf-init-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 1.0.0+1\n');
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);

    await expectLater(
      RepositoryInitializer.initialize(
        InitOptions(
          appRoot: root.path,
          platformVersions: const <Platform, String>{
            Platform.android: '2.0.0',
          },
        ),
      ),
      throwsA(
        isA<SmfError>()
            .having(
              (error) => error.code,
              'code',
              'UNSUPPORTED_INIT_PLATFORM',
            )
            .having(
              (error) => error.message,
              'message',
              contains('Android initializer options'),
            ),
      ),
    );
  });

  test('rejects a shared version with any platform override', () async {
    final root = await Directory.systemTemp.createTemp('smf-init-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 1.0.0+1\n');
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);

    await expectLater(
      RepositoryInitializer.initialize(
        InitOptions(
          appRoot: root.path,
          version: '1.0.0',
          platformVersions: const <Platform, String>{
            Platform.ios: '2.0.0',
          },
        ),
      ),
      throwsA(
        isA<SmfError>()
            .having(
              (error) => error.code,
              'code',
              'INVALID_INIT_OPTIONS',
            )
            .having(
              (error) => error.message,
              'message',
              contains('--version cannot be combined'),
            ),
      ),
    );
  });

  test('rejects a path that could inject a workflow expression', () async {
    final repository = await Directory.systemTemp.createTemp('smf-init-');
    addTearDown(() => repository.delete(recursive: true));
    final app = Directory(p.join(repository.path, r'apps/${{ unsafe }}'));
    await Directory(p.join(app.path, 'ios')).create(recursive: true);
    await File(
      p.join(app.path, 'pubspec.yaml'),
    ).writeAsString('name: mobile\nversion: 2.0.0+1\n');
    await GitClient(root: repository.path).run(const <String>['init', '-b', 'main']);

    await expectLater(
      RepositoryInitializer.initialize(InitOptions(appRoot: app.path)),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'INVALID_SMF_PATH',
        ),
      ),
    );
  });
}
