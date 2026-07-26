import 'dart:io';

import 'package:path/path.dart' as p;

import '../error.dart';
import '../model.dart' hide Platform;
import '../process_runner.dart';

typedef ResolveBundleId =
    Future<String> Function(String repositoryRoot, IosConfig config);

Future<String> resolveBundleId(
  String repositoryRoot,
  IosConfig config, {
  ProcessRunner processRunner = const SystemProcessRunner(),
  bool? isMacOS,
}) async {
  if (config.bundleId != null) return config.bundleId!;
  if (!(isMacOS ?? Platform.isMacOS)) {
    throw const ShipError(
      'platforms.ios.bundleId is required when configuration is validated '
          'outside macOS.',
      'BUNDLE_ID_REQUIRED',
    );
  }

  final projectRoot = p.normalize(
    p.absolute(repositoryRoot, config.projectPath),
  );
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
  final scheme = config.scheme ?? 'Runner';
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
    throw ShipError(
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
    throw const ShipError(
      'Could not detect PRODUCT_BUNDLE_IDENTIFIER. Set '
          'platforms.ios.bundleId in .ship-my-flutter/config.yaml.',
      'BUNDLE_ID_REQUIRED',
    );
  }
  return bundleId;
}
