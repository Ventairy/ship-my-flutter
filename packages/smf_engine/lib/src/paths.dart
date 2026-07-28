import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/model.dart';

/// Resolved repository, Flutter app, and SMF state paths.
final class SmfPaths {
  const SmfPaths._({
    required this.repositoryRoot,
    required this.appRoot,
    required this.directory,
    required this.config,
    required this.manifest,
    required this.changelog,
    required this.storeReleaseNotes,
    required this.candidates,
    required this.hooks,
    required this.beforeCreatePrHook,
    required this.beforeBuildHook,
  });

  /// Discovers one `smf/config.yaml` at or below [workingDirectory].
  ///
  /// Pass [smfPath] to select a specific `smf` directory when a repository
  /// contains multiple Flutter apps.
  factory SmfPaths.resolve(String? workingDirectory, {String? smfPath}) {
    final start = p.normalize(
      p.absolute(workingDirectory ?? Directory.current.path),
    );
    final directory = smfPath == null ? _discoverSmfDirectory(start) : _resolveExplicitSmfDirectory(start, smfPath);
    return SmfPaths._forDirectory(directory);
  }

  /// Resolves the conventional `smf` directory owned by [appRoot].
  factory SmfPaths.forApp([String? appRoot]) {
    final resolvedAppRoot = p.normalize(
      p.absolute(appRoot ?? Directory.current.path),
    );
    return SmfPaths._forDirectory(
      p.join(resolvedAppRoot, directoryName),
    );
  }

  factory SmfPaths._forDirectory(String directory) {
    final normalizedDirectory = p.normalize(p.absolute(directory));
    final appRoot = p.dirname(normalizedDirectory);
    final repositoryRoot = _findRepositoryRoot(appRoot);
    final hooks = p.join(normalizedDirectory, 'hooks');
    return SmfPaths._(
      repositoryRoot: repositoryRoot,
      appRoot: appRoot,
      directory: normalizedDirectory,
      config: p.join(normalizedDirectory, configFileName),
      manifest: p.join(normalizedDirectory, 'manifest.json'),
      changelog: p.join(normalizedDirectory, 'changelog.json'),
      storeReleaseNotes: p.join(
        normalizedDirectory,
        'store-release-notes.json',
      ),
      candidates: p.join(normalizedDirectory, 'candidates'),
      hooks: hooks,
      beforeCreatePrHook: p.join(hooks, 'before_create_pr.dart'),
      beforeBuildHook: p.join(hooks, 'before_build.dart'),
    );
  }

  /// Stable name of every SMF state directory.
  static const String directoryName = 'smf';

  /// Stable name of the user-authored SMF configuration file.
  static const String configFileName = 'config.yaml';

  static const Set<String> _prunedDirectoryNames = <String>{
    '.dart_tool',
    '.fvm',
    '.git',
    '.idea',
    '.pub-cache',
    '.vscode',
    'build',
    'node_modules',
  };

  /// Git repository root used for history, branches, commits, and pushes.
  final String repositoryRoot;

  /// Flutter application root, which is the parent of [directory].
  final String appRoot;

  /// Selected `smf` directory.
  final String directory;

  /// User-authored SMF configuration.
  final String config;

  /// Machine-owned platform release state.
  final String manifest;

  /// Machine-owned release change history.
  final String changelog;

  /// User-owned localized store release notes.
  final String storeReleaseNotes;

  /// Directory containing exact candidate receipts.
  final String candidates;

  /// Directory containing repository hook entrypoints.
  final String hooks;

  /// Hook invoked before SMF creates or updates a release pull request.
  final String beforeCreatePrHook;

  /// Hook invoked before SMF builds a platform candidate.
  final String beforeBuildHook;

  /// Finds every initialized SMF directory below [repositoryRoot].
  static List<String> discover(String repositoryRoot) {
    final root = p.normalize(p.absolute(repositoryRoot));
    final matches = <String>[];
    _collectSmfDirectories(root, matches, isSearchRoot: true);
    matches.sort();
    return List<String>.unmodifiable(matches);
  }

