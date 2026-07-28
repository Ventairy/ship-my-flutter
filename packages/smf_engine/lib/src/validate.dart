import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/serialization.dart';

/// Validates repository state required by release operations.
final class RepositoryValidator {
  const RepositoryValidator._();

  /// Validates the SMF app resolved from [workingDirectory].
  static Future<void> validate(String workingDirectory) async {
    final paths = SmfPaths.resolve(workingDirectory);
    final config = await SmfState.config(paths.directory);
    final manifest = await SmfState.manifest(paths.directory);
    final changelog = await SmfState.changelog(paths.directory);
    await SmfState.storeReleaseNotes(paths.directory);
    await _validateStatePaths(paths);
    await _validateHooks(paths);
    await _validateUniqueAppId(paths, config);

    if (config.enabledPlatforms.isNotEmpty) {
      await _validateFlutterProject(paths);
    }
    for (final platform in config.enabledPlatforms) {
      await _validatePlatformProject(paths: paths, platform: platform);
      _validateReleaseState(
        platform: platform,
        manifest: manifest,
        changelog: changelog,
      );
    }
    SmfError.check(changelog.schemaVersion == 1, 'Unsupported changelog schema.');
  }

  static Future<void> _validateStatePaths(SmfPaths paths) async {
    SmfError.check(
      await SmfFileSystem.exists(paths.config),
      '${p.relative(paths.config, from: paths.repositoryRoot)} is missing.',
      'STATE_PATH_MISSING',
    );
    for (final statePath in <String>[
      paths.config,
      paths.manifest,
      paths.changelog,
      paths.storeReleaseNotes,
      paths.candidates,
    ]) {
      if (!(await SmfFileSystem.exists(statePath))) continue;
      SmfError.check(
        !(await Link(statePath).exists()),
        '${p.relative(statePath, from: paths.repositoryRoot)} must not be a '
            'symbolic link.',
        'STATE_PATH_SYMLINK',
      );
    }
  }

  static Future<void> _validateUniqueAppId(
    SmfPaths paths,
    SmfConfig config,
  ) async {
    for (final directory in SmfPaths.discover(paths.repositoryRoot)) {
      if (p.equals(directory, paths.directory)) continue;
      final value = await SmfFileSystem.readYaml(
        p.join(directory, SmfPaths.configFileName),
      );
      final siblingAppId = value is Map<Object?, Object?> ? value['app_id'] : null;
      SmfError.check(
        siblingAppId != config.appId,
        'app_id "${config.appId}" is also used by '
            '${p.relative(p.dirname(directory), from: paths.repositoryRoot)}.',
        'APP_ID_CONFLICT',
      );
    }
  }

  static Future<void> _validateHooks(SmfPaths paths) async {
    for (final hookPath in <String>[
      paths.beforeCreatePrHook,
      paths.beforeBuildHook,
    ]) {
      final type = await FileSystemEntity.type(
        hookPath,
        followLinks: false,
      );
      if (type == FileSystemEntityType.notFound) continue;
      final relativePath = p.relative(
        hookPath,
        from: paths.repositoryRoot,
      );
      SmfError.check(
        type == FileSystemEntityType.file,
        '$relativePath must be a regular Dart file and must not be a '
            'symbolic link.',
        'INVALID_HOOK_FILE',
      );
      SmfError.check(
        (await GitClient(root: paths.repositoryRoot).run(<String>[
          'ls-files',
          '--error-unmatch',
          relativePath,
        ], allowFailure: true)).isNotEmpty,
        '$relativePath must be committed before SMF can execute it.',
        'UNTRACKED_HOOK',
      );
    }
  }

  static Future<void> _validateFlutterProject(SmfPaths paths) async {
    final repositoryRoot = paths.repositoryRoot;
    final projectRoot = paths.appRoot;
    SmfError.check(
      await Directory(projectRoot).exists(),
      'The Flutter app directory does not exist.',
      'APP_PATH_NOT_FOUND',
    );
    final (repositoryRealPath, projectRealPath) = await (
      Directory(repositoryRoot).resolveSymbolicLinks(),
      Directory(projectRoot).resolveSymbolicLinks(),
    ).wait;
    SmfError.check(
      projectRealPath == repositoryRealPath || p.isWithin(repositoryRealPath, projectRealPath),
      'The Flutter app directory resolves outside the repository.',
      'APP_PATH_ESCAPE',
    );
    SmfError.check(
      await SmfFileSystem.exists(p.join(projectRoot, 'pubspec.yaml')),
      'No pubspec.yaml exists in the Flutter app directory.',
      'PUBSPEC_NOT_FOUND',
    );
    final lockfile = await _findWorkspaceLockfile(
      repositoryRoot: repositoryRoot,
      projectRoot: projectRoot,
    );
    SmfError.check(
      lockfile != null,
      'No committed pubspec.lock exists at the Flutter project or workspace '
          'root.',
      'LOCKFILE_NOT_FOUND',
    );
    final relativeLockfile = p.relative(lockfile!, from: repositoryRoot);
    SmfError.check(
      (await GitClient(root: repositoryRoot).run(<String>[
        'ls-files',
        '--error-unmatch',
        relativeLockfile,
      ], allowFailure: true)).isNotEmpty,
      '$relativeLockfile must be committed before release builds.',
      'LOCKFILE_UNTRACKED',
    );
  }

  static Future<void> _validatePlatformProject({
    required SmfPaths paths,
    required Platform platform,
  }) async {
    final platformPath = p.join(paths.appRoot, platform.value);
    SmfError.check(
      await Directory(platformPath).exists(),
      'No ${platform.value} directory exists in the Flutter app.',
      '${platform.value.toUpperCase()}_PROJECT_NOT_FOUND',
    );
    final projectRealPath = await Directory(
      paths.appRoot,
    ).resolveSymbolicLinks();
    final platformRealPath = await Directory(
      platformPath,
    ).resolveSymbolicLinks();
    SmfError.check(
      p.isWithin(projectRealPath, platformRealPath),
      'The ${platform.value} directory resolves outside the Flutter project.',
      '${platform.value.toUpperCase()}_PATH_ESCAPE',
    );
  }

  static void _validateReleaseState({
    required Platform platform,
    required SmfManifest manifest,
    required ChangelogManifest changelog,
  }) {
    final state = manifest.forPlatform(platform);
    SmfError.check(
      state.version.isNotEmpty,
      'The ${platform.displayName} manifest version is empty.',
    );
    if (state.pendingRelease) {
      SmfError.check(
        changelog.releasesFor(platform).containsKey(state.version),
        'The pending ${platform.displayName} version ${state.version} has no '
            'changelog entry.',
        'PENDING_CHANGELOG_MISSING',
      );
    }
  }

  static Future<String?> _findWorkspaceLockfile({
    required String repositoryRoot,
    required String projectRoot,
  }) async {
    var directory = projectRoot;
    while (directory == repositoryRoot || p.isWithin(repositoryRoot, directory)) {
      final lockfile = p.join(directory, 'pubspec.lock');
      if (await SmfFileSystem.exists(lockfile)) return lockfile;
      if (directory == repositoryRoot) break;
      directory = p.dirname(directory);
    }
    return null;
  }
}
