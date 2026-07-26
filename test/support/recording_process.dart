import 'package:ship_my_flutter/ship_my_flutter.dart';

final class ProcessInvocation {
  const ProcessInvocation({
    required this.executable,
    required this.arguments,
    required this.options,
  });

  final String executable;
  final List<String> arguments;
  final RunOptions options;
}

final class RecordingProcessRunner implements ProcessRunner {
  RecordingProcessRunner({this.handler});

  final Future<RunResult> Function(ProcessInvocation invocation)? handler;
  final List<ProcessInvocation> invocations = <ProcessInvocation>[];

  @override
  Future<RunResult> run(
    String executable,
    List<String> arguments, {
    RunOptions options = const RunOptions(),
  }) async {
    final invocation = ProcessInvocation(
      executable: executable,
      arguments: List<String>.unmodifiable(arguments),
      options: options,
    );
    invocations.add(invocation);
    return handler?.call(invocation) ??
        const RunResult(stdout: '', stderr: '', exitCode: 0);
  }
}
