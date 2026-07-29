import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/yaml_file.dart';

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
      await File(paths.config).exists(),
      '${p.relative(paths.config, from: paths.repositoryRoot)} is missing.',
      SmfErrorCode.statePathMissing,
    );
    for (final statePath in <String>[
      paths.config,
      paths.manifest,
      paths.changelog,
      paths.storeReleaseNotes,
      paths.releaseCandidates,
    ]) {
      if (await FileSystemEntity.type(statePath) == FileSystemEntityType.notFound) {
        continue;
      }
      SmfError.check(
        !(await Link(statePath).exists()),
        '${p.relative(statePath, from: paths.repositoryRoot)} must not be a '
        'symbolic link.',
        SmfErrorCode.statePathSymlink,
      );
    }
  }

  static Future<void> _validateUniqueAppId(
    SmfPaths paths,
    SmfConfig config,
  ) async {
    for (final directory in SmfPaths.discover(paths.repositoryRoot)) {
      if (p.equals(directory, paths.directory)) continue;
      final value = await YamlFile(p.join(directory, SmfPaths.configFileName)).read();
      final siblingAppId = value is Map<String, Object?> ? value['app_id'] : null;
      SmfError.check(
        siblingAppId != config.appId,
        'app_id "${config.appId}" is also used by '
        '${p.relative(p.dirname(directory), from: paths.repositoryRoot)}.',
        SmfErrorCode.appIdConflict,
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
        SmfErrorCode.invalidHookFile,
      );
      SmfError.check(
        (await GitClient(root: paths.repositoryRoot).run(<String>[
          'ls-files',
          '--error-unmatch',
          relativePath,
        ], isFailureAllowed: true)).isNotEmpty,
        '$relativePath must be committed before SMF can execute it.',
        SmfErrorCode.untrackedHook,
      );
    }
  }

  static Future<void> _validateFlutterProject(SmfPaths paths) async {
    final repositoryRoot = paths.repositoryRoot;
    final projectRoot = paths.appRoot;
    SmfError.check(
      await Directory(projectRoot).exists(),
      'The Flutter app directory does not exist.',
      SmfErrorCode.appPathNotFound,
    );
    final (repositoryRealPath, projectRealPath) = await (
      Directory(repositoryRoot).resolveSymbolicLinks(),
      Directory(projectRoot).resolveSymbolicLinks(),
    ).wait;
    SmfError.check(
      projectRealPath == repositoryRealPath || p.isWithin(repositoryRealPath, projectRealPath),
      'The Flutter app directory resolves outside the repository.',
      SmfErrorCode.appPathEscape,
    );
    SmfError.check(
      await File(p.join(projectRoot, 'pubspec.yaml')).exists(),
      'No pubspec.yaml exists in the Flutter app directory.',
      SmfErrorCode.pubspecNotFound,
    );
    final lockfile = await _findWorkspaceLockfile(
      repositoryRoot: repositoryRoot,
      projectRoot: projectRoot,
    );
    if (lockfile == null) {
      throw const SmfError(
        'No committed pubspec.lock exists at the Flutter project or workspace '
        'root.',
        SmfErrorCode.lockfileNotFound,
      );
    }
    final relativeLockfile = p.relative(lockfile, from: repositoryRoot);
    SmfError.check(
      (await GitClient(root: repositoryRoot).run(<String>[
        'ls-files',
        '--error-unmatch',
        relativeLockfile,
      ], isFailureAllowed: true)).isNotEmpty,
      '$relativeLockfile must be committed before release builds.',
      SmfErrorCode.lockfileUntracked,
    );
  }

  static Future<void> _validatePlatformProject({
    required SmfPaths paths,
    required ReleasePlatform platform,
  }) async {
    final platformPath = p.join(paths.appRoot, platform.value);
    SmfError.check(
      await Directory(platformPath).exists(),
      'No ${platform.value} directory exists in the Flutter app.',
      switch (platform) {
        ReleasePlatform.ios => SmfErrorCode.iosProjectNotFound,
        ReleasePlatform.android => SmfErrorCode.androidProjectNotFound,
      },
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
      switch (platform) {
        ReleasePlatform.ios => SmfErrorCode.iosPathEscape,
        ReleasePlatform.android => SmfErrorCode.androidPathEscape,
      },
    );
  }

  static void _validateReleaseState({
    required ReleasePlatform platform,
    required ManifestDto manifest,
    required ChangelogDto changelog,
  }) {
    final state = manifest.forPlatform(platform);
    SmfError.check(
      state.version.isNotEmpty,
      'The ${platform.displayName} manifest version is empty.',
    );
    if (state.isReleasePending) {
      final release = changelog.platforms
          .select(platform)
          .releaseVersion(
            state.version,
          );
      SmfError.check(
        release != null,
        'The pending ${platform.displayName} version ${state.version} has no '
        'changelog entry.',
        SmfErrorCode.pendingChangelogMissing,
      );
      SmfError.check(
        release?.endCommitHash == state.endCommitHash,
        'The pending ${platform.displayName} version ${state.version} has '
        'different ending commits in the manifest and changelog.',
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
      if (await File(lockfile).exists()) return lockfile;
      if (directory == repositoryRoot) break;
      directory = p.dirname(directory);
    }
    return null;
  }
}
