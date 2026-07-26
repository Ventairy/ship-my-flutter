import 'dart:io';

import 'package:path/path.dart' as p;

import 'error.dart';
import 'git.dart';
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
  final entityType = await FileSystemEntity.type(commandPath);
  invariant(
    entityType == FileSystemEntityType.file,
    'beforeReleasePr must reference a file inside the repository',
    'UNSAFE_HOOK',
  );
  final (realRepositoryRoot, realCommandPath) = await (
    Directory(repositoryRoot).resolveSymbolicLinks(),
    File(commandPath).resolveSymbolicLinks(),
  ).wait;
  invariant(
    p.isWithin(realRepositoryRoot, realCommandPath),
    'beforeReleasePr must stay inside the repository',
    'UNSAFE_HOOK',
  );
  final relativeCommandPath = p.relative(commandPath, from: repositoryRoot);
  invariant(
    (await git(repositoryRoot, <String>[
      'ls-files',
      '--error-unmatch',
      relativeCommandPath,
    ], allowFailure: true)).isNotEmpty,
    'beforeReleasePr must reference a tracked repository file',
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
