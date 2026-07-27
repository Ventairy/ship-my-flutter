import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';

/// Resolves the Google Play package name.
typedef ResolvePackageName =
    Future<String> Function(
      String appRoot,
      AndroidConfig config, {
      String? flavor,
    });

/// Resolves the Android application ID used by Google Play.
Future<String> resolvePackageName(
  String appRoot,
  AndroidConfig config, {
  String? flavor,
}) async {
  if (config.packageName != null) return config.packageName!;
  invariant(
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
