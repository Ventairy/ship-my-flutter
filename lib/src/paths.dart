import 'dart:io';

import 'package:path/path.dart' as p;

import 'error.dart';
import 'model.dart';

const String smfDirectoryName = 'smf';
const String smfConfigFileName = 'config.yaml';

const Set<String> _prunedDirectoryNames = <String>{
  '.dart_tool',
  '.fvm',
  '.git',
  '.idea',
  '.pub-cache',
  '.vscode',
  'build',
  'node_modules',
};

/// Resolved repository, Flutter app, and SMF state paths.
final class SmfPaths {
  const SmfPaths({
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

  /// Git repository root used for history, branches, commits, and pushes.
  final String repositoryRoot;

  /// Flutter application root, which is the parent of [directory].
  final String appRoot;

  /// Selected `smf` directory.
  final String directory;
  final String config;
  final String manifest;
  final String changelog;
  final String storeReleaseNotes;
  final String candidates;
  final String hooks;
  final String beforeCreatePrHook;
  final String beforeBuildHook;
}

/// Discovers one `smf/config.yaml` at or below [workingDirectory].
///
/// Pass [smfPath] to select a specific forward `smf` directory when a
/// repository contains multiple Flutter apps.
SmfPaths resolveSmfPaths(String? workingDirectory, {String? smfPath}) {
  final start = p.normalize(
    p.absolute(workingDirectory ?? Directory.current.path),
  );
  final directory = smfPath == null
      ? _discoverSmfDirectory(start)
      : _resolveExplicitSmfDirectory(start, smfPath);
  return _pathsForDirectory(directory);
}

SmfPaths smfPathsForApp([String? appRoot]) {
  final resolvedAppRoot = p.normalize(
    p.absolute(appRoot ?? Directory.current.path),
  );
  return _pathsForDirectory(p.join(resolvedAppRoot, smfDirectoryName));
}

String candidatePath(
  String workingDirectory,
  Platform platform,
  String version, {
  String? smfPath,
}) {
  return p.join(
    resolveSmfPaths(workingDirectory, smfPath: smfPath).candidates,
    '${platform.name}-$version.json',
  );
}

SmfPaths _pathsForDirectory(String directory) {
  final normalizedDirectory = p.normalize(p.absolute(directory));
  final appRoot = p.dirname(normalizedDirectory);
  final repositoryRoot = _findRepositoryRoot(appRoot);
  final hooks = p.join(normalizedDirectory, 'hooks');
  return SmfPaths(
    repositoryRoot: repositoryRoot,
    appRoot: appRoot,
    directory: normalizedDirectory,
    config: p.join(normalizedDirectory, smfConfigFileName),
    manifest: p.join(normalizedDirectory, 'manifest.json'),
    changelog: p.join(normalizedDirectory, 'changelog.json'),
    storeReleaseNotes: p.join(normalizedDirectory, 'store-release-notes.json'),
    candidates: p.join(normalizedDirectory, 'candidates'),
    hooks: hooks,
    beforeCreatePrHook: p.join(hooks, 'before_create_pr.dart'),
    beforeBuildHook: p.join(hooks, 'before_build.dart'),
  );
}

String _resolveExplicitSmfDirectory(String start, String smfPath) {
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

String _discoverSmfDirectory(String start) {
  if (FileSystemEntity.typeSync(start, followLinks: false) !=
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
      'No smf/config.yaml was found at or below $start. Run `smf init` from '
          'the Flutter app directory or pass --smf-path.',
      'SMF_NOT_FOUND',
    );
  }
  matches.sort();
  if (matches.length > 1) {
    final candidates = matches
        .map((String match) => '  - ${p.relative(match, from: start)}')
        .join('\n');
    throw SmfError(
      'Multiple SMF directories were found below $start:\n$candidates\n'
          'Pass --smf-path with the intended directory.',
      'MULTIPLE_SMF_DIRECTORIES',
    );
  }
  return matches.single;
}

void _collectSmfDirectories(
  String directory,
  List<String> matches, {
  required bool isSearchRoot,
}) {
  final name = p.basename(directory);
  if (!isSearchRoot && _shouldPrune(name)) return;

  if (name == smfDirectoryName) {
    final config = p.join(directory, smfConfigFileName);
    if (FileSystemEntity.typeSync(config, followLinks: false) ==
        FileSystemEntityType.file) {
      matches.add(p.normalize(p.absolute(directory)));
    }
    return;
  }

  final entries = Directory(directory).listSync(followLinks: false)
    ..sort(
      (FileSystemEntity left, FileSystemEntity right) =>
          left.path.compareTo(right.path),
    );
  for (final entry in entries) {
    if (FileSystemEntity.typeSync(entry.path, followLinks: false) ==
        FileSystemEntityType.directory) {
      _collectSmfDirectories(entry.path, matches, isSearchRoot: false);
    }
  }
}

bool _shouldPrune(String name) =>
    name.startsWith('.') || _prunedDirectoryNames.contains(name);

void _validateSmfDirectory(String directory) {
  if (p.basename(directory) != smfDirectoryName) {
    throw SmfError(
      'smf-path must point directly to a directory named "smf": $directory.',
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
  final config = p.join(directory, smfConfigFileName);
  if (FileSystemEntity.typeSync(config, followLinks: false) !=
      FileSystemEntityType.file) {
    throw SmfError(
      'The selected directory does not contain config.yaml: $directory.',
      'CONFIG_NOT_FOUND',
    );
  }
}

String _findRepositoryRoot(String appRoot) {
  var current = p.normalize(p.absolute(appRoot));
  while (true) {
    final marker = p.join(current, '.git');
    final type = FileSystemEntity.typeSync(marker, followLinks: false);
    if (type == FileSystemEntityType.directory ||
        type == FileSystemEntityType.file) {
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
