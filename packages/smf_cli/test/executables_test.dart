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

  test('initializes a CLI-only repository without a workflow', () async {
    final root = await Directory.systemTemp.createTemp('smf-cli-only-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: manual_app\nversion: 1.0.0+1\n');
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
    final output = <Object?>[];
    final errors = <Object?>[];

    expect(
      await SmfExecutable.runInit(
        const <String>[
          '--ios-bundle-id',
          'dev.example.manual',
          '--no-github-actions',
        ],
        io: ExecutableIo(
          environment: const <String, String>{},
          workingDirectory: root.path,
          writeOutput: output.add,
          writeError: errors.add,
        ),
      ),
      0,
    );

    expect(
      jsonDecode(output.single! as String),
      containsPair('initialized', true),
    );
    expect(await File(p.join(root.path, 'smf', 'config.yaml')).exists(), isTrue);
    expect(
      await Directory(p.join(root.path, '.github', 'workflows')).exists(),
      isFalse,
    );
    expect(errors, isEmpty);
  });

  test('create-release runs a pending candidate without an Action', () async {
    final root = await Directory.systemTemp.createTemp(
      'smf-manual-release-',
    );
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: manual_app\nversion: 1.0.0+1\n');
    await File(p.join(root.path, 'pubspec.lock')).writeAsString('# lock\n');
    final git = GitClient(root: root.path);
    await git.run(const <String>['init', '-b', 'main']);
    await git.run(const <String>['config', 'user.name', 'Test']);
    await git.run(const <String>['config', 'user.email', 'test@example.com']);
    await git.run(const <String>['add', '.']);
    await git.run(const <String>['commit', '-m', 'chore: bootstrap']);
    await RepositoryInitializer.initialize(
      InitOptions(
        appRoot: root.path,
        iosBundleId: 'dev.example.manual',
        githubActions: false,
      ),
    );
    await git.run(const <String>['add', '.']);
    await git.run(const <String>['commit', '-m', 'chore: configure releases']);
    await git.run(const <String>[
      'checkout',
      '-b',
      'smf/manual_app/release',
    ]);
    final sha = await git.currentSha();
    await ReleaseRegistry.apply(
      root: root.path,
      plan: ReleasePlan(
        platform: Platform.ios,
        currentVersion: '1.0.0',
        nextVersion: '1.1.0',
        versionBump: VersionBump.minor,
        baseSha: sha,
        headSha: sha,
        changes: <ConventionalChange>[
          ConventionalChange(
            sha: sha,
            type: 'feat',
            scope: 'ios',
            description: 'Manual release',
            body: null,
            breaking: false,
            versionBump: VersionBump.minor,
            platforms: const <Platform>[Platform.ios],
          ),
        ],
      ),
    );
    await git.run(const <String>['add', '.']);
    await git.run(
      const <String>['commit', '-m', 'chore(release): prepare iOS 1.1.0'],
    );
    final errors = <Object?>[];

    expect(
      await SmfExecutable.runCreateRelease(
        const <String>[],
        io: ExecutableIo(
          environment: const <String, String>{
            'GITHUB_REPOSITORY': 'example/manual_app',
            'GITHUB_TOKEN': 'token',
          },
          workingDirectory: root.path,
          writeOutput: (_) {},
          writeError: errors.add,
        ),
      ),
      1,
    );

    expect(errors.join('\n'), contains('[MISSING_CREDENTIAL]'));
    expect(
      errors.join('\n'),
      contains('SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64'),
    );
  });

  test('ship runs a merged pending release without an Action', () async {
    final root = await Directory.systemTemp.createTemp('smf-manual-ship-');
    final origin = await Directory.systemTemp.createTemp('smf-manual-origin-');
    addTearDown(() => root.delete(recursive: true));
    addTearDown(() => origin.delete(recursive: true));
    await GitClient(root: origin.path).run(
      const <String>['init', '--bare', '-b', 'main'],
    );
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: manual_app\nversion: 1.0.0+1\n');
    await File(p.join(root.path, 'pubspec.lock')).writeAsString('# lock\n');
    final git = GitClient(root: root.path);
    await git.run(const <String>['init', '-b', 'main']);
    await git.run(const <String>['config', 'user.name', 'Test']);
    await git.run(const <String>['config', 'user.email', 'test@example.com']);
    await git.run(const <String>['add', '.']);
    await git.run(const <String>['commit', '-m', 'chore: bootstrap']);
    await RepositoryInitializer.initialize(
      InitOptions(
        appRoot: root.path,
        iosBundleId: 'dev.example.manual',
        githubActions: false,
      ),
    );
    final configFile = File(p.join(root.path, 'smf', 'config.yaml'));
    await configFile.writeAsString(
      (await configFile.readAsString()).replaceFirst(
        'target_branch: main',
        'target_branch: stable',
      ),
    );
    await git.run(const <String>['add', '.']);
    await git.run(const <String>['commit', '-m', 'chore: configure releases']);
    final sha = await git.currentSha();
    await ReleaseRegistry.apply(
      root: root.path,
      plan: ReleasePlan(
        platform: Platform.ios,
        currentVersion: '1.0.0',
        nextVersion: '1.1.0',
        versionBump: VersionBump.minor,
        baseSha: sha,
        headSha: sha,
        changes: <ConventionalChange>[
          ConventionalChange(
            sha: sha,
            type: 'feat',
            scope: 'ios',
            description: 'Manual release',
            body: null,
            breaking: false,
            versionBump: VersionBump.minor,
            platforms: const <Platform>[Platform.ios],
          ),
        ],
      ),
    );
    await git.run(const <String>['add', '.']);
    await git.run(
      const <String>['commit', '-m', 'chore(release): merge iOS 1.1.0'],
    );
    await git.run(const <String>['branch', 'stable']);
    await git.run(<String>['remote', 'add', 'origin', origin.path]);
    await git.run(const <String>['push', '-u', 'origin', 'main', 'stable']);

    final remoteManifest = await SmfState.manifest(
      p.join(root.path, 'smf'),
    );
    await SmfFileSystem.writeJson(
      p.join(root.path, 'smf', 'manifest.json'),
      remoteManifest
          .copyWith(
            ios: remoteManifest.ios.copyWith(pendingRelease: false),
          )
          .toJson(),
    );
    await git.run(<String>[
      'tag',
      ReleaseReference.tag('manual_app', Platform.ios, '1.1.0'),
    ]);
    final errors = <Object?>[];

    expect(
      await SmfExecutable.runShip(
        const <String>[],
        io: ExecutableIo(
          environment: const <String, String>{
            'GITHUB_REPOSITORY': 'example/manual_app',
            'GITHUB_TOKEN': 'token',
          },
          workingDirectory: root.path,
          writeOutput: (_) {},
          writeError: errors.add,
        ),
      ),
      1,
    );

    expect(errors.join('\n'), contains('[MISSING_CREDENTIAL]'));
    expect(
      errors.join('\n'),
      contains('SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64'),
    );
    expect(
      await SmfState.manifest(
        p.join(root.path, 'smf'),
      ).then((manifest) => manifest.ios.pendingRelease),
      isFalse,
      reason: 'ship must not replace or read the caller checkout state',
    );
    errors.clear();

    expect(
      await SmfExecutable.runAction(
        const <String>['--phase', 'ship', '--platform', 'ios'],
        io: ExecutableIo(
          environment: const <String, String>{
            'GITHUB_REPOSITORY': 'example/manual_app',
            'GITHUB_TOKEN': 'token',
          },
          workingDirectory: root.path,
          writeOutput: (_) {},
          writeError: errors.add,
        ),
      ),
      1,
    );
    expect(
      errors.join('\n'),
      contains('SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64'),
      reason: 'the Action ship phase must use the same remote-only state',
    );

    final releaseTag = ReleaseReference.tag(
      'manual_app',
      Platform.ios,
      '1.1.0',
    );
    await git.run(<String>['push', 'origin', 'refs/tags/$releaseTag']);
    await git.run(<String>['tag', '--delete', releaseTag]);
    errors.clear();

    expect(
      await SmfExecutable.runShip(
        const <String>[],
        io: ExecutableIo(
          environment: const <String, String>{
            'GITHUB_REPOSITORY': 'example/manual_app',
            'GITHUB_TOKEN': 'token',
          },
          workingDirectory: root.path,
          writeOutput: (_) {},
          writeError: errors.add,
        ),
      ),
      1,
    );
    expect(errors.join('\n'), contains('[NO_RELEASE_TO_SHIP]'));
    expect(
      errors.join('\n'),
      contains('remote stable branch'),
      reason: 'the remote tag must win even when the local tag is absent',
    );
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

  test('keeps every top-level command description on the command line', () async {
    final output = <Object?>[];
    final errors = <Object?>[];

    expect(
      await SmfExecutable.run(
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

    final help = output.single! as String;
    for (final command in <String>[
      'init',
      'migrate',
      'validate',
      'create-release',
      'ship',
    ]) {
      expect(
        help,
        matches(RegExp('^  ${RegExp.escape(command)}  +\\S', multiLine: true)),
        reason: '$command must keep its description on the same line',
      );
    }
    expect(errors, isEmpty);
  });

  test('does not accept raw secrets as command-line options', () async {
    final errors = <Object?>[];
    final exitCode = await SmfExecutable.runCreateRelease(
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

  test(
    'create-release infers the repository from Git origin and accepts an override',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'smf-create-release-',
      );
      addTearDown(() => root.delete(recursive: true));
      await GitClient(root: root.path).run(
        const <String>['init', '-b', 'main'],
      );
      await Directory(p.join(root.path, 'smf')).create();
      await File(p.join(root.path, 'smf', 'config.yaml')).writeAsString('''
schema_version: 3
app_id: "example"
target_branch: production
platforms:
  ios:
    enabled: true
''');
      await GitClient(root: root.path).run(
        const <String>['config', 'user.name', 'Test'],
      );
      await GitClient(root: root.path).run(
        const <String>['config', 'user.email', 'test@example.com'],
      );
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(
        const <String>['commit', '-m', 'chore: initialize'],
      );
      final output = <Object?>[];
      final errors = <Object?>[];
      final io = ExecutableIo(
        environment: const <String, String>{'GITHUB_TOKEN': 'token'},
        workingDirectory: root.path,
        writeOutput: output.add,
        writeError: errors.add,
      );

      expect(await SmfExecutable.runCreateRelease(const <String>[], io: io), 1);
      expect(
        errors.removeLast(),
        contains('Pass --repository owner/name'),
      );

      expect(
        await SmfExecutable.runCreateRelease(
          const <String>['--repository', 'Override/example'],
          io: io,
        ),
        0,
      );
      expect(
        jsonDecode(output.removeLast()! as String),
        containsPair('phase', 'noop'),
      );

      await GitClient(root: root.path).run(const <String>[
        'remote',
        'add',
        'origin',
        'git@github.com:Ventairy/example.git',
      ]);
      expect(await SmfExecutable.runCreateRelease(const <String>[], io: io), 0);
      expect(
        jsonDecode(output.removeLast()! as String),
        containsPair('phase', 'noop'),
      );

      await GitClient(root: root.path).run(const <String>[
        'remote',
        'set-url',
        'origin',
        'https://github.com/Ventairy/example.git',
      ]);
      expect(await SmfExecutable.runCreateRelease(const <String>[], io: io), 0);
      expect(
        jsonDecode(output.removeLast()! as String),
        containsPair('phase', 'noop'),
      );
    },
  );

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
      expect(output.single, contains('--no-github-actions'));
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
      expect(
        output.single,
        contains('Update SMF files created by an older CLI'),
      );
      expect(output.single, contains('Install the newer SMF CLI first'));
      expect(output.single, contains('--config'));
      expect(output.single, contains('--github-actions'));
      expect(output.single, contains('--registry'));
      output.clear();

      expect(
        await SmfExecutable.runCreateRelease(
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
      expect(output.single, contains('--platform=<ios|android>'));
      expect(output.single, contains('--prepare-only'));
      expect(errors, isEmpty);
    },
  );

  test('documents every visible CLI option in command help', () async {
    final commands = <String>[
      'init',
      'migrate',
      'validate',
      'create-release',
      'ship',
    ];

    for (final command in commands) {
      final output = <Object?>[];
      final errors = <Object?>[];
      final exitCode = await SmfExecutable.run(
        <String>[command, '--help'],
        io: ExecutableIo(
          environment: const <String, String>{},
          workingDirectory: Directory.current.path,
          writeOutput: output.add,
          writeError: errors.add,
        ),
      );

      expect(exitCode, 0, reason: command);
      expect(errors, isEmpty, reason: command);
      final help = output.single! as String;
      final optionLines = help
          .split('\n')
          .where(
            (line) => line.trimLeft().startsWith('-h,') || line.trimLeft().startsWith('--'),
          );
      expect(optionLines, isNotEmpty, reason: command);
      for (final line in optionLines) {
        expect(
          line,
          matches(RegExp(r'^\s*(?:-\w,\s+)?--\S+\s{2,}\S')),
          reason: '$command has an undocumented option: $line',
        );
      }
    }
  });

  test('rejects removed release and candidate command names', () async {
    for (final command in <String>[
      'open-pr',
      'release',
      'candidate',
      'testflight',
      'internal-testing',
      'promote',
      'app-store',
      'google-play',
    ]) {
      final errors = <Object?>[];

      expect(
        await SmfExecutable.run(
          <String>[command],
          io: ExecutableIo(
            environment: const <String, String>{},
            workingDirectory: Directory.current.path,
            writeOutput: (_) {},
            writeError: errors.add,
          ),
        ),
        64,
        reason: command,
      );
      expect(
        errors.join('\n'),
        contains('unknown command "$command"'),
        reason: command,
      );
    }
  });
}
