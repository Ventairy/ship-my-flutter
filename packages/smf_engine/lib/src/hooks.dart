import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/src/config.dart';
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
    Map<String, String>? environment,
  }) async {
    SmfError.check(
      plans.isNotEmpty,
      'The before_create_pr hook requires at least one release plan.',
      SmfErrorCode.createPrHookPlansEmpty,
    );
    final paths = SmfPaths.resolve(workingDirectory);
    final config = await SmfState.config(paths.directory);
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
      secretNames: config.hooks.beforeCreatePullRequestSecrets,
      environment: environment ?? Platform.environment,
    );
  }

  /// Runs preparation before SMF fingerprints and builds a release candidate.
  static Future<bool> beforeBuild({
    required String workingDirectory,
    ProcessRunner processRunner = const SystemProcessRunner(),
    Map<String, String>? environment,
  }) async {
    final paths = SmfPaths.resolve(workingDirectory);
    final config = await SmfState.config(paths.directory);
    return _runHook(
      paths: paths,
      hookPath: paths.beforeBuildHook,
      phase: SmfHookProtocolPhase.beforeBuild,
      payload: <String, Object?>{
        SmfHookProtocol.repositoryRootField: paths.repositoryRoot,
      },
      processRunner: processRunner,
      secretNames: config.hooks.beforeBuildSecrets,
      environment: environment ?? Platform.environment,
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
    required List<String> secretNames,
    required Map<String, String> environment,
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
    final secretEnvironment = _resolveSecretEnvironment(
      secretNames: secretNames,
      environment: environment,
    );

    final temporaryDirectory = await Directory.systemTemp.createTemp('smf-hook-');
    final contextPath = p.join(temporaryDirectory.path, 'context.json');
    final resultPath = p.join(temporaryDirectory.path, 'result.json');
    try {
      await JsonFile(contextPath).write(<String, Object?>{
        SmfHookProtocol.schemaVersionField: SmfHookProtocol.schemaVersion,
        SmfHookProtocol.phaseField: phase.value,
        SmfHookProtocol.secretNamesField: secretEnvironment.keys.toList(
          growable: false,
        ),
        ...payload,
      });
      final command = await _hookCommand(paths, hookPath);
      await processRunner.run(
        command.executable,
        command.arguments,
        options: RunOptions(
          workingDirectory: paths.appRoot,
          environment: <String, String>{
            ...secretEnvironment,
            SmfHookProtocol.contextPathEnvironment: contextPath,
            SmfHookProtocol.resultPathEnvironment: resultPath,
          },
          sensitiveValues: secretEnvironment.values.toList(growable: false),
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
      await _verifyNoSecretLeaks(
        repositoryRoot: paths.repositoryRoot,
        secretEnvironment: secretEnvironment,
      );
      return true;
    } finally {
      await temporaryDirectory.delete(recursive: true);
    }
  }

  static Map<String, String> _resolveSecretEnvironment({
    required List<String> secretNames,
    required Map<String, String> environment,
  }) {
    final secrets = <String, String>{};
    final missingNames = <String>[];
    final shortNames = <String>[];
    for (final name in secretNames) {
      final value = environment[name];
      if (value == null || value.isEmpty) {
        missingNames.add(name);
        continue;
      }
      if (value.length < 8) {
        shortNames.add(name);
        continue;
      }
      secrets[name] = value;
    }
    if (missingNames.isNotEmpty) {
      throw SmfError(
        'Repository hook secrets are missing or empty: '
        '${missingNames.join(', ')}.',
        SmfErrorCode.hookSecretMissing,
      );
    }
    if (shortNames.isNotEmpty) {
      throw SmfError(
        'Repository hook secrets must contain at least 8 characters: '
        '${shortNames.join(', ')}.',
        SmfErrorCode.hookSecretValueTooShort,
      );
    }
    return secrets;
  }

  static Future<void> _verifyNoSecretLeaks({
    required String repositoryRoot,
    required Map<String, String> secretEnvironment,
  }) async {
    if (secretEnvironment.isEmpty) return;
    final git = GitClient(root: repositoryRoot);
    final paths = <String>{
      ..._nullSeparatedPaths(
        await git.runRaw(const <String>[
          'diff',
          '--name-only',
          '-z',
          '--diff-filter=ACMRTUXB',
        ]),
      ),
      ..._nullSeparatedPaths(
        await git.runRaw(const <String>[
          'diff',
          '--cached',
          '--name-only',
          '-z',
          '--diff-filter=ACMRTUXB',
        ]),
      ),
      ..._nullSeparatedPaths(
        await git.runRaw(const <String>[
          'ls-files',
          '--others',
          '--exclude-standard',
          '-z',
        ]),
      ),
    };
    final leaks = <String, Set<String>>{};
    for (final relativePath in paths) {
      final absolutePath = p.normalize(p.join(repositoryRoot, relativePath));
      if (!p.isWithin(repositoryRoot, absolutePath)) continue;
      final type = await FileSystemEntity.type(absolutePath, followLinks: false);
      for (final secret in secretEnvironment.entries) {
        final isPathLeak = relativePath.contains(secret.value);
        final isContentLeak = switch (type) {
          FileSystemEntityType.file => await _fileContains(
            File(absolutePath),
            utf8.encode(secret.value),
          ),
          FileSystemEntityType.link => (await Link(absolutePath).target()).contains(
            secret.value,
          ),
          _ => false,
        };
        if (isPathLeak || isContentLeak) {
          leaks.putIfAbsent(relativePath, () => <String>{}).add(secret.key);
        }
      }
    }
    if (leaks.isEmpty) return;
    final details = leaks.entries.toList()..sort((left, right) => left.key.compareTo(right.key));
    throw SmfError(
      'Repository hook output contains configured secrets in committable '
      'paths: ${details.map((entry) {
        final names = entry.value.toList()..sort();
        return '${entry.key} (${names.join(', ')})';
      }).join('; ')}.',
      SmfErrorCode.hookSecretLeak,
    );
  }

  static Iterable<String> _nullSeparatedPaths(String output) => output.split('\u0000').where((path) => path.isNotEmpty);

  static Future<bool> _fileContains(File file, List<int> pattern) async {
    var tail = <int>[];
    await for (final chunk in file.openRead()) {
      final bytes = <int>[...tail, ...chunk];
      for (var start = 0; start <= bytes.length - pattern.length; start++) {
        var matches = true;
        for (var offset = 0; offset < pattern.length; offset++) {
          if (bytes[start + offset] == pattern[offset]) continue;
          matches = false;
          break;
        }
        if (matches) return true;
      }
      final tailLength = pattern.length - 1;
      tail = bytes.length <= tailLength ? bytes : bytes.sublist(bytes.length - tailLength);
    }
    return false;
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
