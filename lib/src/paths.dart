import 'dart:io';

import 'package:path/path.dart' as p;

import 'model.dart';

const String shipDirectoryName = '.ship-my-flutter';

final class ShipPaths {
  const ShipPaths({
    required this.root,
    required this.directory,
    required this.config,
    required this.manifest,
    required this.changelog,
    required this.storeReleaseNotes,
    required this.candidates,
  });

  final String root;
  final String directory;
  final String config;
  final String manifest;
  final String changelog;
  final String storeReleaseNotes;
  final String candidates;
}

ShipPaths resolveShipPaths([String? root]) {
  final resolvedRoot = root ?? Directory.current.path;
  final directory = p.join(resolvedRoot, shipDirectoryName);
  return ShipPaths(
    root: resolvedRoot,
    directory: directory,
    config: p.join(directory, 'config.yaml'),
    manifest: p.join(directory, 'manifest.json'),
    changelog: p.join(directory, 'changelog.json'),
    storeReleaseNotes: p.join(directory, 'store-release-notes.json'),
    candidates: p.join(directory, 'candidates'),
  );
}

String candidatePath(String root, Platform platform, String version) {
  return p.join(
    resolveShipPaths(root).candidates,
    '${platform.name}-$version.json',
  );
}
