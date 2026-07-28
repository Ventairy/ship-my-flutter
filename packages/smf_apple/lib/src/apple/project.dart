import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart' hide Platform;

/// Xcode project metadata used by Apple delivery.
final class AppleProject {
  const AppleProject._();

  /// Detects one stable marketing version from conventional project files.
  ///
  /// Literal `MARKETING_VERSION` build settings take precedence over a literal
  /// `CFBundleShortVersionString`. Dynamic build-setting references are
  /// ignored.
  static Future<String?> detectVersion(String appRoot) async {
    final iosDirectory = Directory(p.join(appRoot, 'ios'));
    if (!(await iosDirectory.exists())) return null;
    final projects =
        (await iosDirectory.list(followLinks: false).toList())
            .whereType<Directory>()
            .where((entry) => p.extension(entry.path) == '.xcodeproj')
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));
    final projectVersions = <String>{};
    for (final project in projects) {
      final settings = File(p.join(project.path, 'project.pbxproj'));
      if (!(await settings.exists())) continue;
      final source = await settings.readAsString();
      projectVersions.addAll(
        _stableVersions(
          RegExp(
            r'^\s*MARKETING_VERSION\s*=\s*"?([^";]+)"?;\s*$',
            multiLine: true,
          ).allMatches(source).map((match) => match.group(1)),
        ),
      );
    }
    if (projectVersions.isNotEmpty) {
      return _oneVersion(projectVersions);
    }

    final infoPlist = File(p.join(iosDirectory.path, 'Runner', 'Info.plist'));
    if (!(await infoPlist.exists())) return null;
    final source = await infoPlist.readAsString();
    final match = RegExp(
      r'<key>\s*CFBundleShortVersionString\s*</key>\s*'
      r'<string>\s*([^<$]+)\s*</string>',
      multiLine: true,
    ).firstMatch(source);
    final versions = _stableVersions(<String?>[match?.group(1)]);
    return versions.isEmpty ? null : versions.single;
  }

  static Set<String> _stableVersions(Iterable<String?> values) => <String>{
    for (final value in values)
      if (value?.trim() case final candidate? when _isStableVersion(candidate)) candidate,
  };

  static bool _isStableVersion(String value) => RegExp(
    r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$',
  ).hasMatch(value);

  static String _oneVersion(Set<String> versions) {
    if (versions.length != 1) {
      throw SmfError(
        'The iOS project contains multiple MARKETING_VERSION values: '
            '${versions.toList()..sort()}. Pass --ios-version explicitly.',
        'IOS_VERSION_AMBIGUOUS',
      );
    }
    return versions.single;
  }

  /// Resolves the main application bundle identifier.
  static Future<String> resolveBundleId(
    String appRoot,
    IosConfig config, {
    String? flavor,
    ProcessRunner processRunner = const SystemProcessRunner(),
    bool? isMacOS,
  }) async {
    if (config.bundleId != null) return config.bundleId!;
    if (!(isMacOS ?? Platform.isMacOS)) {
      throw const SmfError(
        'platforms.ios.bundle_id is required when configuration is validated '
            'outside macOS.',
        'BUNDLE_ID_REQUIRED',
      );
    }

    final projectRoot = p.normalize(p.absolute(appRoot));
    final iosDirectory = p.join(projectRoot, 'ios');
    final container = await _xcodeContainer(iosDirectory);
    final scheme = flavor ?? 'Runner';
    final arguments = <String>[
      container.option,
      container.path,
      '-scheme',
      scheme,
      '-configuration',
      'Release',
      '-sdk',
      'iphoneos',
      '-showBuildSettings',
    ];
    final result = await processRunner.run(
      'xcodebuild',
      arguments,
      options: RunOptions(workingDirectory: projectRoot),
    );
    final matches = RegExp(
      r'PRODUCT_BUNDLE_IDENTIFIER = (.+)$',
      multiLine: true,
    ).allMatches(result.stdout);
    final bundleId = matches.isEmpty ? null : matches.last.group(1)?.trim();
    if (bundleId == null || bundleId.isEmpty || bundleId.contains(r'$(')) {
      throw const SmfError(
        'Could not detect PRODUCT_BUNDLE_IDENTIFIER. Set '
            'platforms.ios.bundle_id in smf/config.yaml.',
        'BUNDLE_ID_REQUIRED',
      );
    }
    return bundleId;
  }

  /// Resolves every signed app or extension bundle ID in the Release scheme.
  static Future<Set<String>> resolveSigningBundleIds(
    String appRoot, {
    required String mainBundleId,
    String? flavor,
    ProcessRunner processRunner = const SystemProcessRunner(),
    bool? isMacOS,
  }) async {
    if (!(isMacOS ?? Platform.isMacOS)) {
      throw const SmfError(
        'Apple signing-target discovery requires a macOS runner.',
        'MACOS_REQUIRED',
      );
    }
    SmfError.check(
      _isExplicitBundleId(mainBundleId),
      'The configured iOS bundle identifier is not an explicit bundle ID: '
          '$mainBundleId.',
      'BUNDLE_ID_INVALID',
    );
    final projectRoot = p.normalize(p.absolute(appRoot));
    final iosDirectory = p.join(projectRoot, 'ios');
    final container = await _xcodeContainer(iosDirectory);
    final scheme = flavor ?? 'Runner';
    final arguments = <String>[
      container.option,
      container.path,
      '-scheme',
      scheme,
      '-configuration',
      'Release',
      '-sdk',
      'iphoneos',
      '-showBuildSettings',
      '-json',
    ];
    final result = await processRunner.run(
      'xcodebuild',
      arguments,
      options: RunOptions(workingDirectory: projectRoot),
    );
    Object? decoded;
    try {
      decoded = jsonDecode(result.stdout);
    } on FormatException catch (error) {
      throw SmfError(
        'Xcode returned malformed signing-target build settings.',
        'XCODE_BUILD_SETTINGS_INVALID',
        cause: error,
      );
    }
    if (decoded is! List<Object?>) {
      throw const SmfError(
        'Xcode signing-target build settings are not a list.',
        'XCODE_BUILD_SETTINGS_INVALID',
      );
    }
    final bundleIds = <String>{};
    final appBundleIds = <String>{};
    for (final item in decoded) {
      if (item is! Map<Object?, Object?>) continue;
      final settingsValue = item['buildSettings'];
      if (settingsValue is! Map<Object?, Object?>) continue;
      final wrapperExtension = settingsValue['WRAPPER_EXTENSION'];
      final signingAllowed = settingsValue['CODE_SIGNING_ALLOWED'];
      final signingRequired = settingsValue['CODE_SIGNING_REQUIRED'];
      if ((wrapperExtension != 'app' && wrapperExtension != 'appex') ||
          signingAllowed == 'NO' ||
          signingRequired == 'NO') {
        continue;
      }
      final bundleId = settingsValue['PRODUCT_BUNDLE_IDENTIFIER'];
      final target = item['target'] is String ? item['target']! as String : 'unknown target';
      if (bundleId is! String || !_isExplicitBundleId(bundleId.trim())) {
        throw SmfError(
          'Xcode target "$target" does not resolve to an explicit Release '
              'bundle identifier.',
          'XCODE_BUNDLE_ID_INVALID',
        );
      }
      final resolved = bundleId.trim();
      bundleIds.add(resolved);
      if (wrapperExtension == 'app') appBundleIds.add(resolved);
    }
    SmfError.check(
      appBundleIds.contains(mainBundleId),
      appBundleIds.isEmpty
          ? 'Xcode did not report a signed application target for the Release '
                'scheme.'
          : 'The configured iOS bundle ID $mainBundleId does not match a signed '
                'application target in Xcode: ${appBundleIds.toList()..sort()}.',
      'BUNDLE_ID_MISMATCH',
    );
    return bundleIds;
  }

  static bool _isExplicitBundleId(String value) {
    if (value.isEmpty ||
        value.contains(r'$') ||
        value.contains('*') ||
        value.startsWith('.') ||
        value.endsWith('.') ||
        value.contains('..')) {
      return false;
    }
    return value
        .split('.')
        .every(
          (component) => RegExp(r'^[A-Za-z0-9][A-Za-z0-9-]*$').hasMatch(component),
        );
  }

  static Future<({String option, String path})> _xcodeContainer(
    String iosDirectory,
  ) async {
    final directory = Directory(iosDirectory);
    if (!await directory.exists()) {
      throw SmfError(
        'No iOS directory found at $iosDirectory.',
        'XCODE_PROJECT_NOT_FOUND',
      );
    }
    final entries =
        (await directory.list(followLinks: false).where((entry) => entry is Directory).cast<Directory>().toList())
          ..sort((left, right) => left.path.compareTo(right.path));
    final workspaces = entries.where((item) => item.path.endsWith('.xcworkspace')).toList();
    final projects = entries.where((item) => item.path.endsWith('.xcodeproj')).toList();

    Directory? select(List<Directory> candidates, String preferredName) {
      final preferred = candidates.where((item) => p.basename(item.path) == preferredName).firstOrNull;
      if (preferred != null) return preferred;
      if (candidates.length == 1) return candidates.single;
      if (candidates.length > 1) {
        throw SmfError(
          'Multiple Xcode containers were found in $iosDirectory: '
              '${candidates.map((item) => p.basename(item.path)).join(', ')}.',
          'XCODE_PROJECT_AMBIGUOUS',
        );
      }
      return null;
    }

    final workspace = select(workspaces, 'Runner.xcworkspace');
    if (workspace != null) {
      return (option: '-workspace', path: workspace.path);
    }
    final project = select(projects, 'Runner.xcodeproj');
    if (project != null) return (option: '-project', path: project.path);
    throw SmfError(
      'No Xcode workspace or project found in $iosDirectory.',
      'XCODE_PROJECT_NOT_FOUND',
    );
  }
}
