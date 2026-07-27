/// Captured result of a subprocess invocation.
final class RunResult {
  /// Creates a subprocess result.
  const RunResult({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
  });

  /// Captured standard output.
  final String stdout;

  /// Captured standard error.
  final String stderr;

  /// Process exit code.
  final int exitCode;
}
