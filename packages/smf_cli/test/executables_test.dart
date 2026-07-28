import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_cli/src/executables.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('publishes one installed smf entrypoint', () async {
    final pubspec = loadYaml(await File('pubspec.yaml').readAsString()) as YamlMap;
    expect(pubspec['executables'], <Object?, Object?>{'smf': 'smf'});
    expect(await File('bin/smf.dart').exists(), isTrue);
  });

  test('CLI commands initialize and validate', () async {
    final root = await Directory.systemTemp.createTemp('smf-executable-');
    addTearDown(() => root.delete(recursive: true));
    final appRoot = p.join(root.path, 'apps', 'mobile');
    await Directory(p.join(appRoot, 'ios')).create(recursive: true);
    final iosProject = Directory(
      p.join(appRoot, 'ios', 'Runner.xcodeproj'),
    );
    await iosProject.create();
    await File(p.join(iosProject.path, 'project.pbxproj')).writeAsString(
      'MARKETING_VERSION = 2.0.0;\n',
    );
    await File(
      p.join(appRoot, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 1.0.0+1\n');
    await File(p.join(appRoot, 'pubspec.lock')).writeAsString('# lock\n');
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
    await GitClient(root: root.path).run(const <String>['config', 'user.name', 'Test']);
    await GitClient(root: root.path).run(const <String>[
      'config',
      'user.email',
      'test@example.com',
    ]);
    await GitClient(root: root.path).run(const <String>['add', '.']);
    await GitClient(root: root.path).run(const <String>['commit', '-m', 'chore: bootstrap']);

    final output = <Object?>[];
    final errors = <Object?>[];
    final io = ExecutableIo(
      environment: const <String, String>{},
      workingDirectory: root.path,
      writeOutput: output.add,
      writeError: errors.add,
    );
    expect(
      await SmfExecutable.runInit(const <String>[
        '--app-path',
        'apps/mobile',
        '--ios-bundle-id',
        'dev.example.app',
      ], io: io),
      0,
    );
    final initOutput = jsonDecode(output.removeLast()! as String) as Map<String, Object?>;
    expect(initOutput, containsPair('initialized', true));
    expect(initOutput, containsPair('appId', 'example'));
    final configPath = p.join(appRoot, 'smf', 'config.yaml');
    final config = '${await File(configPath).readAsString()}# preserved\n';
    await File(configPath).writeAsString(config);
    final workflowPath = p.join(
      root.path,
      '.github',
      'workflows',
      'smf-example.yml',
    );
    await File(workflowPath).writeAsString('stale workflow\n');
    expect(
      await SmfExecutable.runInit(const <String>[
        '--app-path',
        'apps/mobile',
        '--github-actions',
      ], io: io),
      0,
    );
    expect(
      jsonDecode(output.removeLast()! as String),
      containsPair('githubActionsCreated', true),
    );
    expect(await File(configPath).readAsString(), config);
    final workflowTemplate = await File(
      '../smf_engine/templates/smf.yml',
    ).readAsString();
    expect(
      await File(workflowPath).readAsString(),
      workflowTemplate.replaceFirst(
        'SMF_PATH: "smf"',
        'SMF_PATH: "apps/mobile/smf"',
      ),
    );
    await File(workflowPath).writeAsString('stale workflow\n');
    expect(
      await SmfExecutable.runMigrate(const <String>[
        '--smf-path',
        'apps/mobile/smf',
        '--github-actions',
      ], io: io),
      0,
    );
    expect(jsonDecode(output.removeLast()! as String), <String, Object?>{
      'migrated': true,
      'targets': <Object?>['githubActions'],
      'changedFiles': <Object?>['.github/workflows/smf-example.yml'],
    });
    expect(await File(configPath).readAsString(), config);
    await GitClient(root: root.path).run(const <String>['add', '.']);
    await GitClient(root: root.path).run(const <String>[
      'commit',
      '-m',
      'chore: configure releases',
    ]);

    expect(await SmfExecutable.runValidate(const <String>[], io: io), 0);
    expect(jsonDecode(output.removeLast()! as String), <String, Object?>{
      'valid': true,
    });

    expect(errors, isEmpty);
  });

  test(
    'does not expose the internal release planner as a CLI command',
    () async {
      final output = <Object?>[];
      final errors = <Object?>[];
      final io = ExecutableIo(
        environment: const <String, String>{},
        workingDirectory: Directory.current.path,
        writeOutput: output.add,
        writeError: errors.add,
      );

      expect(await SmfExecutable.run(const <String>['--help'], io: io), 0);
      expect(output.join('\n'), isNot(contains('plan')));
      expect(await SmfExecutable.run(const <String>['plan'], io: io), 64);
      expect(errors.join('\n'), contains('unknown command "plan"'));
    },
  );

  test('does not accept raw secrets as command-line options', () async {
    final errors = <Object?>[];
    final exitCode = await SmfExecutable.runOpenPullRequest(
      const <String>['--github-token', 'visible-secret'],
      io: ExecutableIo(
        environment: const <String, String>{},
        workingDirectory: Directory.current.path,
        writeOutput: (_) {},
        writeError: errors.add,
      ),
    );
    expect(exitCode, 64);
    expect(errors.join('\n'), isNot(contains('visible-secret')));
  });

  test('reports an outdated config without leaking a parallel error', () async {
    final root = await Directory.systemTemp.createTemp('smf-validate-');
    addTearDown(() => root.delete(recursive: true));
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
    await Directory(p.join(root.path, 'smf')).create();
    await File(p.join(root.path, 'smf', 'config.yaml')).writeAsString('''
schema_version: 1
platforms:
  ios:
    enabled: true
''');
    final errors = <Object?>[];

    final exitCode = await SmfExecutable.runValidate(
      const <String>[],
      io: ExecutableIo(
        environment: const <String, String>{},
        workingDirectory: root.path,
        writeOutput: (_) {},
        writeError: errors.add,
      ),
    );

    expect(exitCode, 1);
    expect(errors.join('\n'), contains('[INVALID_CONFIG]'));
    expect(errors.join('\n'), contains('run smf migrate'));
    expect(errors.join('\n'), isNot(contains('ParallelWaitError')));
  });

  test('rejects shared and platform-specific init versions together', () async {
    final errors = <Object?>[];
    final exitCode = await SmfExecutable.runInit(
      const <String>[
        '--version',
        '1.0.0',
        '--ios-version',
        '2.0.0',
      ],
      io: ExecutableIo(
        environment: const <String, String>{},
        workingDirectory: Directory.current.path,
        writeOutput: (_) {},
        writeError: errors.add,
      ),
    );

    expect(exitCode, 1);
    expect(errors.join('\n'), contains('[INVALID_INIT_OPTIONS]'));
    expect(errors.join('\n'), contains('--version cannot be combined'));
  });

  test('rejects an app path that escapes through a symbolic link', () async {
    final repository = await Directory.systemTemp.createTemp('smf-app-path-');
    final external = await Directory.systemTemp.createTemp('smf-app-path-');
    addTearDown(() async {
      await repository.delete(recursive: true);
      await external.delete(recursive: true);
    });
    await Directory(p.join(external.path, 'ios')).create();
    await File(
      p.join(external.path, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 1.0.0+1\n');
    await Link(
      p.join(repository.path, 'mobile'),
    ).create(external.path);
    final errors = <Object?>[];

    final exitCode = await SmfExecutable.runInit(
      const <String>['--app-path', 'mobile'],
      io: ExecutableIo(
        environment: const <String, String>{},
        workingDirectory: repository.path,
        writeOutput: (_) {},
        writeError: errors.add,
      ),
    );

    expect(exitCode, 1);
    expect(errors.join('\n'), contains('[INVALID_APP_PATH]'));
    expect(errors.join('\n'), contains('symbolic link'));
  });

  test(
    'prints executable-specific help without executing the operation',
    () async {
      final output = <Object?>[];
      final errors = <Object?>[];

      expect(
        await SmfExecutable.runInit(
          const <String>['--help'],
          io: ExecutableIo(
            environment: const <String, String>{},
            workingDirectory: Directory.current.path,
            writeOutput: output.add,
            writeError: errors.add,
          ),
        ),
        0,
      );
      expect(output.single, contains('Usage: smf init [options]'));
      expect(output.single, contains('--app-path'));
      expect(output.single, contains('--app-id'));
      expect(output.single, contains('--version'));
      expect(output.single, contains('--ios-version'));
      expect(output.single, contains('--android-version'));
      expect(output.single, contains('--ios-bundle-id'));
      expect(output.single, contains('--android-package-name'));
      expect(output.single, contains('--github-actions'));
      expect(output.single, isNot(contains('--current-version')));
      expect(output.single, isNot(contains('--bundle-id ')));
      expect(output.single, isNot(contains('--package-name ')));
      expect(output.single, isNot(contains('--workflow-only')));
      output.clear();

      expect(
        await SmfExecutable.runMigrate(
          const <String>['--help'],
          io: ExecutableIo(
            environment: const <String, String>{},
            workingDirectory: Directory.current.path,
            writeOutput: output.add,
            writeError: errors.add,
          ),
        ),
        0,
      );
      expect(output.single, contains('Usage: smf migrate [options]'));
      expect(output.single, contains('--config'));
      expect(output.single, contains('--github-actions'));
      expect(output.single, contains('--registry'));
      expect(errors, isEmpty);
    },
  );
}