  /// Returns repository paths whose commits apply to this app.
  ///
  /// A root application observes the whole repository. A nested application
  /// always observes its own directory plus [additionalPaths].
  List<String> releaseTriggerPaths(Iterable<String> additionalPaths) {
    final appPath = p.relative(appRoot, from: repositoryRoot).replaceAll(r'\', '/');
    if (appPath == '.') return const <String>[];
    return List<String>.unmodifiable(<String>[
      appPath,
      ...additionalPaths.where((path) => path != appPath),
    ]);
  }

  /// Returns the receipt path for one platform [version].
  String candidatePath({
    required Platform platform,
    required String version,
  }) => p.join(candidates, '${platform.name}-$version.json');

  static String _resolveExplicitSmfDirectory(String start, String smfPath) {
    if (smfPath.trim().isEmpty) {
      throw const SmfError(
        'smf-path must point to an smf directory.',
        'INVALID_SMF_PATH',
      );
    }
    final directory = p.normalize(p.absolute(start, smfPath));
    if (!p.equals(directory, start) && !p.isWithin(start, directory)) {
      throw SmfError(
        'smf-path must stay within the working directory: $start.',
        'INVALID_SMF_PATH',
      );
    }
    _validateSmfDirectory(directory);
    return directory;
  }

  static String _discoverSmfDirectory(String start) {
    if (FileSystemEntity.typeSync(
          start,
          followLinks: false,
        ) !=
        FileSystemEntityType.directory) {
      throw SmfError(
        'The SMF search directory does not exist: $start.',
        'SMF_SEARCH_PATH_NOT_FOUND',
      );
    }

    final matches = <String>[];
    _collectSmfDirectories(start, matches, isSearchRoot: true);
    if (matches.isEmpty) {
      throw SmfError(
        'No smf/config.yaml was found at or below $start. Run '
            '`smf init` from the Flutter app directory or pass --smf-path.',
        'SMF_NOT_FOUND',
      );
    }
    matches.sort();
    if (matches.length > 1) {
      final candidates = matches.map((match) => '  - ${p.relative(match, from: start)}').join('\n');
      throw SmfError(
        'Multiple SMF directories were found below $start:\n$candidates\n'
            'Pass --smf-path with the intended directory.',
        'MULTIPLE_SMF_DIRECTORIES',
      );
    }
    return matches.single;
  }

  static void _collectSmfDirectories(
    String directory,
    List<String> matches, {
    required bool isSearchRoot,
  }) {
    final name = p.basename(directory);
    if (!isSearchRoot && _shouldPrune(name)) return;

    if (name == directoryName) {
      final config = p.join(directory, configFileName);
      if (FileSystemEntity.typeSync(
            config,
            followLinks: false,
          ) ==
          FileSystemEntityType.file) {
        matches.add(p.normalize(p.absolute(directory)));
      }
      return;
    }

    final entries = Directory(directory).listSync(followLinks: false)
      ..sort((left, right) => left.path.compareTo(right.path));
    for (final entry in entries) {
      if (FileSystemEntity.typeSync(
            entry.path,
            followLinks: false,
          ) ==
          FileSystemEntityType.directory) {
        _collectSmfDirectories(entry.path, matches, isSearchRoot: false);
      }
    }
  }

  static bool _shouldPrune(String name) => name.startsWith('.') || _prunedDirectoryNames.contains(name);

  static void _validateSmfDirectory(String directory) {
    if (p.basename(directory) != directoryName) {
      throw SmfError(
        'smf-path must point directly to a directory named "smf": '
            '$directory.',
        'INVALID_SMF_PATH',
      );
    }
    final type = FileSystemEntity.typeSync(directory, followLinks: false);
    if (type == FileSystemEntityType.link) {
      throw const SmfError(
        'The selected smf directory must not be a symbolic link.',
        'INVALID_SMF_PATH',
      );
    }
    if (type != FileSystemEntityType.directory) {
      throw SmfError(
        'The selected smf directory does not exist: $directory.',
        'SMF_NOT_FOUND',
      );
    }
    final config = p.join(directory, configFileName);
    if (FileSystemEntity.typeSync(
          config,
          followLinks: false,
        ) !=
        FileSystemEntityType.file) {
      throw SmfError(
        'The selected directory does not contain config.yaml: $directory.',
        'CONFIG_NOT_FOUND',
      );
    }
  }

  static String _findRepositoryRoot(String appRoot) {
    var current = p.normalize(p.absolute(appRoot));
    while (true) {
      final marker = p.join(current, '.git');
      final type = FileSystemEntity.typeSync(marker, followLinks: false);
      if (type == FileSystemEntityType.directory || type == FileSystemEntityType.file) {
        return current;
      }
      final parent = p.dirname(current);
      if (parent == current) {
        throw SmfError(
          'The SMF app is not inside a Git repository: $appRoot.',
          'GIT_REPOSITORY_NOT_FOUND',
        );
      }
      current = parent;
    }
  }
}
