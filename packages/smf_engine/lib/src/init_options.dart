import 'package:smf_engine/src/enums/release_platform.dart';

/// Inputs used to initialize one Flutter application.
final class InitOptions {
  /// Creates repository initialization options.
  InitOptions({
    required this.appRoot,
    this.appId,
    this.version,
    Map<ReleasePlatform, String> platformVersions = const <ReleasePlatform, String>{},
    Map<ReleasePlatform, Future<String?> Function(String appRoot)> platformVersionDetectors =
        const <ReleasePlatform, Future<String?> Function(String appRoot)>{},
    this.selectedPlatform,
    this.iosBundleId,
    this.androidPackageName,
    this.shouldOverwriteExistingFiles = false,
    this.shouldOnlyUpdateGitHubActions = false,
    this.shouldCreateGitHubActions = true,
  }) : platformVersions = Map<ReleasePlatform, String>.unmodifiable(
         platformVersions,
       ),
       platformVersionDetectors = Map<ReleasePlatform, Future<String?> Function(String appRoot)>.unmodifiable(
         platformVersionDetectors,
       );

  /// Flutter application root to initialize.
  final String appRoot;

  /// Stable application identifier, or `null` to detect it.
  final String? appId;

  /// Initial version shared by selected platforms, when supplied.
  final String? version;

  /// Initial versions keyed by platform.
  final Map<ReleasePlatform, String> platformVersions;

  /// Platform-specific initial-version detectors.
  final Map<ReleasePlatform, Future<String?> Function(String appRoot)> platformVersionDetectors;

  /// Platform to initialize exclusively, or `null` to initialize all detected platforms.
  final ReleasePlatform? selectedPlatform;

  /// Explicit iOS bundle identifier.
  final String? iosBundleId;

  /// Explicit Android application identifier.
  final String? androidPackageName;

  /// Whether existing SMF-owned files may be overwritten.
  final bool shouldOverwriteExistingFiles;

  /// Whether initialization should only update the GitHub Actions wrapper.
  final bool shouldOnlyUpdateGitHubActions;

  /// Whether initialization writes the optional GitHub Actions wrapper.
  final bool shouldCreateGitHubActions;
}
