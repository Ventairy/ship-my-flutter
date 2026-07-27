import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/process_runner.dart';
import 'package:smf_engine/src/serialization.dart';
import 'package:smf_hooks/smf_hooks.dart' show SmfHookPhase;

Future<bool?> runBeforeCreatePrHook(
  String workingDirectory,
  SmfConfig config,
  ReleasePlan plan, {
  ProcessRunner processRunner = const SystemProcessRunner(),
}) async {
  final paths = resolveSmfPaths(workingDirectory);
  return _runHook(
    paths: paths,
    hookPath: paths.beforeCreatePrHook,
    phase: SmfHookPhase.beforeCreatePr,
    config: config,
    payload: <String, Object?>{
      'currentPlatformVersion': plan.currentVersion,
      'releasePlan': plan.toJson(),
    },
    environment: <String, String>{
      'SMF_CURRENT_PLATFORM_VERSION': plan.currentVersion,
      'SMF_PLATFORM_VERSION': plan.nextVersion,
    },
    processRunner: processRunner,
  );
}

Future<bool?> runBeforeBuildHook(
  String workingDirectory,
  SmfConfig config,
  String version, {
  ProcessRunner processRunner = const SystemProcessRunner(),
}) async {
  final paths = resolveSmfPaths(workingDirectory);
  final changelog = await loadChangelog(paths.directory);
  final release = changelog.iosReleases[version];
  if (release == null) {
    throw SmfError(
      'The before_build hook has no changelog entry for iOS $version.',
      'BUILD_HOOK_CHANGELOG_MISSING',
    );
  }
  return _runHook(
    paths: paths,
    hookPath: paths.beforeBuildHook,
    phase: SmfHookPhase.beforeBuild,
    config: config,
    payload: <String, Object?>{'release': release.toJson()},
    environment: <String, String>{'SMF_PLATFORM_VERSION': version},
    processRunner: processRunner,
  );
}

Future<bool?> _runHook({
  required SmfPaths paths,
  required String hookPath,
  required SmfHookPhase phase,
  required SmfConfig config,
  required Map<String, Object?> payload,
  required Map<String, String> environment,
  required ProcessRunner processRunner,
}) async {
  final type = await FileSystemEntity.type(hookPath, followLinks: false);
  if (type == FileSystemEntityType.notFound) return null;
  invariant(
    type == FileSystemEntityType.file,
    '${p.relative(hookPath, from: paths.repositoryRoot)} must be a regular '
        'Dart file and must not be a symbolic link.',
    'INVALID_HOOK_FILE',
  );
  final relativeHook = p.relative(hookPath, from: paths.repositoryRoot);
  invariant(
    (await git(paths.repositoryRoot, <String>[
      'ls-files',
      '--error-unmatch',
      relativeHook,
    ], allowFailure: true)).isNotEmpty,
    '$relativeHook must be committed before SMF can execute it.',
    'UNTRACKED_HOOK',
  );

  final temporaryDirectory = await Directory.systemTemp.createTemp('smf-hook-');
  final contextPath = p.join(temporaryDirectory.path, 'context.json');
  final resultPath = p.join(temporaryDirectory.path, 'result.json');
  try {
    await writeJson(contextPath, <String, Object?>{
      'schemaVersion': 1,
      'phase': phase.value,
      'platform': Platform.ios.value,
      'platformVersion': environment['SMF_PLATFORM_VERSION'],
      'repositoryRoot': paths.repositoryRoot,
      'appRoot': paths.appRoot,
      'smfDirectory': paths.directory,
      'configFile': paths.config,
      'changelogFile': paths.changelog,
      'storeReleaseNotesFile': paths.storeReleaseNotes,
      'flavor': config.flavor,
      ...payload,
    });
    final command = await _hookCommand(paths, hookPath);
    await processRunner.run(
      command.executable,
      command.arguments,
      options: RunOptions(
        workingDirectory: paths.appRoot,
        environment: <String, String>{
          'SMF_HOOK': phase.value,
          'SMF_PLATFORM': Platform.ios.value,
          'SMF_REPOSITORY_ROOT': paths.repositoryRoot,
          'SMF_APP_ROOT': paths.appRoot,
          'SMF_PATH': paths.directory,
          'SMF_CONFIG_PATH': paths.config,
          'SMF_CHANGELOG_PATH': paths.changelog,
          'SMF_STORE_RELEASE_NOTES_PATH': paths.storeReleaseNotes,
          'SMF_HOOK_CONTEXT_PATH': contextPath,
          'SMF_HOOK_RESULT_PATH': resultPath,
          'SMF_FLAVOR': ?config.flavor,
          ...environment,
        },
        onStdout: (output) {
          if (output.isNotEmpty) stderr.write(output);
        },
        onStderr: (output) {
          if (output.isNotEmpty) stderr.write(output);
        },
      ),
    );
    invariant(
      await File(resultPath).exists(),
      '$relativeHook must call runSmfHook(...) from main().',
      'HOOK_RESULT_MISSING',
    );
    return _readCommitChanges(await readJson(resultPath));
  } finally {
    await temporaryDirectory.delete(recursive: true);
  }
}

Future<({String executable, List<String> arguments})> _hookCommand(
  SmfPaths paths,
  String hookPath,
) async {
  var directory = paths.appRoot;
  while (true) {
    final usesFvm =
        await File(p.join(directory, '.fvmrc')).exists() ||
        await File(p.join(directory, '.fvm', 'fvm_config.json')).exists();
    if (usesFvm) {
      return (executable: 'fvm', arguments: <String>['dart', 'run', hookPath]);
    }
    if (p.equals(directory, paths.repositoryRoot)) break;
    final parent = p.dirname(directory);
    if (parent == directory) break;
    directory = parent;
  }
  return (executable: 'dart', arguments: <String>['run', hookPath]);
}

bool _readCommitChanges(Object? value) {
  if (value is! Map<Object?, Object?> ||
      value['schemaVersion'] != 1 ||
      value['commitChanges'] is! bool) {
    throw const SmfError(
      'The SMF hook result is invalid.',
      'INVALID_HOOK_RESULT',
    );
  }
  return value['commitChanges']! as bool;
}
