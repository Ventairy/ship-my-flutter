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
      unorderedEquals(<String>['schemaVersion', 'phase', 'repositoryRoot']),
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
}
