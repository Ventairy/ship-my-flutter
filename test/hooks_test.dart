import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf/smf.dart';
import 'package:test/test.dart';

import 'support/recording_process.dart';

final class _BeforeCreateHook extends SmfHook {
  SmfBeforeCreatePrContext? received;

  @override
  bool get commitChanges => false;

  @override
  Future<void> run(SmfBeforeCreatePrContext context) async {
    received = context;
  }
}

Future<void> _writeJson(String path, Object? value) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(value));
}

void main() {
  test('runSmfHook exposes a typed before-create-PR context', () async {
    final root = await Directory.systemTemp.createTemp('smf-hook-context-');
    addTearDown(() => root.delete(recursive: true));
    final contextPath = p.join(root.path, 'context.json');
    final resultPath = p.join(root.path, 'result.json');
    const plan = ReleasePlan(
      platform: Platform.ios,
      currentVersion: '1.0.0',
      nextVersion: '1.1.0',
      bump: Bump.minor,
      baseSha: 'base',
      headSha: 'head',
      changes: <ConventionalChange>[],
    );
    await _writeJson(contextPath, <String, Object?>{
      'schemaVersion': 1,
      'phase': 'before_create_pr',
      'platform': 'ios',
      'platformVersion': '1.1.0',
      'repositoryRoot': root.path,
      'appRoot': p.join(root.path, 'app'),
      'smfDirectory': p.join(root.path, 'app', 'smf'),
      'configFile': p.join(root.path, 'app', 'smf', 'config.yaml'),
      'changelogFile': p.join(root.path, 'app', 'smf', 'changelog.json'),
      'storeReleaseNotesFile': p.join(
        root.path,
        'app',
        'smf',
        'store-release-notes.json',
      ),
      'flavor': 'production',
      'currentPlatformVersion': '1.0.0',
      'releasePlan': plan.toJson(),
    });
    final hook = _BeforeCreateHook();

    await runSmfHook(
      hook,
      environment: <String, String>{
        'SMF_HOOK_CONTEXT_PATH': contextPath,
        'SMF_HOOK_RESULT_PATH': resultPath,
      },
    );

    expect(hook.received, isNotNull);
    expect(hook.received!.platform, Platform.ios);
    expect(hook.received!.platformVersion.toString(), '1.1.0');
    expect(hook.received!.currentPlatformVersion.toString(), '1.0.0');
    expect(hook.received!.releasePlan, plan);
    expect(hook.received!.flavor, 'production');
    expect(jsonDecode(await File(resultPath).readAsString()), <String, Object?>{
      'schemaVersion': 1,
      'commitChanges': false,
    });
  });

  test('discovers and runs the tracked hook from the Flutter app', () async {
    final repository = await Directory.systemTemp.createTemp('smf-hook-run-');
    addTearDown(() => repository.delete(recursive: true));
    final app = Directory(p.join(repository.path, 'apps', 'mobile'));
    await Directory(p.join(app.path, 'ios')).create(recursive: true);
    await File(
      p.join(app.path, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 1.0.0+1\n');
    await git(repository.path, const <String>['init', '-b', 'main']);
    await git(repository.path, const <String>[
      'config',
      'user.email',
      'test@example.com',
    ]);
    await git(repository.path, const <String>['config', 'user.name', 'Test']);
    await initialize(
      InitOptions(appRoot: app.path, bundleId: 'dev.example.app'),
    );
    final paths = resolveSmfPaths(repository.path);
    await File(paths.beforeCreatePrHook).parent.create(recursive: true);
    await File(
      paths.beforeCreatePrHook,
    ).writeAsString('Future<void> main() async {}\n');
    await git(repository.path, const <String>['add', '.']);
    await git(repository.path, const <String>['commit', '-m', 'chore: setup']);
    final runner = RecordingProcessRunner(
      handler: (invocation) async {
        await _writeJson(
          invocation.options.environment['SMF_HOOK_RESULT_PATH']!,
          <String, Object?>{'schemaVersion': 1, 'commitChanges': true},
        );
        return const RunResult(stdout: '', stderr: '', exitCode: 0);
      },
    );
    const plan = ReleasePlan(
      platform: Platform.ios,
      currentVersion: '1.0.0',
      nextVersion: '1.1.0',
      bump: Bump.minor,
      baseSha: 'base',
      headSha: 'head',
      changes: <ConventionalChange>[],
    );

    final commit = await runBeforeCreatePrHook(
      repository.path,
      await loadConfig(paths.directory),
      plan,
      processRunner: runner,
    );

    expect(commit, isTrue);
    final invocation = runner.invocations.single;
    expect(invocation.executable, 'dart');
    expect(invocation.arguments, <String>['run', paths.beforeCreatePrHook]);
    expect(invocation.options.workingDirectory, app.path);
    expect(
      invocation.options.environment,
      containsPair('SMF_PLATFORM_VERSION', '1.1.0'),
    );
    expect(
      invocation.options.environment,
      containsPair('SMF_APP_ROOT', app.path),
    );
  });

  test('skips an absent hook', () async {
    final repository = await Directory.systemTemp.createTemp('smf-hook-none-');
    addTearDown(() => repository.delete(recursive: true));
    await Directory(p.join(repository.path, 'ios')).create();
    await File(
      p.join(repository.path, 'pubspec.yaml'),
    ).writeAsString('name: example\n');
    await git(repository.path, const <String>['init', '-b', 'main']);
    await initialize(InitOptions(appRoot: repository.path));
    final paths = resolveSmfPaths(repository.path);

    expect(
      await runBeforeCreatePrHook(
        paths.directory,
        await loadConfig(paths.directory),
        const ReleasePlan(
          platform: Platform.ios,
          currentVersion: '0.0.0',
          nextVersion: '0.0.1',
          bump: Bump.patch,
          baseSha: 'base',
          headSha: 'head',
          changes: <ConventionalChange>[],
        ),
      ),
      isNull,
    );
  });
}
