import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_cli/src/executables.dart';
import 'package:smf_cli/src/upgrade.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

Future<void> _initializeValidationApp(
  String repositoryRoot,
  String appName,
) async {
  final appRoot = p.join(repositoryRoot, 'apps', appName);
  await Directory(p.join(appRoot, 'ios')).create(recursive: true);
  await File(
    p.join(appRoot, 'ios', '.gitkeep'),
  ).writeAsString('');
  await File(p.join(appRoot, 'pubspec.yaml')).writeAsString(
    'name: $appName\nversion: 1.0.0+1\n',
  );
  await RepositoryInitializer.initialize(
    InitOptions(
      appRoot: appRoot,
      appId: appName,
      iosBundleId: 'dev.example.$appName',
      shouldCreateGitHubActions: false,
    ),
  );
}

void main() {
  test('publishes one installed smf entrypoint', () async {
    final pubspec = loadYaml(await File('pubspec.yaml').readAsString()) as YamlMap;
    expect(pubspec['executables'], <Object?, Object?>{'smf': 'smf'});
    expect(await File('bin/smf.dart').exists(), isTrue);
  });

  test('when version is requested, it should print the installed version', () async {
    for (final flag in const <String>['--version', '-V']) {
      final output = <Object?>[];
      final errors = <Object?>[];

      expect(
        await SmfExecutable.run(
          <String>[flag],
          io: ExecutableIo(
            environment: const <String, String>{},
            workingDirectory: Directory.current.path,
            writeOutput: output.add,
            writeError: errors.add,
          ),
        ),
        0,
      );
      expect(output, <Object?>[smfCliVersion]);
      expect(errors, isEmpty);
    }
  });

  test('upgrade is documented and installs a newer CLI', () async {
    final output = <Object?>[];
    final errors = <Object?>[];
    final io = ExecutableIo(
      environment: const <String, String>{},
      workingDirectory: Directory.current.path,
      writeOutput: output.add,
      writeError: errors.add,
      upgradeService: SmfUpgradeService(
        latestVersionLoader: () async => '2.0.0',
        installer: (_, _) async => ProcessResult(1, 0, '', ''),
      ),
    );

    expect(await SmfExecutable.run(const <String>['--help'], io: io), 0);
    final topLevelHelp = output.removeLast();
    expect(topLevelHelp, contains('upgrade'));
    expect(topLevelHelp, contains('--version'));
    expect(
      await SmfExecutable.run(
        const <String>['upgrade', '--help'],
        io: io,
      ),
      0,
    );
    expect(output.removeLast(), contains('Usage: smf upgrade [options]'));
    expect(
      output.singleOrNull,
      isNull,
    );
    expect(await SmfExecutable.runUpgrade(const <String>[], io: io), 0);
    expect(
      jsonDecode(output.single! as String),
      containsPair('version', '2.0.0'),
    );
    expect(errors, isEmpty);
  });

  test('prints an advisory update notice only outside CI', () async {
    var checks = 0;
    final output = <Object?>[];
    final errors = <Object?>[];
    SmfUpgradeService service() => SmfUpgradeService(
      latestVersionLoader: () async {
        checks += 1;
        return '2.0.0';
      },
      installer: (_, _) async => ProcessResult(1, 0, '', ''),
    );

    expect(
      await SmfExecutable.run(
        const <String>['--help'],
        io: ExecutableIo(
          environment: const <String, String>{},
          workingDirectory: Directory.current.path,
          writeOutput: output.add,
          writeError: errors.add,
          upgradeService: service(),
          shouldCheckForUpdates: true,
        ),
      ),
      0,
    );
    expect(checks, 1);
    expect(
      errors.single,
      'SMF 2.0.0 is available; this installation is $smfCliVersion. '
      'Run `smf upgrade` to update.',
    );

    for (final environment in const <Map<String, String>>[
      <String, String>{'CI': 'true'},
      <String, String>{'SMF_NO_UPDATE_CHECK': 'true'},
    ]) {
      errors.clear();
      expect(
        await SmfExecutable.run(
          const <String>['--help'],
          io: ExecutableIo(
            environment: environment,
            workingDirectory: Directory.current.path,
            writeOutput: output.add,
            writeError: errors.add,
            upgradeService: service(),
            shouldCheckForUpdates: true,
          ),
        ),
        0,
      );
      expect(checks, 1);
      expect(errors, isEmpty);
    }
  });

  test('CLI commands initialize and validate', () async {
    final root = await Directory.systemTemp.createTemp('smf-executable-');
    addTearDown(() => root.delete(recursive: true));
    final appRoot = p.join(root.path, 'apps', 'mobile');
    await Directory(p.join(appRoot, 'ios')).create(recursive: true);
    await Directory(p.join(appRoot, 'android')).create();
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
        '--platform',
        'ios',
        '--ios-bundle-id',
        'dev.example.app',
      ], io: io),
      0,
    );
    final initOutput = jsonDecode(output.removeLast()! as String) as Map<String, Object?>;
    expect(initOutput, containsPair('isInitialized', true));
    expect(initOutput, containsPair('appId', 'example'));
    final initializedConfig = await SmfState.config(
      p.join(appRoot, 'smf'),
    );
    expect(
      (
        isIosEnabled: initializedConfig.ios.isEnabled,
        isAndroidEnabled: initializedConfig.android.isEnabled,
      ),
      (isIosEnabled: true, isAndroidEnabled: false),
    );
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
      containsPair('isGitHubActionsWorkflowCreated', true),
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
    await GitClient(root: root.path).run(const <String>['add', '.']);
    await GitClient(root: root.path).run(const <String>[
      'commit',
      '-m',
      'chore: configure releases',
    ]);

    expect(await SmfExecutable.runValidate(const <String>[], io: io), 0);
    expect(jsonDecode(output.removeLast()! as String), <String, Object?>{
      'isValid': true,
      'smfPaths': <Object?>['apps/mobile/smf'],
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
      containsPair('isInitialized', true),
    );
    expect(await File(p.join(root.path, 'smf', 'config.yaml')).exists(), isTrue);
    expect(
      await Directory(p.join(root.path, '.github', 'workflows')).exists(),
      isFalse,
    );
    expect(errors, isEmpty);
  });

  test('release-candidate runs a pending release candidate without an Action', () async {
    final root = await Directory.systemTemp.createTemp(
      'smf-manual-release-',
    );
    final origin = await Directory.systemTemp.createTemp(
      'smf-manual-origin-',
    );
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
        shouldCreateGitHubActions: false,
      ),
    );
    await git.run(const <String>['add', '.']);
    await git.run(const <String>['commit', '-m', 'chore: configure releases']);
    await git.run(<String>['remote', 'add', 'origin', origin.path]);
    await git.run(const <String>['push', '-u', 'origin', 'main']);
    await git.run(const <String>[
      'checkout',
      '-b',
      'smf/manual_app/release',
    ]);
    final commitHash = await git.currentCommitHash();
    await ReleaseRegistry.apply(
      root: root.path,
      gitHubToken: 'github-token',
      plan: ReleasePlanDto(
        platform: ReleasePlatform.ios,
        currentVersion: '1.0.0',
        nextVersion: '1.1.0',
        versionBumpType: VersionBumpType.minor,
        baseCommitHash: commitHash,
        endCommitHash: commitHash,
        changes: <ConventionalChangeDto>[
          ConventionalChangeDto(
            commitHash: commitHash,
            type: 'feat',
            scope: 'ios',
            description: 'Manual release',
            body: null,
            isBreaking: false,
            versionBumpType: VersionBumpType.minor,
            platforms: const <ReleasePlatform>[ReleasePlatform.ios],
          ),
        ],
      ),
    );
    await git.run(const <String>['add', '.']);
    await git.run(
      const <String>['commit', '-m', 'chore(release): prepare iOS 1.1.0'],
    );
    await git.run(const <String>[
      'push',
      '-u',
      'origin',
      'smf/manual_app/release',
    ]);
    await git.run(const <String>['switch', 'main']);
    final errors = <Object?>[];

    expect(
      await SmfExecutable.runRelease(
        <String>[
          '--phase',
          'release-candidate',
          '--app-store-connect-auth-key-base64',
          base64Encode(utf8.encode('private-key')),
          '--app-store-connect-key-id',
          'KEY123',
        ],
        io: ExecutableIo(
          environment: const <String, String>{
            'SMF_GITHUB_REPOSITORY': 'example/manual_app',
            'SMF_GITHUB_TOKEN': 'token',
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
      allOf(
        contains('--app-store-connect-issuer-id'),
        contains('SMF_APP_STORE_CONNECT_ISSUER_ID'),
      ),
    );
    errors.clear();
    expect(
      await SmfExecutable.runRelease(
        const <String>[
          '--phase',
          'release-candidate',
          '--platform',
          'android',
        ],
        io: ExecutableIo(
          environment: const <String, String>{
            'SMF_GITHUB_REPOSITORY': 'example/manual_app',
            'SMF_GITHUB_TOKEN': 'token',
          },
          workingDirectory: root.path,
          writeOutput: (_) {},
          writeError: errors.add,
        ),
      ),
      1,
    );
    expect(errors.single, contains('[NO_RELEASE_CANDIDATE]'));
    expect(await git.currentBranch(), 'main');
  });

  test('ship phase runs a merged pending release without an Action', () async {
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
        shouldCreateGitHubActions: false,
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
    await git.run(<String>['remote', 'add', 'origin', origin.path]);
    final commitHash = await git.currentCommitHash();
    await ReleaseRegistry.apply(
      root: root.path,
      gitHubToken: 'github-token',
      plan: ReleasePlanDto(
        platform: ReleasePlatform.ios,
        currentVersion: '1.0.0',
        nextVersion: '1.1.0',
        versionBumpType: VersionBumpType.minor,
        baseCommitHash: commitHash,
        endCommitHash: commitHash,
        changes: <ConventionalChangeDto>[
          ConventionalChangeDto(
            commitHash: commitHash,
            type: 'feat',
            scope: 'ios',
            description: 'Manual release',
            body: null,
            isBreaking: false,
            versionBumpType: VersionBumpType.minor,
            platforms: const <ReleasePlatform>[ReleasePlatform.ios],
          ),
        ],
      ),
    );
    await git.run(const <String>['add', '.']);
    await git.run(
      const <String>['commit', '-m', 'chore(release): merge iOS 1.1.0'],
    );
    await git.run(const <String>['branch', 'stable']);
    await git.run(const <String>['push', '-u', 'origin', 'main', 'stable']);

    final remoteManifest = await SmfState.manifest(
      p.join(root.path, 'smf'),
    );
    await JsonFile(
      p.join(root.path, 'smf', 'manifest.json'),
    ).write(
      remoteManifest
          .copyWith(
            platforms: remoteManifest.platforms.copyWith(
              ios: remoteManifest.platforms.ios.copyWith(
                isReleasePending: false,
              ),
            ),
          )
          .toJson(),
    );
    await git.run(<String>[
      'tag',
      ReleaseReference.tag('manual_app', ReleasePlatform.ios, '1.1.0'),
    ]);
    final errors = <Object?>[];

    expect(
      await SmfExecutable.runRelease(
        const <String>['--phase', 'ship'],
        io: ExecutableIo(
          environment: const <String, String>{
            'SMF_GITHUB_REPOSITORY': 'example/manual_app',
            'SMF_GITHUB_TOKEN': 'token',
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
      ).then((manifest) => manifest.platforms.ios.isReleasePending),
      isFalse,
      reason: 'ship must not replace or read the caller checkout state',
    );
    errors.clear();

    expect(
      await SmfExecutable.runRelease(
        const <String>['--phase', 'ship', '--platform', 'ios'],
        io: ExecutableIo(
          environment: const <String, String>{
            'SMF_GITHUB_REPOSITORY': 'example/manual_app',
            'SMF_GITHUB_TOKEN': 'token',
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
      ReleasePlatform.ios,
      '1.1.0',
    );
    await git.run(<String>['push', 'origin', 'refs/tags/$releaseTag']);
    await git.run(<String>['tag', '--delete', releaseTag]);
    errors.clear();

    expect(
      await SmfExecutable.runRelease(
        const <String>['--phase', 'ship'],
        io: ExecutableIo(
          environment: const <String, String>{
            'SMF_GITHUB_REPOSITORY': 'example/manual_app',
            'SMF_GITHUB_TOKEN': 'token',
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
    for (final command in <String>['init', 'release', 'upgrade', 'validate']) {
      expect(
        help,
        matches(RegExp('^  ${RegExp.escape(command)}  +\\S', multiLine: true)),
        reason: '$command must keep its description on the same line',
      );
    }
    expect(errors, isEmpty);
  });

  test('accepts a direct GitHub token without echoing it', () async {
    final errors = <Object?>[];
    final exitCode = await SmfExecutable.runRelease(
      const <String>[
        '--phase',
        'pull-request',
        '--github-token',
        'visible-secret',
        '--repository',
        'example/repository',
      ],
      io: ExecutableIo(
        environment: const <String, String>{},
        workingDirectory: Directory.current.path,
        writeOutput: (_) {},
        writeError: errors.add,
      ),
    );
    expect(exitCode, 1);
    expect(errors.join('\n'), isNot(contains('visible-secret')));

    errors.clear();
    expect(
      await SmfExecutable.runRelease(
        const <String>[
          '--phase',
          'pull-request',
          '--github-token',
          'argument-secret',
          '--repository',
          'example/repository',
        ],
        io: ExecutableIo(
          environment: const <String, String>{
            'SMF_GITHUB_TOKEN': 'environment-secret',
          },
          workingDirectory: Directory.current.path,
          writeOutput: (_) {},
          writeError: errors.add,
        ),
      ),
      1,
    );
    expect(errors.single, contains('[CONFLICTING_CREDENTIAL]'));
    expect(errors.single, isNot(contains('argument-secret')));
    expect(errors.single, isNot(contains('environment-secret')));
  });

  test(
    'pull-request infers the repository from Git origin and accepts an override',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'smf-create-release-',
      );
      final origin = await Directory.systemTemp.createTemp(
        'smf-create-release-origin-',
      );
      addTearDown(() => root.delete(recursive: true));
      addTearDown(() => origin.delete(recursive: true));
      await GitClient(root: origin.path).run(
        const <String>['init', '--bare', '-b', 'main'],
      );
      await GitClient(root: root.path).run(
        const <String>['init', '-b', 'main'],
      );
      await Directory(p.join(root.path, 'smf')).create();
      await File(p.join(root.path, 'smf', 'config.yaml')).writeAsString('''
schema_version: 1
app_id: "example"
target_branch: main
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
      expect(
        await SmfExecutable.runRelease(
          const <String>[
            '--phase',
            'pull-request',
            '--repository',
            'example/repository',
          ],
          io: ExecutableIo(
            environment: const <String, String>{
              'GITHUB_TOKEN': 'ignored',
              'INPUT_GITHUB_TOKEN': 'ignored',
            },
            workingDirectory: root.path,
            writeOutput: output.add,
            writeError: errors.add,
          ),
        ),
        1,
      );
      expect(
        errors.removeLast(),
        allOf(contains('--github-token'), contains('SMF_GITHUB_TOKEN')),
      );

      final io = ExecutableIo(
        environment: const <String, String>{'SMF_GITHUB_TOKEN': 'token'},
        workingDirectory: root.path,
        writeOutput: output.add,
        writeError: errors.add,
      );

      expect(
        await SmfExecutable.runRelease(
          const <String>['--phase', 'pull-request'],
          io: io,
        ),
        1,
      );
      expect(
        errors.removeLast(),
        contains('Pass --repository owner/name'),
      );

      await GitClient(root: root.path).run(<String>[
        'remote',
        'add',
        'origin',
        origin.path,
      ]);
      await GitClient(root: root.path).run(
        const <String>['push', '-u', 'origin', 'main'],
      );
      expect(
        await SmfExecutable.runRelease(
          const <String>[
            '--phase',
            'pull-request',
            '--platform',
            'android',
            '--repository',
            'Override/example',
          ],
          io: io,
        ),
        0,
      );
      expect(
        jsonDecode(output.removeLast()! as String),
        containsPair('nextPhase', 'noop'),
      );

      await GitClient(root: root.path).run(<String>[
        'config',
        'url.${origin.path}.insteadOf',
        'git@github.com:Ventairy/example.git',
      ]);
      await GitClient(root: root.path).run(const <String>[
        'remote',
        'set-url',
        'origin',
        'git@github.com:Ventairy/example.git',
      ]);
      expect(
        await SmfExecutable.runRelease(
          const <String>[
            '--phase',
            'pull-request',
            '--platform',
            'android',
          ],
          io: io,
        ),
        0,
      );
      expect(
        jsonDecode(output.removeLast()! as String),
        containsPair('nextPhase', 'noop'),
      );

      await GitClient(root: root.path).run(const <String>[
        'remote',
        'set-url',
        'origin',
        'https://github.com/Ventairy/example.git',
      ]);
      await GitClient(root: root.path).run(<String>[
        'config',
        '--add',
        'url.${origin.path}.insteadOf',
        'https://github.com/Ventairy/example.git',
      ]);
      expect(
        await SmfExecutable.runRelease(
          const <String>[
            '--phase',
            'pull-request',
            '--platform',
            'android',
          ],
          io: io,
        ),
        0,
      );
      expect(
        jsonDecode(output.removeLast()! as String),
        containsPair('nextPhase', 'noop'),
      );
    },
  );

  test(
    'when release runs below the repository root, it should resolve the selected app from the root',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'smf-release-path-',
      );
      final origin = await Directory.systemTemp.createTemp(
        'smf-release-path-origin-',
      );
      addTearDown(() => root.delete(recursive: true));
      addTearDown(() => origin.delete(recursive: true));
      await GitClient(root: origin.path).run(
        const <String>['init', '--bare', '-b', 'main'],
      );
      final git = GitClient(root: root.path);
      await git.run(const <String>['init', '-b', 'main']);
      await git.run(const <String>[
        'config',
        'user.name',
        'Test',
      ]);
      await git.run(const <String>[
        'config',
        'user.email',
        'test@example.com',
      ]);
      await File(
        p.join(root.path, 'README.md'),
      ).writeAsString('fixture\n');
      await File(
        p.join(root.path, 'pubspec.lock'),
      ).writeAsString('# fixture\n');
      await git.run(const <String>['add', '.']);
      await git.run(const <String>[
        'commit',
        '-m',
        'chore: bootstrap',
      ]);
      await _initializeValidationApp(root.path, 'customer');
      await _initializeValidationApp(root.path, 'driver');
      final nestedDirectory = p.join(
        root.path,
        'apps',
        'driver',
        'lib',
      );
      await Directory(nestedDirectory).create();
      await git.run(const <String>['add', '.']);
      await git.run(const <String>[
        'commit',
        '-m',
        'chore: configure releases',
      ]);
      await git.run(<String>['remote', 'add', 'origin', origin.path]);
      await git.run(const <String>['push', '-u', 'origin', 'main']);
      final output = <Object?>[];
      final errors = <Object?>[];

      final exitCode = await SmfExecutable.runRelease(
        const <String>[
          '--phase',
          'pull-request',
          '--smf-path',
          'apps/customer/smf',
          '--repository',
          'example/repository',
        ],
        io: ExecutableIo(
          environment: const <String, String>{
            'SMF_GITHUB_TOKEN': 'token',
          },
          workingDirectory: nestedDirectory,
          writeOutput: output.add,
          writeError: errors.add,
        ),
      );

      expect(
        (
          exitCode: exitCode,
          nextPhase: output.isEmpty
              ? null
              : (jsonDecode(output.single! as String) as Map<String, Object?>)['nextPhase'],
          errors: errors.join('\n'),
        ),
        (exitCode: 0, nextPhase: 'noop', errors: ''),
      );
    },
  );

  test(
    'when pull-request runs from a dirty divergent checkout, it should plan only the remote target branch',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'smf-remote-pull-request-',
      );
      final origin = await Directory.systemTemp.createTemp(
        'smf-remote-pull-request-origin-',
      );
      addTearDown(() => root.delete(recursive: true));
      addTearDown(() => origin.delete(recursive: true));
      await GitClient(root: origin.path).run(
        const <String>['init', '--bare', '-b', 'main'],
      );
      await Directory(p.join(root.path, 'ios')).create();
      await File(
        p.join(root.path, 'ios', '.gitkeep'),
      ).writeAsString('');
      await File(
        p.join(root.path, 'pubspec.yaml'),
      ).writeAsString('name: remote_app\nversion: 1.0.0+1\n');
      await File(
        p.join(root.path, 'pubspec.lock'),
      ).writeAsString('# fixture\n');
      final git = GitClient(root: root.path);
      await git.run(const <String>['init', '-b', 'main']);
      await git.run(const <String>['config', 'user.name', 'Test']);
      await git.run(
        const <String>['config', 'user.email', 'test@example.com'],
      );
      await git.run(const <String>['add', '.']);
      await git.run(const <String>['commit', '-m', 'chore: bootstrap']);
      await RepositoryInitializer.initialize(
        InitOptions(
          appRoot: root.path,
          iosBundleId: 'dev.example.remote',
          shouldCreateGitHubActions: false,
        ),
      );
      await git.run(const <String>['add', '.']);
      await git.run(
        const <String>['commit', '-m', 'chore: configure releases'],
      );
      await git.run(<String>['remote', 'add', 'origin', origin.path]);
      await git.run(const <String>['push', '-u', 'origin', 'main']);
      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('const releasedLocallyOnly = true;\n');
      await git.run(const <String>['add', 'lib.dart']);
      await git.run(
        const <String>['commit', '-m', 'feat: local-only feature'],
      );
      await File(
        p.join(root.path, 'local-notes.txt'),
      ).writeAsString('not committed\n');
      final output = <Object?>[];
      final errors = <Object?>[];

      final exitCode = await SmfExecutable.runRelease(
        const <String>[
          '--phase',
          'pull-request',
          '--repository',
          'example/remote_app',
        ],
        io: ExecutableIo(
          environment: const <String, String>{
            'SMF_GITHUB_TOKEN': 'token',
          },
          workingDirectory: root.path,
          writeOutput: output.add,
          writeError: errors.add,
        ),
      );

      expect(
        (
          exitCode: exitCode,
          nextPhase: output.isEmpty
              ? null
              : (jsonDecode(output.single! as String) as Map<String, Object?>)['nextPhase'],
          branch: await git.currentBranch(),
          clean: await git.isClean(),
          errors: errors.join('\n'),
        ),
        (
          exitCode: 0,
          nextPhase: 'noop',
          branch: 'main',
          clean: false,
          errors: '',
        ),
      );
    },
  );

  test(
    'when the target is not the default branch, it should read only the remote target configuration',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'smf-non-default-target-',
      );
      final origin = await Directory.systemTemp.createTemp(
        'smf-non-default-target-origin-',
      );
      addTearDown(() => root.delete(recursive: true));
      addTearDown(() => origin.delete(recursive: true));
      await GitClient(root: origin.path).run(
        const <String>['init', '--bare', '-b', 'main'],
      );
      await Directory(p.join(root.path, 'ios')).create();
      await File(
        p.join(root.path, 'ios', '.gitkeep'),
      ).writeAsString('');
      await File(
        p.join(root.path, 'pubspec.yaml'),
      ).writeAsString('name: remote_app\nversion: 1.0.0+1\n');
      await File(
        p.join(root.path, 'pubspec.lock'),
      ).writeAsString('# fixture\n');
      final git = GitClient(root: root.path);
      await git.run(const <String>['init', '-b', 'main']);
      await git.run(const <String>['config', 'user.name', 'Test']);
      await git.run(
        const <String>['config', 'user.email', 'test@example.com'],
      );
      await git.run(const <String>['add', '.']);
      await git.run(const <String>['commit', '-m', 'chore: bootstrap']);
      await RepositoryInitializer.initialize(
        InitOptions(
          appRoot: root.path,
          iosBundleId: 'dev.example.remote',
          shouldCreateGitHubActions: false,
        ),
      );
      await git.run(const <String>['add', '.']);
      await git.run(
        const <String>['commit', '-m', 'chore: configure releases'],
      );
      await git.run(<String>['remote', 'add', 'origin', origin.path]);
      await git.run(const <String>['push', '-u', 'origin', 'main']);

      await git.run(const <String>['switch', '-c', 'release-target']);
      final configFile = File(p.join(root.path, 'smf', 'config.yaml'));
      await configFile.writeAsString(
        (await configFile.readAsString()).replaceFirst(
          'target_branch: main',
          'target_branch: release-target',
        ),
      );
      await git.run(const <String>['add', 'smf/config.yaml']);
      await git.run(
        const <String>['commit', '-m', 'chore: target release branch'],
      );
      await git.run(
        const <String>['push', '-u', 'origin', 'release-target'],
      );

      await git.run(const <String>['switch', 'main']);
      await configFile.writeAsString(
        (await configFile.readAsString()).replaceFirst(
          RegExp(r'^app_id:.*\n', multiLine: true),
          '',
        ),
      );
      await git.run(const <String>['add', 'smf/config.yaml']);
      await git.run(
        const <String>['commit', '-m', 'test: make default config invalid'],
      );
      await git.run(const <String>['push', 'origin', 'main']);
      await git.run(const <String>['switch', 'release-target']);

      final output = <Object?>[];
      final errors = <Object?>[];
      final exitCode = await SmfExecutable.runRelease(
        const <String>[
          '--phase',
          'pull-request',
          '--repository',
          'example/remote_app',
        ],
        io: ExecutableIo(
          environment: const <String, String>{
            'SMF_GITHUB_TOKEN': 'token',
          },
          workingDirectory: root.path,
          writeOutput: output.add,
          writeError: errors.add,
        ),
      );

      expect(
        (
          exitCode: exitCode,
          nextPhase: output.isEmpty
              ? null
              : (jsonDecode(output.single! as String) as Map<String, Object?>)['nextPhase'],
          branch: await git.currentBranch(),
          clean: await git.isClean(),
          errors: errors.join('\n'),
        ),
        (
          exitCode: 0,
          nextPhase: 'noop',
          branch: 'release-target',
          clean: true,
          errors: '',
        ),
      );
    },
  );

  test(
    'validate discovers every app and optionally selects one',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'smf-validate-multiple-',
      );
      addTearDown(() => root.delete(recursive: true));
      final git = GitClient(root: root.path);
      await git.run(const <String>['init', '-b', 'main']);
      await git.run(const <String>['config', 'user.name', 'Test']);
      await git.run(const <String>[
        'config',
        'user.email',
        'test@example.com',
      ]);
      await File(p.join(root.path, 'pubspec.lock')).writeAsString('# lock\n');
      await _initializeValidationApp(root.path, 'customer');
      await _initializeValidationApp(root.path, 'driver');
      await git.run(const <String>['add', '.']);
      await git.run(const <String>[
        'commit',
        '-m',
        'chore: configure apps',
      ]);

      final output = <Object?>[];
      final errors = <Object?>[];
      final io = ExecutableIo(
        environment: const <String, String>{},
        workingDirectory: p.join(root.path, 'apps', 'customer'),
        writeOutput: output.add,
        writeError: errors.add,
      );

      expect(await SmfExecutable.runValidate(const <String>[], io: io), 0);
      expect(jsonDecode(output.removeLast()! as String), <String, Object?>{
        'isValid': true,
        'smfPaths': <Object?>[
          'apps/customer/smf',
          'apps/driver/smf',
        ],
      });

      expect(
        await SmfExecutable.runValidate(
          const <String>['--smf-path', 'apps/driver/smf'],
          io: io,
        ),
        0,
      );
      expect(jsonDecode(output.removeLast()! as String), <String, Object?>{
        'isValid': true,
        'smfPaths': <Object?>['apps/driver/smf'],
      });
      expect(errors, isEmpty);

      final driverConfig = File(
        p.join(root.path, 'apps', 'driver', 'smf', 'config.yaml'),
      );
      await driverConfig.writeAsString(
        (await driverConfig.readAsString()).replaceFirst(
          'schema_version: 1',
          'schema_version: 0',
        ),
      );

      expect(await SmfExecutable.runValidate(const <String>[], io: io), 1);
      expect(errors.join('\n'), contains('[INVALID_CONFIG]'));
      expect(
        errors.join('\n'),
        contains('Validation failed for apps/driver/smf'),
      );
      errors.clear();
      expect(
        await SmfExecutable.runValidate(
          const <String>['--smf-path', 'apps/customer/smf'],
          io: io,
        ),
        0,
      );
      expect(jsonDecode(output.removeLast()! as String), <String, Object?>{
        'isValid': true,
        'smfPaths': <Object?>['apps/customer/smf'],
      });
      expect(errors, isEmpty);
    },
  );

  test('validate reports when the repository has no SMF apps', () async {
    final root = await Directory.systemTemp.createTemp('smf-validate-empty-');
    addTearDown(() => root.delete(recursive: true));
    await GitClient(root: root.path).run(const <String>[
      'init',
      '-b',
      'main',
    ]);
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
    expect(errors.join('\n'), contains('[SMF_NOT_FOUND]'));
    expect(errors.join('\n'), contains('No smf/config.yaml was found'));
  });

  test('reports an outdated config without leaking a parallel error', () async {
    final root = await Directory.systemTemp.createTemp('smf-validate-');
    addTearDown(() => root.delete(recursive: true));
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
    await Directory(p.join(root.path, 'smf')).create();
    await File(p.join(root.path, 'smf', 'config.yaml')).writeAsString('''
schema_version: 0
app_id: example
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
    expect(errors.join('\n'), contains('schema_version must be 1'));
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
        await SmfExecutable.runValidate(
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
      expect(output.single, contains('Usage: smf validate [options]'));
      expect(
        output.single,
        contains('discover and validate every SMF app in the repository'),
      );
      expect(output.single, contains('Validate only this repository-relative'));
      output.clear();

      expect(
        await SmfExecutable.runRelease(
          const <String>['--phase', 'pull-request', '--help'],
          io: ExecutableIo(
            environment: const <String, String>{},
            workingDirectory: Directory.current.path,
            writeOutput: output.add,
            writeError: errors.add,
          ),
        ),
        0,
      );
      expect(output.single, contains('--phase (mandatory)'));
      expect(
        output.single,
        contains(
          '--phase (mandatory)                             Release workflow '
          'phase: pull-request, release-candidate, or ship.',
        ),
      );
      expect(
        output.single,
        contains(
          '--platform=<ios|android>                        Optional platform '
          'filter: ios or android. Omit it to process every eligible platform.',
        ),
      );
      expect(output.single, contains('--platform=<ios|android>'));
      expect(output.single, isNot(contains('[pull-request, release-candidate, ship]')));
      expect(output.single, isNot(contains('[ios, android]')));
      expect(output.single, isNot(contains('--prepare-only')));
      for (final option in <String>[
        '--github-token=<value>',
        '--app-store-connect-key-id=<value>',
        '--app-store-connect-issuer-id=<value>',
        '--app-store-connect-auth-key-base64=<base64>',
        '--ios-certificate-base64=<base64>',
        '--ios-certificate-password=<value>',
        '--google-play-service-account-json=<json>',
        '--android-keystore-base64=<base64>',
        '--android-key-alias=<value>',
        '--android-keystore-password=<value>',
        '--android-key-password=<value>',
      ]) {
        expect(output.single, contains(option));
      }
      for (final environmentName in <String>[
        'SMF_GITHUB_TOKEN',
        'SMF_APP_STORE_CONNECT_KEY_ID',
        'SMF_APP_STORE_CONNECT_ISSUER_ID',
        'SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64',
        'SMF_IOS_CERTIFICATE_BASE64',
        'SMF_IOS_CERTIFICATE_PASSWORD',
        'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON',
        'SMF_ANDROID_KEYSTORE_BASE64',
        'SMF_ANDROID_KEY_ALIAS',
        'SMF_ANDROID_KEYSTORE_PASSWORD',
        'SMF_ANDROID_KEY_PASSWORD',
      ]) {
        expect(
          output.single,
          contains('the $environmentName environment variable'),
        );
      }
      expect(output.single, isNot(contains('--github-token-file')));
      expect(errors, isEmpty);
    },
  );

  test('reports a user error when the release phase is missing', () async {
    final output = <Object?>[];
    final errors = <Object?>[];

    final exitCode = await SmfExecutable.run(
      const <String>['release'],
      io: ExecutableIo(
        environment: const <String, String>{},
        workingDirectory: Directory.current.path,
        writeOutput: output.add,
        writeError: errors.add,
      ),
    );

    expect(exitCode, 64);
    expect(output, isEmpty);
    expect(
      errors.first,
      'smf release: Missing required option "--phase". Choose pull-request, '
      'release-candidate, or ship.',
    );
    expect(errors.last, contains('Usage: smf release [options]'));
    expect(errors.join('\n'), isNot(contains('Unhandled exception')));
  });

  test('reports unsupported release phase and platform values', () async {
    for (final testCase in <(List<String>, String)>[
      (
        const <String>['release', '--phase', 'deploy'],
        'smf release: Unsupported phase "deploy". Choose pull-request, '
            'release-candidate, or ship.',
      ),
      (
        const <String>['release', '--phase', 'noop'],
        'smf release: Unsupported phase "noop". Choose pull-request, '
            'release-candidate, or ship.',
      ),
      (
        const <String>[
          'release',
          '--phase',
          'pull-request',
          '--platform',
          'web',
        ],
        'smf release: Unsupported platform "web".',
      ),
    ]) {
      final errors = <Object?>[];

      final exitCode = await SmfExecutable.run(
        testCase.$1,
        io: ExecutableIo(
          environment: const <String, String>{},
          workingDirectory: Directory.current.path,
          writeOutput: (_) {},
          writeError: errors.add,
        ),
      );

      expect(exitCode, 64);
      expect(errors.first, testCase.$2);
    }
  });

  test('documents every visible CLI option in command help', () async {
    final commands = <String, List<String>>{
      'init': <String>['init', '--help'],
      'upgrade': <String>['upgrade', '--help'],
      'validate': <String>['validate', '--help'],
      'release phases': <String>[
        'release',
        '--phase',
        'pull-request',
        '--help',
      ],
    };

    for (final entry in commands.entries) {
      final output = <Object?>[];
      final errors = <Object?>[];
      final exitCode = await SmfExecutable.run(
        entry.value,
        io: ExecutableIo(
          environment: const <String, String>{},
          workingDirectory: Directory.current.path,
          writeOutput: output.add,
          writeError: errors.add,
        ),
      );

      expect(exitCode, 0, reason: entry.key);
      expect(errors, isEmpty, reason: entry.key);
      final help = output.single! as String;
      final optionLines = help
          .split('\n')
          .where(
            (line) => line.trimLeft().startsWith('-h,') || line.trimLeft().startsWith('--'),
          );
      expect(optionLines, isNotEmpty, reason: entry.key);
      for (final line in optionLines) {
        expect(
          line,
          matches(
            RegExp(r'^\s*(?:-\w,\s+)?--\S+(?: \(mandatory\))?\s{2,}\S'),
          ),
          reason: '${entry.key} has an undocumented option: $line',
        );
      }
    }
  });
}
