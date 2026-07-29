part of 'smf_hooks_sdk.dart';

/// Context supplied before SMF fingerprints and builds a platform release
/// candidate.
final class SmfBeforeBuildContext extends SmfHookContext {
  const SmfBeforeBuildContext._({
    required Directory repositoryRoot,
  }) : _repositoryRoot = repositoryRoot,
       super._();

  final Directory _repositoryRoot;

  /// Runs [command] through the platform shell.
  ///
  /// By default, the command runs from the hook process's current directory.
  /// Pass `shouldRunFromRepositoryRoot: true` to run it from the Git
  /// repository root.
  Future<void> runCommand(
    String command, {
    bool shouldRunFromRepositoryRoot = false,
  }) async {
    final process = await Process.start(
      '/bin/sh',
      <String>['-c', command],
      workingDirectory: shouldRunFromRepositoryRoot ? _repositoryRoot.path : null,
      mode: ProcessStartMode.inheritStdio,
    );
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw ProcessException(
        '/bin/sh',
        <String>['-c', command],
        'Hook command failed.',
        exitCode,
      );
    }
  }
}
