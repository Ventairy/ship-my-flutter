import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/serialization.dart';
import 'package:smf_engine/src/templates.dart';

/// Inputs used to initialize one Flutter application.
final class InitOptions {
  const InitOptions({
    required this.appRoot,
    this.appId,
    this.version,
    this.platformVersions = const <Platform, String>{},
    this.platformVersionDetectors = const <Platform, Future<String?> Function(String appRoot)>{},
    this.iosBundleId,
    this.androidPackageName,
    this.force = false,
    this.githubActionsOnly = false,
  });

  final String appRoot;
  final String? appId;
  final String? version;
  final Map<Platform, String> platformVersions;
  final Map<Platform, Future<String?> Function(String appRoot)> platformVersionDetectors;
  final String? iosBundleId;
  final String? androidPackageName;
  final bool force;
  final bool githubActionsOnly;
}

/// Initializes SMF state and the app-scoped GitHub Actions workflow.
final class RepositoryInitializer {
  const RepositoryInitializer._();

  static Future<String?> _detectFlutterVersion(String root) async {
    final pubspecPath = p.join(root, 'pubspec.yaml');
    if (!(await SmfFileSystem.exists(pubspecPath))) return null;
    final value = await SmfFileSystem.readYaml(pubspecPath);
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

  static Future<String> _detectFlutterPackageName(String root) async {
    final pubspecPath = p.join(root, 'pubspec.yaml');
    final value = await SmfFileSystem.readYaml(pubspecPath);
    final name = value is Map<Object?, Object?> ? value['name'] : null;
    if (name is! String || name.trim().isEmpty) {
      throw SmfError(
        'Could not read a package name from $pubspecPath. Pass --app-id.',
        'APP_ID_NOT_FOUND',
      );
    }
    return _validAppId(name.trim());
  }

  static String _validAppId(String value) {
    if (!RegExp(r'^[a-z0-9][a-z0-9_-]*$').hasMatch(value)) {
      throw SmfError(
        '$value is not a valid app ID. Use lowercase letters, numbers, '
            'underscores, or hyphens, beginning with a letter or number.',
        'INVALID_APP_ID',
      );
    }
    return value;
  }

  static String _stableVersion(String value) {
    Version parsedVersion;
    try {
      parsedVersion = Version.parse(value);
    } on FormatException {
      throw SmfError(
        '$value must be a stable major.minor.patch version',
        'SEMVER',
      );
    }
    SmfError.check(
      !parsedVersion.isPreRelease && parsedVersion.build.isEmpty,
      '$value must be a stable major.minor.patch version',
      'SEMVER',
    );
    return parsedVersion.toString();
  }

  /// Initializes the repository according to [options].
  static Future<void> initialize(InitOptions options) async {
    final appRoot = p.normalize(p.absolute(options.appRoot));
    final paths = SmfPaths.forApp(appRoot);
    if (!(await SmfFileSystem.exists(p.join(appRoot, 'pubspec.yaml')))) {
      throw SmfError(
        'No pubspec.yaml exists in the Flutter app directory: $appRoot.',
        'FLUTTER_APP_NOT_FOUND',
      );
    }
    final existingConfig = await SmfFileSystem.exists(paths.config);
    final configuredAppId = existingConfig ? (await SmfState.config(paths.directory)).appId : null;
    if (configuredAppId != null && options.appId != null && options.appId != configuredAppId) {
      throw SmfError(
        'app_id is permanent after initialization. Configured app_id is '
            '"$configuredAppId", not "${options.appId}".',
        'APP_ID_IMMUTABLE',
      );
    }
    final appId = _validAppId(
      options.appId ?? configuredAppId ?? await _detectFlutterPackageName(appRoot),
    );
    for (final directory in SmfPaths.discover(paths.repositoryRoot)) {
      if (p.equals(directory, paths.directory)) continue;
      final value = await SmfFileSystem.readYaml(
        p.join(directory, SmfPaths.configFileName),
      );
      final otherAppId = value is Map<Object?, Object?> ? value['app_id'] : null;
      if (otherAppId == appId) {
        throw SmfError(
          'app_id "$appId" is already used by '
              '${p.relative(p.dirname(directory), from: paths.repositoryRoot)}. '
              'Pass a different --app-id.',
          'APP_ID_CONFLICT',
        );
      }
    }
    final workflowPath = p.join(
      paths.repositoryRoot,
      '.github',
      'workflows',
      SmfTemplates.workflowFileName(appId),
    );
    final smfPath = p.relative(paths.directory, from: paths.repositoryRoot).replaceAll(r'\', '/');
    SmfError.check(
      !smfPath.contains('\n') && !smfPath.contains('\r') && !smfPath.contains(r'${{'),
      'The SMF path cannot contain a newline or GitHub expression opener.',
      'INVALID_SMF_PATH',
    );
    SmfError.check(
      options.version == null || options.platformVersions.isEmpty,
      '--version cannot be combined with a platform-specific version option.',
      'INVALID_INIT_OPTIONS',
    );
    if (options.githubActionsOnly) {
      SmfError.check(
        !options.force &&
            options.version == null &&
            options.platformVersions.isEmpty &&
            options.appId == null &&
            options.iosBundleId == null &&
            options.androidPackageName == null,
        '--github-actions cannot be combined with --force, --app-id, --version, '
            'platform-specific version options, --ios-bundle-id, or '
            '--android-package-name.',
        'INVALID_INIT_OPTIONS',
      );
      SmfError.check(
        existingConfig,
        '${paths.config} does not exist. Run `smf init` first.',
        'NOT_INITIALIZED',
      );
      await File(workflowPath).parent.create(recursive: true);
      await File(
        workflowPath,
      ).writeAsString(SmfTemplates.workflowYaml(smfPath: smfPath, appId: appId));
      return;
    }
    if (existingConfig && !options.force) {
      throw SmfError(
        '${paths.config} already exists. Pass --force to replace the generated '
            'configuration and workflow, or --github-actions to create only '
            'the GitHub Actions workflow.',
        'ALREADY_INITIALIZED',
      );
    }

    final enableIos = await Directory(p.join(appRoot, 'ios')).exists();
    final enableAndroid = await Directory(p.join(appRoot, 'android')).exists();
    SmfError.check(
      enableIos || enableAndroid,
      'The Flutter app must contain an ios or android platform directory.',
      'SUPPORTED_PLATFORM_NOT_FOUND',
    );
    SmfError.check(
      enableIos || (!options.platformVersions.containsKey(Platform.ios) && options.iosBundleId == null),
      'iOS initializer options require an ios platform directory.',
      'UNSUPPORTED_INIT_PLATFORM',
    );
    SmfError.check(
      enableAndroid || (!options.platformVersions.containsKey(Platform.android) && options.androidPackageName == null),
      'Android initializer options require an android platform directory.',
      'UNSUPPORTED_INIT_PLATFORM',
    );
    final detectedVersion = await _detectFlutterVersion(appRoot) ?? '0.0.0';
    final iosVersion = enableIos
        ? _stableVersion(
            options.version ??
                options.platformVersions[Platform.ios] ??
                await options.platformVersionDetectors[Platform.ios]?.call(
                  appRoot,
                ) ??
                detectedVersion,
          )
        : null;
    final androidVersion = enableAndroid
        ? _stableVersion(
            options.version ??
                options.platformVersions[Platform.android] ??
                await options.platformVersionDetectors[Platform.android]?.call(
                  appRoot,
                ) ??
                detectedVersion,
          )
        : null;

    await File(paths.config).parent.create(recursive: true);
    final writes = <Future<void>>[
      File(paths.config).writeAsString(
        SmfTemplates.configYaml(
          appId: appId,
          iosInitialVersion: iosVersion,
          androidInitialVersion: androidVersion,
          bundleId: options.iosBundleId,
          packageName: options.androidPackageName,
        ),
      ),
    ];
    if (options.force || !(await SmfFileSystem.exists(workflowPath))) {
      await File(workflowPath).parent.create(recursive: true);
      writes.add(
        File(
          workflowPath,
        ).writeAsString(SmfTemplates.workflowYaml(smfPath: smfPath, appId: appId)),
      );
    }
    await Future.wait(writes);
  }
}
