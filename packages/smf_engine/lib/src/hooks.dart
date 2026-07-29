import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/json_file.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/process_runner.dart';
import 'package:smf_engine/src/system_process_runner.dart';
import 'package:smf_hooks/smf_hooks_protocol.dart';

/// Executes trusted repository-owned release preparation.
final class RepositoryHooks {
  const RepositoryHooks._();

  /// Runs preparation before SMF creates or updates a release pull request.
  static Future<bool> beforeCreatePullRequest({
    required String workingDirectory,
    required List<ReleasePlanDto> plans,
    ProcessRunner processRunner = const SystemProcessRunner(),
  }) async {
    SmfError.check(
      plans.isNotEmpty,
      'The before_create_pr hook requires at least one release plan.',
      SmfErrorCode.createPrHookPlansEmpty,
    );
    final paths = SmfPaths.resolve(workingDirectory);
    return _runHook(
      paths: paths,
      hookPath: paths.beforeCreatePrHook,
      phase: SmfHookProtocolPhase.beforeCreatePr,
      payload: <String, Object?>{
        SmfHookProtocol.storeReleaseNotesFileField: paths.storeReleaseNotes,
        SmfHookProtocol.iosReleaseField: _platformRelease(
          plans,
          ReleasePlatform.ios,
        ),
        SmfHookProtocol.androidReleaseField: _platformRelease(
          plans,
          ReleasePlatform.android,
        ),
      },
      processRunner: processRunner,
    );
  }

  /// Runs preparation before SMF fingerprints and builds a release candidate.
  static Future<bool> beforeBuild({
    required String workingDirectory,
    ProcessRunner processRunner = const SystemProcessRunner(),
  }) {
    final paths = SmfPaths.resolve(workingDirectory);
    return _runHook(
      paths: paths,
      hookPath: paths.beforeBuildHook,
      phase: SmfHookProtocolPhase.beforeBuild,
      payload: <String, Object?>{
        SmfHookProtocol.repositoryRootField: paths.repositoryRoot,
      },
      processRunner: processRunner,
    );
  }

  static Map<String, Object?>? _platformRelease(
    List<ReleasePlanDto> plans,
    ReleasePlatform platform,
  ) {
    ReleasePlanDto? release;
    for (final plan in plans) {
      if (plan.platform != platform) continue;
      SmfError.check(
        release == null,
        'The before_create_pr hook received duplicate ${platform.displayName} '
        'release plans.',
        SmfErrorCode.createPrHookPlatformPlanDuplicate,
      );
      release = plan;
    }
    if (release == null) return null;
    return <String, Object?>{
      SmfHookProtocol.nextVersionField: release.nextVersion,
      SmfHookProtocol.changesField: release.changes
          .map(
            (change) => <String, Object?>{
              SmfHookProtocol.changeTypeField: change.type,
              SmfHookProtocol.changeScopeField: change.scope,
              SmfHookProtocol.changeDescriptionField: change.description,
              SmfHookProtocol.changeBodyField: change.body,
            },
          )
          .toList(growable: false),
    };
  }

  static Future<bool> _runHook({
    required SmfPaths paths,
    required String hookPath,
    required SmfHookProtocolPhase phase,
    required Map<String, Object?> payload,
    required ProcessRunner processRunner,
  }) async {
    final type = await FileSystemEntity.type(hookPath, followLinks: false);
    if (type == FileSystemEntityType.notFound) return false;
    SmfError.check(
      type == FileSystemEntityType.file,
      '${p.relative(hookPath, from: paths.repositoryRoot)} must be a regular '
      'Dart file and must not be a symbolic link.',
      SmfErrorCode.invalidHookFile,
    );
    final relativeHook = p.relative(hookPath, from: paths.repositoryRoot);
    SmfError.check(
      (await GitClient(root: paths.repositoryRoot).run(<String>[
        'ls-files',
        '--error-unmatch',
        relativeHook,
      ], isFailureAllowed: true)).isNotEmpty,
      '$relativeHook must be committed before SMF can execute it.',
      SmfErrorCode.untrackedHook,
    );

    final temporaryDirectory = await Directory.systemTemp.createTemp('smf-hook-');
    final contextPath = p.join(temporaryDirectory.path, 'context.json');
    final resultPath = p.join(temporaryDirectory.path, 'result.json');
    try {
      await JsonFile(contextPath).write(<String, Object?>{
        SmfHookProtocol.schemaVersionField: SmfHookProtocol.schemaVersion,
        SmfHookProtocol.phaseField: phase.value,
        ...payload,
      });
      final command = await _hookCommand(paths, hookPath);
      await processRunner.run(
        command.executable,
        command.arguments,
        options: RunOptions(
          workingDirectory: paths.appRoot,
          environment: <String, String>{
            SmfHookProtocol.contextPathEnvironment: contextPath,
            SmfHookProtocol.resultPathEnvironment: resultPath,
          },
          onStdout: (output) {
            if (output.isNotEmpty) stderr.write(output);
          },
          onStderr: (output) {
            if (output.isNotEmpty) stderr.write(output);
          },
        ),
      );
      SmfError.check(
        await File(resultPath).exists(),
        '$relativeHook must call runSmfHook(...) from main().',
        SmfErrorCode.hookResultMissing,
      );
      _validateHookResult(await JsonFile(resultPath).read());
      return true;
    } finally {
      await temporaryDirectory.delete(recursive: true);
    }
  }

  static void _validateHookResult(Object? value) {
    if (value is! Map<Object?, Object?> ||
        value.length != 1 ||
        value[SmfHookProtocol.schemaVersionField] != SmfHookProtocol.schemaVersion) {
      throw const SmfError(
        'The SMF hook completion marker is invalid.',
        SmfErrorCode.invalidHookResult,
      );
    }
  }

  static Future<({String executable, List<String> arguments})> _hookCommand(
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
}
