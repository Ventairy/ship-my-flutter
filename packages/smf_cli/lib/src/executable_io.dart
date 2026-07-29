part of 'executables.dart';

final class ExecutableIo {
  const ExecutableIo({
    required this.environment,
    required this.workingDirectory,
    required this.writeOutput,
    required this.writeError,
    this.upgradeService,
    this.shouldCheckForUpdates = false,
  });

  factory ExecutableIo.system() => ExecutableIo(
    environment: dart_io.Platform.environment,
    workingDirectory: dart_io.Directory.current.path,
    writeOutput: dart_io.stdout.writeln,
    writeError: dart_io.stderr.writeln,
    upgradeService: SmfUpgradeService.system(),
    shouldCheckForUpdates: true,
  );

  final Map<String, String> environment;
  final String workingDirectory;
  final void Function(Object? value) writeOutput;
  final void Function(Object? value) writeError;
  final SmfUpgradeService? upgradeService;
  final bool shouldCheckForUpdates;
}
