import 'package:path/path.dart' as p;

import 'error.dart';
import 'model.dart';
import 'paths.dart';
import 'process_runner.dart';

Future<void> runBeforeReleasePrHook(
  String root,
  ShipConfig config,
  ReleasePlan plan, {
  ProcessRunner processRunner = const SystemProcessRunner(),
}) async {
  final hook = config.hooks.beforeReleasePr;
  if (hook == null) return;

  final repositoryRoot = p.normalize(p.absolute(root));
  final commandPath = p.normalize(p.absolute(root, hook));
  invariant(
    p.isWithin(repositoryRoot, commandPath),
    'beforeReleasePr must stay inside the repository',
    'UNSAFE_HOOK',
  );
  final paths = resolveShipPaths(root);
  await processRunner.run(
    commandPath,
    const <String>[],
    options: RunOptions(
      workingDirectory: root,
      environment: <String, String>{
        'SHIP_MY_FLUTTER_PLATFORM': plan.platform.value,
        'SHIP_MY_FLUTTER_CURRENT_VERSION': plan.currentVersion,
        'SHIP_MY_FLUTTER_VERSION': plan.nextVersion,
        'SHIP_MY_FLUTTER_CHANGELOG_PATH': paths.changelog,
        'SHIP_MY_FLUTTER_STORE_RELEASE_NOTES_PATH': paths.storeReleaseNotes,
      },
    ),
  );
}
