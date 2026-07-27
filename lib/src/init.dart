import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

import 'error.dart';
import 'paths.dart';
import 'serialization.dart';
import 'templates.dart';

final class InitOptions {
  const InitOptions({
    required this.appRoot,
    this.currentVersion,
    this.bundleId,
    this.force = false,
  });

  final String appRoot;
  final String? currentVersion;
  final String? bundleId;
  final bool force;
}

Future<String?> _detectFlutterVersion(String root) async {
  final pubspecPath = p.join(root, 'pubspec.yaml');
  if (!(await fileExists(pubspecPath))) return null;
  final value = await readYaml(pubspecPath);
  if (value is! Map<Object?, Object?>) return null;
  final rawVersion = value['version'];
  if (rawVersion is! String) return null;
  final versionValue = rawVersion.split('+').first;
  try {
    final version = Version.parse(versionValue);
    return version.isPreRelease ? null : version.toString();
  } on FormatException {
    return null;
  }
}

Future<void> initialize(InitOptions options) async {
  final appRoot = p.normalize(p.absolute(options.appRoot));
  final paths = smfPathsForApp(appRoot);
  if (!(await fileExists(p.join(appRoot, 'pubspec.yaml')))) {
    throw SmfError(
      'No pubspec.yaml exists in the Flutter app directory: $appRoot.',
      'FLUTTER_APP_NOT_FOUND',
    );
  }
  if (await fileExists(paths.config) && !options.force) {
    throw SmfError(
      '${paths.config} already exists. Pass --force to replace the generated '
          'configuration and workflow.',
      'ALREADY_INITIALIZED',
    );
  }

  final version =
      options.currentVersion ?? await _detectFlutterVersion(appRoot) ?? '0.0.0';
  Version parsedVersion;
  try {
    parsedVersion = Version.parse(version);
  } on FormatException {
    throw SmfError(
      '$version must be a stable major.minor.patch version',
      'SEMVER',
    );
  }
  invariant(
    !parsedVersion.isPreRelease && parsedVersion.build.isEmpty,
    '$version must be a stable major.minor.patch version',
    'SEMVER',
  );
  final workflowPath = p.join(
    paths.repositoryRoot,
    '.github',
    'workflows',
    'smf.yml',
  );

  await File(paths.config).parent.create(recursive: true);
  final writes = <Future<void>>[
    File(paths.config).writeAsString(
      generatedConfigYaml(
        initialVersion: parsedVersion.toString(),
        bundleId: options.bundleId,
      ),
    ),
  ];
  if (options.force || !(await fileExists(workflowPath))) {
    await File(workflowPath).parent.create(recursive: true);
    writes.add(File(workflowPath).writeAsString(workflowTemplate));
  }
  await Future.wait(writes);
}
