import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/serialization.dart';
import 'package:smf_engine/src/templates.dart';

final class InitOptions {
  const InitOptions({
    required this.appRoot,
    this.currentVersion,
    this.bundleId,
    this.packageName,
    this.force = false,
    this.workflowOnly = false,
  });

  final String appRoot;
  final String? currentVersion;
  final String? bundleId;
  final String? packageName;
  final bool force;
  final bool workflowOnly;
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
  final workflowPath = p.join(
    paths.repositoryRoot,
    '.github',
    'workflows',
    'smf.yml',
  );
  final smfPath = p
      .relative(paths.directory, from: paths.repositoryRoot)
      .replaceAll(r'\', '/');
  invariant(
    !smfPath.contains('\n') &&
        !smfPath.contains('\r') &&
        !smfPath.contains(r'${{'),
    'The SMF path cannot contain a newline or GitHub expression opener.',
    'INVALID_SMF_PATH',
  );
  if (options.workflowOnly) {
    invariant(
      !options.force &&
          options.currentVersion == null &&
          options.bundleId == null &&
          options.packageName == null,
      '--workflow-only cannot be combined with --force, --current-version, '
          '--bundle-id, or --package-name.',
      'INVALID_INIT_OPTIONS',
    );
    invariant(
      await fileExists(paths.config),
      '${paths.config} does not exist. Run `smf init` first.',
      'NOT_INITIALIZED',
    );
    await File(workflowPath).parent.create(recursive: true);
    await File(
      workflowPath,
    ).writeAsString(generatedWorkflowYaml(smfPath: smfPath));
    return;
  }
  if (await fileExists(paths.config) && !options.force) {
    throw SmfError(
      '${paths.config} already exists. Pass --force to replace the generated '
          'configuration and workflow, or --workflow-only to refresh only '
          'the workflow.',
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
  final enableIos = await Directory(p.join(appRoot, 'ios')).exists();
  final enableAndroid = await Directory(p.join(appRoot, 'android')).exists();
  invariant(
    enableIos || enableAndroid,
    'The Flutter app must contain an ios or android platform directory.',
    'SUPPORTED_PLATFORM_NOT_FOUND',
  );

  await File(paths.config).parent.create(recursive: true);
  final writes = <Future<void>>[
    File(paths.config).writeAsString(
      generatedConfigYaml(
        initialVersion: parsedVersion.toString(),
        enableIos: enableIos,
        enableAndroid: enableAndroid,
        bundleId: options.bundleId,
        packageName: options.packageName,
      ),
    ),
  ];
  if (options.force || !(await fileExists(workflowPath))) {
    await File(workflowPath).parent.create(recursive: true);
    writes.add(
      File(workflowPath).writeAsString(generatedWorkflowYaml(smfPath: smfPath)),
    );
  }
  await Future.wait(writes);
}
