import 'dart:convert';
import 'dart:io';

import 'error.dart';

const Set<String> sensitiveEnvironmentNames = <String>{
  'GITHUB_TOKEN',
  'INPUT_GITHUB_TOKEN',
  'SMF_APP_STORE_CONNECT_KEY_ID',
  'SMF_APP_STORE_CONNECT_ISSUER_ID',
  'SMF_APP_STORE_CONNECT_PRIVATE_KEY_BASE64',
  'SMF_IOS_CERTIFICATE_BASE64',
  'SMF_IOS_CERTIFICATE_PASSWORD',
  'SMF_IOS_PROVISIONING_PROFILES_BASE64',
  'SHIP_MY_FLUTTER_GITHUB_TOKEN',
  'SHIP_MY_FLUTTER_APP_STORE_CONNECT_KEY_ID',
  'SHIP_MY_FLUTTER_APP_STORE_CONNECT_ISSUER_ID',
  'SHIP_MY_FLUTTER_APP_STORE_CONNECT_PRIVATE_KEY_BASE64',
  'SHIP_MY_FLUTTER_APP_STORE_CONNECT_PRIVATE_KEY_PATH',
  'SHIP_MY_FLUTTER_IOS_CERTIFICATE_BASE64',
  'SHIP_MY_FLUTTER_IOS_CERTIFICATE_PATH',
  'SHIP_MY_FLUTTER_IOS_CERTIFICATE_PASSWORD',
  'SHIP_MY_FLUTTER_IOS_PROVISIONING_PROFILES_BASE64',
  'SHIP_MY_FLUTTER_IOS_PROVISIONING_PROFILES_PATH',
};

final class RunOptions {
  const RunOptions({
    this.workingDirectory,
    this.environment = const <String, String>{},
    this.input,
    this.allowFailure = false,
    this.onStdout,
    this.onStderr,
  });

  final String? workingDirectory;
  final Map<String, String> environment;
  final String? input;
  final bool allowFailure;
  final void Function(String value)? onStdout;
  final void Function(String value)? onStderr;
}

final class RunResult {
  const RunResult({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
  });

  final String stdout;
  final String stderr;
  final int exitCode;
}

abstract interface class ProcessRunner {
  Future<RunResult> run(
    String executable,
    List<String> arguments, {
    RunOptions options = const RunOptions(),
  });
}

final class SystemProcessRunner implements ProcessRunner {
  const SystemProcessRunner({this.parentEnvironment});

  /// Primarily useful for deterministic embedding and tests.
  ///
  /// When omitted, the current process environment is used.
  final Map<String, String>? parentEnvironment;

  @override
  Future<RunResult> run(
    String executable,
    List<String> arguments, {
    RunOptions options = const RunOptions(),
  }) async {
    final environment = Map<String, String>.of(
      parentEnvironment ?? Platform.environment,
    );
    for (final name in sensitiveEnvironmentNames) {
      environment.remove(name);
    }
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
      throw ShipError(
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
      throw ShipError(
        '$executable failed with exit code $exitCode',
        'COMMAND_FAILED',
        cause: result,
      );
    }
    return result;
  }
}
