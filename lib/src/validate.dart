import 'dart:io';

import 'package:path/path.dart' as p;

import 'config.dart';
import 'error.dart';
import 'git.dart';
import 'paths.dart';
import 'serialization.dart';

Future<String?> _findWorkspaceLockfile(
  String repositoryRoot,
  String projectRoot,
) async {
  var directory = projectRoot;
  while (directory == repositoryRoot || p.isWithin(repositoryRoot, directory)) {
    final lockfile = p.join(directory, 'pubspec.lock');
    if (await fileExists(lockfile)) return lockfile;
    if (directory == repositoryRoot) break;
    directory = p.dirname(directory);
  }
  return null;
}

Future<void> validateRepository(String workingDirectory) async {
  final paths = resolveSmfPaths(workingDirectory);
  final (config, manifest, changelog, _) = await (
    loadConfig(paths.directory),
    loadManifest(paths.directory),
    loadChangelog(paths.directory),
    loadStoreReleaseNotes(paths.directory),
  ).wait;
  invariant(
    await fileExists(paths.config),
    '${p.relative(paths.config, from: paths.repositoryRoot)} is missing.',
    'STATE_PATH_MISSING',
  );
  invariant(
    !(await Link(paths.config).exists()),
    '${p.relative(paths.config, from: paths.repositoryRoot)} must not be a '
        'symbolic link.',
    'STATE_PATH_SYMLINK',
  );
  for (final statePath in <String>[
    paths.manifest,
    paths.changelog,
    paths.storeReleaseNotes,
    paths.candidates,
  ]) {
    if (!(await fileExists(statePath))) continue;
    invariant(
      !(await Link(statePath).exists()),
      '${p.relative(statePath, from: paths.repositoryRoot)} must not be a '
          'symbolic link.',
      'STATE_PATH_SYMLINK',
    );
  }

  if (config.ios.enabled) {
    final repositoryRoot = paths.repositoryRoot;
    final projectRoot = paths.appRoot;
    invariant(
      await Directory(projectRoot).exists(),
      'The Flutter app directory does not exist.',
      'APP_PATH_NOT_FOUND',
    );
    final (repositoryRealPath, projectRealPath) = await (
      Directory(repositoryRoot).resolveSymbolicLinks(),
      Directory(projectRoot).resolveSymbolicLinks(),
    ).wait;
    invariant(
      projectRealPath == repositoryRealPath ||
          p.isWithin(repositoryRealPath, projectRealPath),
      'The Flutter app directory resolves outside the repository.',
      'APP_PATH_ESCAPE',
    );
    invariant(
      await fileExists(p.join(projectRoot, 'pubspec.yaml')),
      'No pubspec.yaml exists in the Flutter app directory.',
      'PUBSPEC_NOT_FOUND',
    );
    final lockfile = await _findWorkspaceLockfile(repositoryRoot, projectRoot);
    invariant(
      lockfile != null,
      'No committed pubspec.lock exists at the Flutter project or workspace '
          'root.',
      'LOCKFILE_NOT_FOUND',
    );
    final relativeLockfile = p.relative(lockfile!, from: repositoryRoot);
    invariant(
      (await git(repositoryRoot, <String>[
        'ls-files',
        '--error-unmatch',
        relativeLockfile,
      ], allowFailure: true)).isNotEmpty,
      '$relativeLockfile must be committed before release builds.',
      'LOCKFILE_UNTRACKED',
    );
    final iosPath = p.join(projectRoot, 'ios');
    invariant(
      await Directory(iosPath).exists(),
      'No ios directory exists in the Flutter app.',
      'IOS_PROJECT_NOT_FOUND',
    );
    final iosRealPath = await Directory(iosPath).resolveSymbolicLinks();
    invariant(
      p.isWithin(projectRealPath, iosRealPath),
      'The ios directory resolves outside the Flutter project.',
      'IOS_PATH_ESCAPE',
    );
  }

  invariant(
    manifest.ios.version.isNotEmpty,
    'The iOS manifest version is empty.',
  );
  if (manifest.ios.pendingRelease) {
    invariant(
      changelog.iosReleases.containsKey(manifest.ios.version),
      'The pending iOS version ${manifest.ios.version} has no changelog entry.',
      'PENDING_CHANGELOG_MISSING',
    );
  }
  invariant(changelog.schemaVersion == 1, 'Unsupported changelog schema.');
}
