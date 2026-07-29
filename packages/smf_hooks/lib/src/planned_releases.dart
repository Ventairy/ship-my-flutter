part of 'smf_hooks_sdk.dart';

/// Nullable platform releases exposed before SMF creates a release pull
/// request.
final class PlannedReleases {
  const PlannedReleases._({required this.ios, required this.android});

  /// Planned iOS release, or `null` when iOS is not being released.
  final PlatformRelease? ios;

  /// Planned Android release, or `null` when Android is not being released.
  final PlatformRelease? android;
}
