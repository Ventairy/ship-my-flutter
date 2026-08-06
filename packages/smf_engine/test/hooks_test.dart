import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

import 'support/recording_process.dart';

Future<void> _writeJson(String path, Object? value) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(value));
}

Future<({Directory repository, SmfPaths paths})> _hookRepository({
  String? ignoredPath,
  String? trackedPath,
}) async {
  final repository = await Directory.systemTemp.createTemp('smf-hook-secret-');
  addTearDown(() => repository.delete(recursive: true));
  await Directory(p.join(repository.path, 'ios')).create();
  await File(
    p.join(repository.path, 'pubspec.yaml'),
  ).writeAsString('name: example\nversion: 1.0.0+1\n');
  await GitClient(root: repository.path).run(const <String>['init', '-b', 'main']);
  await GitClient(root: repository.path).run(const <String>[
    'config',
    'user.email',
    'test@example.com',
  ]);
  await GitClient(root: repository.path).run(const <String>[
    'config',
    'user.name',
    'Test',
  ]);
  await RepositoryInitializer.initialize(InitOptions(appRoot: repository.path));
  final paths = SmfPaths.resolve(repository.path);
  final config = await File(paths.config).readAsString();
  await File(paths.config).writeAsString(
    config.replaceFirst(
      'platforms:',
      'hooks:\n'
          '  before_build:\n'
          '    secrets:\n'
          '      - GOOGLE_MAPS_API_KEY\n'
          'platforms:',
    ),
  );
  await File(paths.beforeBuildHook).parent.create(recursive: true);
  await File(paths.beforeBuildHook).writeAsString('Future<void> main() async {}\n');
  if (ignoredPath != null) {
    await File(p.join(repository.path, '.gitignore')).writeAsString('$ignoredPath\n');
  }
  if (trackedPath != null) {
    await File(p.join(repository.path, trackedPath)).writeAsString('safe\n');
  }
  await GitClient(root: repository.path).run(const <String>['add', '.']);
  await GitClient(root: repository.path).run(const <String>[
    'commit',
    '-m',
    'chore: setup hook',
  ]);
  return (repository: repository, paths: paths);
}

RecordingProcessRunner _successfulHookRunner(
  Future<void> Function(ProcessInvocation invocation) beforeResult,
) => RecordingProcessRunner(
  handler: (invocation) async {
    await beforeResult(invocation);
    await _writeJson(
      invocation.options.environment['SMF_HOOK_RESULT_PATH']!,
      <String, Object?>{'schemaVersion': 1},
    );
    return const RunResult(stdout: '', stderr: '', exitCode: 0);
  },
);

