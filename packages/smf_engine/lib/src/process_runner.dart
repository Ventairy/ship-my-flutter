import 'dart:convert';
import 'dart:io';

import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/process/run_options.dart';
import 'package:smf_engine/src/process/run_result.dart';

export 'process/run_options.dart';
export 'process/run_result.dart';

abstract interface class ProcessRunner {
  Future<RunResult> run(
    String executable,
    List<String> arguments, {
    RunOptions options = const RunOptions(),
  });
}

final class SystemProcessRunner implements ProcessRunner {
  const SystemProcessRunner({this.parentEnvironment});

  static const Set<String> _sensitiveEnvironmentNames = <String>{
    'GITHUB_TOKEN',
    'INPUT_GITHUB_TOKEN',
    'SMF_APP_STORE_CONNECT_KEY_ID',
    'SMF_APP_STORE_CONNECT_ISSUER_ID',
    'SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64',
    'SMF_APP_STORE_CONNECT_AUTH_KEY_PATH',
    'SMF_IOS_CERTIFICATE_BASE64',
    'SMF_IOS_CERTIFICATE_PATH',
    'SMF_IOS_CERTIFICATE_PASSWORD',
    'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON',
    'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH',
    'SMF_ANDROID_KEYSTORE_BASE64',
    'SMF_ANDROID_KEYSTORE_PATH',
    'SMF_ANDROID_KEY_ALIAS',
    'SMF_ANDROID_KEYSTORE_PASSWORD',
    'SMF_ANDROID_KEY_PASSWORD',
    'SMF_GITHUB_TOKEN',
  };

  /// Primarily useful for deterministic embedding and tests.
  ///
  /// When omitted, the current process environment is used.
  final Map<String, String>? parentEnvironment;

  /// Runs a trusted repository command through a fail-fast POSIX shell.
  ///
  /// The command inherits the credential-stripped environment enforced by
  /// this runner. Use this only for explicit consumer configuration, not for
  /// remote or machine-generated values.
  static Future<RunResult> shell(
    String command, {
    RunOptions options = const RunOptions(),
    ProcessRunner processRunner = const SystemProcessRunner(),
  }) {
    if (Platform.isWindows) {
      throw const SmfError(
        'Repository commands require a POSIX shell.',
        'SHELL_UNSUPPORTED',
      );
    }
    return processRunner.run('/bin/bash', <String>[
      '--noprofile',
      '--norc',
      '-euo',
      'pipefail',
      '-c',
      command,
    ], options: options);
  }

  @override
  Future<RunResult> run(
    String executable,
    List<String> arguments, {
    RunOptions options = const RunOptions(),
  }) async {
    final environment = Map<String, String>.of(
      parentEnvironment ?? Platform.environment,
    );
    _sensitiveEnvironmentNames.forEach(environment.remove);
    environment.addAll(options.environment);

    late final Process process;
    try {
      process = await Process.start(
        executable,
        arguments,
        workingDirectory: options.workingDirectory,
        environment: environment,
        includeParentEnvironment: false,
      );
    } on ProcessException catch (error) {
      throw SmfError(
        'Could not start $executable: ${error.message}',
        'COMMAND_FAILED',
        cause: error,
      );
    }
    if (options.input != null) {
      process.stdin.write(options.input);
    }
    await process.stdin.close();

    final stdoutFuture = process.stdout.transform(utf8.decoder).join();
    final stderrFuture = process.stderr.transform(utf8.decoder).join();
    final (stdoutValue, stderrValue, exitCode) = await (
      stdoutFuture,
      stderrFuture,
      process.exitCode,
    ).wait;
    options.onStdout?.call(stdoutValue);
    options.onStderr?.call(stderrValue);
    final result = RunResult(
      stdout: stdoutValue,
      stderr: stderrValue,
      exitCode: exitCode,
    );
    if (exitCode != 0 && !options.allowFailure) {
      final diagnostics = stderrValue.trim().isNotEmpty ? stderrValue.trim() : stdoutValue.trim();
      final detail = diagnostics.isEmpty ? '' : '\n${_truncateDiagnostics(diagnostics)}';
      throw SmfError(
        '$executable failed with exit code $exitCode$detail',
        'COMMAND_FAILED',
        cause: result,
      );
    }
    return result;
  }

  static String _truncateDiagnostics(String value) {
    const maximumCharacters = 4000;
    if (value.length <= maximumCharacters) return value;
    return '${value.substring(0, maximumCharacters)}\n[output truncated]';
  }
}
