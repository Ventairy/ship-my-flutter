import 'model.dart';
import 'paths.dart';
import 'process_runner.dart';

/// Runs the configured pre-PR hook with non-secret planning context.
Future<void> runBeforeCreatePrHook(
  String root,
  ShipConfig config,
  ReleasePlan plan, {
  ProcessRunner processRunner = const SystemProcessRunner(),
}) async {
  final hook = config.hooks.beforeCreatePr;
  if (hook == null) return;

  final paths = resolveShipPaths(root);
  await _runRepositoryCommand(
    root: root,
    command: hook.run,
    environment: <String, String>{
      'SHIP_MY_FLUTTER_PLATFORM': plan.platform.value,
      'SHIP_MY_FLUTTER_CURRENT_VERSION': plan.currentVersion,
      'SHIP_MY_FLUTTER_VERSION': plan.nextVersion,
      'SHIP_MY_FLUTTER_CHANGELOG_PATH': paths.changelog,
      'SHIP_MY_FLUTTER_STORE_RELEASE_NOTES_PATH': paths.storeReleaseNotes,
    },
    processRunner: processRunner,
  );
}

/// Runs the configured build hook before source fingerprinting.
Future<void> runBeforeBuildHook(
  String root,
  ShipConfig config,
  String version, {
  ProcessRunner processRunner = const SystemProcessRunner(),
}) async {
  final hook = config.hooks.beforeBuild;
  if (hook == null) return;

  final paths = resolveShipPaths(root);
  await _runRepositoryCommand(
    root: root,
    command: hook.run,
    environment: <String, String>{
      'SHIP_MY_FLUTTER_PLATFORM': Platform.ios.value,
      'SHIP_MY_FLUTTER_VERSION': version,
      'SHIP_MY_FLUTTER_APP_PATH': config.appPath,
      'SHIP_MY_FLUTTER_CHANGELOG_PATH': paths.changelog,
      'SHIP_MY_FLUTTER_STORE_RELEASE_NOTES_PATH': paths.storeReleaseNotes,
    },
    processRunner: processRunner,
  );
}

Future<void> _runRepositoryCommand({
  required String root,
  required String command,
  required Map<String, String> environment,
  required ProcessRunner processRunner,
}) async {
  await runShellCommand(
    command,
    options: RunOptions(workingDirectory: root, environment: environment),
    processRunner: processRunner,
  );
}