void main() {
  test('discovers and runs the tracked hook from the Flutter app', () async {
    final repository = await Directory.systemTemp.createTemp('smf-hook-run-');
    addTearDown(() => repository.delete(recursive: true));
    final app = Directory(p.join(repository.path, 'apps', 'mobile'));
    await Directory(p.join(app.path, 'ios')).create(recursive: true);
    await File(
      p.join(app.path, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 1.0.0+1\n');
    await GitClient(root: repository.path).run(const <String>['init', '-b', 'main']);
    await GitClient(root: repository.path).run(const <String>[
      'config',
      'user.email',
      'test@example.com',
    ]);
    await GitClient(root: repository.path).run(const <String>['config', 'user.name', 'Test']);
    await RepositoryInitializer.initialize(
      InitOptions(appRoot: app.path, iosBundleId: 'dev.example.app'),
    );
    final paths = SmfPaths.resolve(repository.path);
    await File(paths.beforeCreatePrHook).parent.create(recursive: true);
    await File(
      paths.beforeCreatePrHook,
    ).writeAsString('Future<void> main() async {}\n');
    await File(
      paths.beforeBuildHook,
    ).writeAsString('Future<void> main() async {}\n');
    await GitClient(root: repository.path).run(const <String>['add', '.']);
    await GitClient(root: repository.path).run(const <String>['commit', '-m', 'chore: setup']);
    final hookContexts = <Map<String, Object?>>[];
    final runner = RecordingProcessRunner(
      handler: (invocation) async {
        hookContexts.add(
          jsonDecode(
                await File(
                  invocation.options.environment['SMF_HOOK_CONTEXT_PATH']!,
                ).readAsString(),
              )
              as Map<String, Object?>,
        );
        await _writeJson(
          invocation.options.environment['SMF_HOOK_RESULT_PATH']!,
          <String, Object?>{'schemaVersion': 1},
        );
        return const RunResult(stdout: '', stderr: '', exitCode: 0);
      },
    );
    const plan = ReleasePlanDto(
      platform: ReleasePlatform.ios,
      currentVersion: '1.0.0',
      nextVersion: '1.1.0',
      versionBumpType: VersionBumpType.minor,
      baseCommitHash: 'base',
      endCommitHash: 'head',
      changes: <ConventionalChangeDto>[
        ConventionalChangeDto(
          commitHash: 'commit',
          type: 'feat',
          scope: 'ios',
          description: 'Improve search',
          body: 'Show nearby work sooner.',
          isBreaking: false,
          versionBumpType: VersionBumpType.minor,
          platforms: <ReleasePlatform>[ReleasePlatform.ios],
        ),
      ],
    );

    final commit = await RepositoryHooks.beforeCreatePullRequest(
      workingDirectory: repository.path,
      plans: <ReleasePlanDto>[plan],
      processRunner: runner,
    );

    expect(commit, isTrue);
    final invocation = runner.invocations.first;
    expect(invocation.executable, 'dart');
    expect(invocation.arguments, <String>['run', paths.beforeCreatePrHook]);
    expect(invocation.options.workingDirectory, app.path);
    expect(
      invocation.options.environment.keys,
      unorderedEquals(<String>[
        'SMF_HOOK_CONTEXT_PATH',
        'SMF_HOOK_RESULT_PATH',
      ]),
    );
    expect(
      hookContexts.first.keys,
      unorderedEquals(<String>[
        'schemaVersion',
        'phase',
        'secretNames',
        'storeReleaseNotesFile',
        'iosRelease',
        'androidRelease',
      ]),
    );
    expect(hookContexts.first['androidRelease'], isNull);
    expect(
      (hookContexts.first['iosRelease']! as Map<String, Object?>).keys,
      unorderedEquals(<String>['nextVersion', 'changes']),
    );
    final iosRelease = hookContexts.first['iosRelease']! as Map<String, Object?>;
    final change = (iosRelease['changes']! as List<Object?>).single! as Map<String, Object?>;
    expect(
      change.keys,
      unorderedEquals(<String>['type', 'scope', 'description', 'body']),
    );

    expect(
      await RepositoryHooks.beforeBuild(
        workingDirectory: paths.directory,
        processRunner: runner,
      ),
      isTrue,
    );
    expect(
      hookContexts.last.keys,
      unorderedEquals(<String>[
        'schemaVersion',
        'phase',
        'secretNames',
        'repositoryRoot',
      ]),
    );
    expect(hookContexts.last['phase'], 'before_build');
  });

  test('skips an absent hook', () async {
    final repository = await Directory.systemTemp.createTemp('smf-hook-none-');
    addTearDown(() => repository.delete(recursive: true));
    await Directory(p.join(repository.path, 'ios')).create();
    await File(
      p.join(repository.path, 'pubspec.yaml'),
    ).writeAsString('name: example\n');
    await GitClient(root: repository.path).run(const <String>['init', '-b', 'main']);
    await RepositoryInitializer.initialize(InitOptions(appRoot: repository.path));
    final paths = SmfPaths.resolve(repository.path);

    expect(
      await RepositoryHooks.beforeCreatePullRequest(
        workingDirectory: paths.directory,
        plans: const <ReleasePlanDto>[
          ReleasePlanDto(
            platform: ReleasePlatform.ios,
            currentVersion: '0.0.0',
            nextVersion: '0.0.1',
            versionBumpType: VersionBumpType.patch,
            baseCommitHash: 'base',
            endCommitHash: 'head',
            changes: <ConventionalChangeDto>[],
          ),
        ],
      ),
      isFalse,
    );
  });

  test('passes configured hook secrets through the explicit environment', () async {
    final fixture = await _hookRepository();
    Map<String, Object?>? contextJson;
    final runner = _successfulHookRunner((invocation) async {
      contextJson =
          jsonDecode(
                await File(
                  invocation.options.environment['SMF_HOOK_CONTEXT_PATH']!,
                ).readAsString(),
              )
              as Map<String, Object?>;
    });

    await RepositoryHooks.beforeBuild(
      workingDirectory: fixture.paths.directory,
      processRunner: runner,
      environment: const <String, String>{
        'GOOGLE_MAPS_API_KEY': 'google-maps-secret-value',
      },
    );

    final options = runner.invocations.single.options;
    expect(
      (
        options.environment['GOOGLE_MAPS_API_KEY'],
        options.sensitiveValues.join(','),
        (contextJson!['secretNames']! as List<Object?>).join(','),
        jsonEncode(contextJson).contains('google-maps-secret-value'),
      ),
      (
        'google-maps-secret-value',
        'google-maps-secret-value',
        'GOOGLE_MAPS_API_KEY',
        false,
      ),
    );
  });

  test('rejects a missing configured hook secret before execution', () async {
    final fixture = await _hookRepository();
    final runner = _successfulHookRunner((_) async {});

    await expectLater(
      RepositoryHooks.beforeBuild(
        workingDirectory: fixture.paths.directory,
        processRunner: runner,
        environment: const <String, String>{},
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          SmfErrorCode.hookSecretMissing,
        ),
      ),
    );
  });

  test('rejects a configured hook secret shorter than eight characters', () async {
    final fixture = await _hookRepository();
    final runner = _successfulHookRunner((_) async {});

    await expectLater(
      RepositoryHooks.beforeBuild(
        workingDirectory: fixture.paths.directory,
        processRunner: runner,
        environment: const <String, String>{'GOOGLE_MAPS_API_KEY': 'short'},
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          SmfErrorCode.hookSecretValueTooShort,
        ),
      ),
    );
  });

  test('rejects a raw hook secret in an unignored output file', () async {
    final fixture = await _hookRepository();
    final runner = _successfulHookRunner((_) async {
      await File(
        p.join(fixture.repository.path, 'generated.properties'),
      ).writeAsString('key=google-maps-secret-value\n');
    });

    await expectLater(
      RepositoryHooks.beforeBuild(
        workingDirectory: fixture.paths.directory,
        processRunner: runner,
        environment: const <String, String>{
          'GOOGLE_MAPS_API_KEY': 'google-maps-secret-value',
        },
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          SmfErrorCode.hookSecretLeak,
        ),
      ),
    );
  });

  test('rejects a raw hook secret in a tracked output file', () async {
    final fixture = await _hookRepository(trackedPath: 'generated.properties');
    final runner = _successfulHookRunner((_) async {
      await File(
        p.join(fixture.repository.path, 'generated.properties'),
      ).writeAsString('key=google-maps-secret-value\n');
    });

    await expectLater(
      RepositoryHooks.beforeBuild(
        workingDirectory: fixture.paths.directory,
        processRunner: runner,
        environment: const <String, String>{
          'GOOGLE_MAPS_API_KEY': 'google-maps-secret-value',
        },
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          SmfErrorCode.hookSecretLeak,
        ),
      ),
    );
  });

  test('rejects a raw hook secret in an unignored output filename', () async {
    final fixture = await _hookRepository();
    final runner = _successfulHookRunner((_) async {
      await File(
        p.join(fixture.repository.path, 'google-maps-secret-value.txt'),
      ).writeAsString('safe\n');
    });

    await expectLater(
      RepositoryHooks.beforeBuild(
        workingDirectory: fixture.paths.directory,
        processRunner: runner,
        environment: const <String, String>{
          'GOOGLE_MAPS_API_KEY': 'google-maps-secret-value',
        },
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          SmfErrorCode.hookSecretLeak,
        ),
      ),
    );
  });

  test('allows a raw hook secret in an ignored build input file', () async {
    final fixture = await _hookRepository(ignoredPath: 'generated.properties');
    final runner = _successfulHookRunner((_) async {
      await File(
        p.join(fixture.repository.path, 'generated.properties'),
      ).writeAsString('key=google-maps-secret-value\n');
    });

    final didRun = await RepositoryHooks.beforeBuild(
      workingDirectory: fixture.paths.directory,
      processRunner: runner,
      environment: const <String, String>{
        'GOOGLE_MAPS_API_KEY': 'google-maps-secret-value',
      },
    );

    expect(didRun, isTrue);
  });

  test('rejects a raw hook secret in an unignored symlink target', () async {
    final fixture = await _hookRepository();
    final runner = _successfulHookRunner((_) async {
      await Link(p.join(fixture.repository.path, 'generated-link')).create(
        'google-maps-secret-value',
      );
    });

    await expectLater(
      RepositoryHooks.beforeBuild(
        workingDirectory: fixture.paths.directory,
        processRunner: runner,
        environment: const <String, String>{
          'GOOGLE_MAPS_API_KEY': 'google-maps-secret-value',
        },
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          SmfErrorCode.hookSecretLeak,
        ),
      ),
    );
  });
}
