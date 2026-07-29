/// Options controlling one subprocess invocation.
///
/// This deliberately avoids generated value semantics because its environment
/// and input may contain scoped credentials.
final class RunOptions {
  /// Creates subprocess options.
  const RunOptions({
    this.workingDirectory,
    this.environment = const <String, String>{},
    this.input,
    this.isFailureAllowed = false,
    this.onStdout,
    this.onStderr,
  });

  /// Working directory for the subprocess.
  final String? workingDirectory;

  /// Explicit environment additions.
  final Map<String, String> environment;

  /// Optional standard input.
  final String? input;

  /// Whether a non-zero exit code may be returned instead of thrown.
  final bool isFailureAllowed;

  /// Optional complete standard-output observer.
  final void Function(String value)? onStdout;

  /// Optional complete standard-error observer.
  final void Function(String value)? onStderr;
}
