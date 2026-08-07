import 'package:smf_engine/src/process/run_options.dart';
import 'package:smf_engine/src/process/run_result.dart';

export 'process/run_options.dart';
export 'process/run_result.dart';

/// Runs subprocesses through an injectable, typed boundary.
abstract interface class ProcessRunner {
  /// Runs [executable] with [arguments] and returns its complete result.
  Future<RunResult> run(
    String executable,
    List<String> arguments, {
    RunOptions options = const RunOptions(),
  });
}
