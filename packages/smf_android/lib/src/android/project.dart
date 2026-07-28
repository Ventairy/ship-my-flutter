import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';

/// Android project metadata used by Google Play delivery.
final class AndroidProject {
  const AndroidProject._();

  /// Detects one stable version name from conventional project files.
  ///
  /// A literal Gradle `versionName` takes precedence over Flutter's generated
  /// `flutter.versionName` value in `android/local.properties`.
  static Future<String?> detectVersion(String appRoot) async {
    final androidDirectory = p.join(appRoot, 'android');
    final gradleVersions = <String>{};
    for (final path in <String>[
      p.join(androidDirectory, 'app', 'build.gradle.kts'),
      p.join(androidDirectory, 'app', 'build.gradle'),
    ]) {
      final file = File(path);
      if (!(await file.exists())) continue;
      final source = await file.readAsString();
      gradleVersions.addAll(
        _stableVersions(
          RegExp(
            r'''^\s*versionName\s*(?:=\s*)?["']([^"'$]+)["']\s*$''',
            multiLine: true,
          ).allMatches(source).map((match) => match.group(1)),
        ),
      );
    }
    if (gradleVersions.isNotEmpty) {
      return _oneVersion(gradleVersions);
    }

    final localProperties = File(
      p.join(androidDirectory, 'local.properties'),
    );
    if (!(await localProperties.exists())) return null;
    final source = await localProperties.readAsString();
    final versions = _stableVersions(
      RegExp(
        r'^\s*flutter\.versionName\s*=\s*(\S+)\s*$',
        multiLine: true,
      ).allMatches(source).map((match) => match.group(1)),
    );
    return versions.isEmpty ? null : _oneVersion(versions);
  }

  static Set<String> _stableVersions(Iterable<String?> values) =>
      values.whereType<String>().map((value) => value.trim()).where(_isStableVersion).toSet();

  static bool _isStableVersion(String value) => RegExp(
    r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$',
  ).hasMatch(value);

  static String _oneVersion(Set<String> versions) {
    if (versions.length != 1) {
      throw SmfError(
        'The Android project contains multiple versionName values: '
            '${versions.toList()..sort()}. Pass --android-version explicitly.',
        'ANDROID_VERSION_AMBIGUOUS',
      );
    }
    return versions.single;
  }

  /// Resolves the application ID used by Google Play.
  static Future<String> resolvePackageName(
    String appRoot,
    AndroidConfig config, {
    String? flavor,
  }) async {
    final configuredPackageName = config.packageName;
    if (configuredPackageName != null) return configuredPackageName;
    SmfError.check(
      flavor == null,
      'platforms.android.package_name is required when flavor is configured.',
      'PACKAGE_NAME_REQUIRED',
    );
    final androidApp = p.join(appRoot, 'android', 'app');
    final candidates = <String>[
      p.join(androidApp, 'build.gradle.kts'),
      p.join(androidApp, 'build.gradle'),
    ];
    for (final path in candidates) {
      if (!(await File(path).exists())) continue;
      final source = await File(path).readAsString();
      final match = RegExp(
        r'''applicationId\s*(?:=|\s)\s*["']([^"'$]+)["']''',
      ).firstMatch(source);
      final packageName = match?.group(1)?.trim();
      if (packageName != null && packageName.isNotEmpty) return packageName;
    }
    throw const SmfError(
      'Could not detect the Android application ID. Set '
          'platforms.android.package_name in smf/config.yaml.',
      'PACKAGE_NAME_REQUIRED',
    );
  }
}
