import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/init_options.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/templates.dart';
import 'package:smf_engine/src/yaml_file.dart';

/// Initializes SMF state and its optional app-scoped GitHub Actions wrapper.
final class RepositoryInitializer {
  const RepositoryInitializer._();

  static Future<String?> _detectFlutterVersion(String root) async {
    final pubspecPath = p.join(root, 'pubspec.yaml');
    if (!(await File(pubspecPath).exists())) return null;
    final value = await YamlFile(pubspecPath).read();
    if (value is! Map<String, Object?>) return null;
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
    final value = await YamlFile(pubspecPath).read();
    final name = value is Map<String, Object?> ? value['name'] : null;
    if (name is! String || name.trim().isEmpty) {
      throw SmfError(
        'Could not read a package name from $pubspecPath. Pass --app-id.',
        SmfErrorCode.appIdNotFound,
      );
    }
    return _validAppId(name.trim());
  }

  static String _validAppId(String value) {
    if (!RegExp(r'^[a-z0-9][a-z0-9_-]*$').hasMatch(value)) {
      throw SmfError(
        '$value is not a valid app ID. Use lowercase letters, numbers, '
        'underscores, or hyphens, beginning with a letter or number.',
        SmfErrorCode.invalidAppId,
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
        SmfErrorCode.semver,
      );
    }
    SmfError.check(
      !parsedVersion.isPreRelease && parsedVersion.build.isEmpty,
      '$value must be a stable major.minor.patch version',
      SmfErrorCode.semver,
    );
    return parsedVersion.toString();
  }

  /// Initializes the repository according to [options].
  static Future<void> initialize(InitOptions options) async {
    final appRoot = p.normalize(p.absolute(options.appRoot));
    final paths = SmfPaths.forApp(appRoot);
    if (!(await File(p.join(appRoot, 'pubspec.yaml')).exists())) {
      throw SmfError(
        'No pubspec.yaml exists in the Flutter app directory: $appRoot.',
        SmfErrorCode.flutterAppNotFound,
      );
    }
    final doesConfigExist = await File(paths.config).exists();
    final configuredAppId = doesConfigExist ? (await SmfState.config(paths.directory)).appId : null;
    if (configuredAppId != null && options.appId != null && options.appId != configuredAppId) {
      throw SmfError(
        'app_id is permanent after initialization. Configured app_id is '
        '"$configuredAppId", not "${options.appId}".',
        SmfErrorCode.appIdImmutable,
      );
    }
    final appId = _validAppId(
      options.appId ?? configuredAppId ?? await _detectFlutterPackageName(appRoot),
    );
    for (final directory in SmfPaths.discover(paths.repositoryRoot)) {
      if (p.equals(directory, paths.directory)) continue;
      final value = await YamlFile(p.join(directory, SmfPaths.configFileName)).read();
      final otherAppId = value is Map<String, Object?> ? value['app_id'] : null;
      if (otherAppId == appId) {
        throw SmfError(
          'app_id "$appId" is already used by '
          '${p.relative(p.dirname(directory), from: paths.repositoryRoot)}. '
          'Pass a different --app-id.',
          SmfErrorCode.appIdConflict,
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
      SmfErrorCode.invalidSmfPath,
    );
    SmfError.check(
      options.version == null || options.platformVersions.isEmpty,
      '--version cannot be combined with a platform-specific version option.',
      SmfErrorCode.invalidInitOptions,
    );
    if (options.shouldOnlyUpdateGitHubActions) {
      SmfError.check(
        options.shouldCreateGitHubActions &&
            !options.shouldOverwriteExistingFiles &&
            options.version == null &&
            options.platformVersions.isEmpty &&
            options.selectedPlatform == null &&
            options.appId == null &&
            options.iosBundleId == null &&
            options.androidPackageName == null,
        '--github-actions cannot be combined with --force, --app-id, --version, '
        'platform selection or version options, --ios-bundle-id, or '
        '--android-package-name.',
        SmfErrorCode.invalidInitOptions,
      );
      SmfError.check(
        doesConfigExist,
        '${paths.config} does not exist. Run `smf init` first.',
        SmfErrorCode.notInitialized,
      );
      await File(workflowPath).parent.create(recursive: true);
      await File(
        workflowPath,
      ).writeAsString(SmfTemplates.workflowYaml(smfPath: smfPath, appId: appId));
      return;
    }
    if (doesConfigExist && !options.shouldOverwriteExistingFiles) {
      throw SmfError(
        '${paths.config} already exists. Pass --force to replace the generated '
        'configuration and workflow, or --github-actions to create only '
        'the GitHub Actions workflow.',
        SmfErrorCode.alreadyInitialized,
      );
    }

    final hasIos = await Directory(p.join(appRoot, 'ios')).exists();
    final hasAndroid = await Directory(p.join(appRoot, 'android')).exists();
    final shouldEnableIos =
        hasIos && (options.selectedPlatform == null || options.selectedPlatform == ReleasePlatform.ios);
    final shouldEnableAndroid =
        hasAndroid && (options.selectedPlatform == null || options.selectedPlatform == ReleasePlatform.android);
    if (options.selectedPlatform case final selectedPlatform?) {
      SmfError.check(
        selectedPlatform == ReleasePlatform.ios ? hasIos : hasAndroid,
        'The selected ${selectedPlatform.displayName} platform requires an '
        '${selectedPlatform.value} directory.',
        SmfErrorCode.unsupportedInitPlatform,
      );
    }
    SmfError.check(
      shouldEnableIos || shouldEnableAndroid,
      'The Flutter app must contain an ios or android platform directory.',
      SmfErrorCode.supportedPlatformNotFound,
    );
    SmfError.check(
      shouldEnableIos || (!options.platformVersions.containsKey(ReleasePlatform.ios) && options.iosBundleId == null),
      'iOS initializer options require an ios platform directory.',
      SmfErrorCode.unsupportedInitPlatform,
    );
    SmfError.check(
      shouldEnableAndroid ||
          (!options.platformVersions.containsKey(ReleasePlatform.android) && options.androidPackageName == null),
      'Android initializer options require an android platform directory.',
      SmfErrorCode.unsupportedInitPlatform,
    );
    final detectedVersion = await _detectFlutterVersion(appRoot) ?? '0.0.0';
    final iosVersion = shouldEnableIos
        ? _stableVersion(
            options.version ??
                options.platformVersions[ReleasePlatform.ios] ??
                await options.platformVersionDetectors[ReleasePlatform.ios]?.call(
                  appRoot,
                ) ??
                detectedVersion,
          )
        : null;
    final androidVersion = shouldEnableAndroid
        ? _stableVersion(
            options.version ??
                options.platformVersions[ReleasePlatform.android] ??
                await options.platformVersionDetectors[ReleasePlatform.android]?.call(
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
    if (options.shouldCreateGitHubActions &&
        (options.shouldOverwriteExistingFiles || !(await File(workflowPath).exists()))) {
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
