import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart' hide Platform;

typedef ResolveBundleId =
    Future<String> Function(String appRoot, IosConfig config, {String? flavor});

Future<String> resolveBundleId(
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
  final entries = await Directory(iosDirectory).list().toList();
  final workspace = entries
      .whereType<Directory>()
      .where((Directory item) => item.path.endsWith('.xcworkspace'))
      .firstOrNull;
  final project = entries
      .whereType<Directory>()
      .where((Directory item) => item.path.endsWith('.xcodeproj'))
      .firstOrNull;
  final scheme = flavor ?? 'Runner';
  final arguments = workspace != null
      ? <String>[
          '-workspace',
          workspace.path,
          '-scheme',
          scheme,
          '-configuration',
          'Release',
          '-showBuildSettings',
        ]
      : project != null
      ? <String>[
          '-project',
          project.path,
          '-scheme',
          scheme,
          '-configuration',
          'Release',
          '-showBuildSettings',
        ]
      : const <String>[];
  if (arguments.isEmpty) {
    throw SmfError(
      'No Xcode workspace or project found in $iosDirectory.',
      'XCODE_PROJECT_NOT_FOUND',
    );
  }
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
