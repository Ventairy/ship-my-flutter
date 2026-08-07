import 'package:smf_engine/src/android/google_play_release.dart';

/// Current desired state for a Google Play track.
final class GooglePlayTrack {
  /// Creates track state.
  factory GooglePlayTrack({
    required String name,
    List<GooglePlayRelease> releases = const <GooglePlayRelease>[],
  }) => GooglePlayTrack._(
    name: name,
    releases: List<GooglePlayRelease>.unmodifiable(releases),
  );

  const GooglePlayTrack._({
    required this.name,
    required this.releases,
  });

  /// Track identifier.
  final String name;

  /// Active or desired releases.
  final List<GooglePlayRelease> releases;

  /// Whether [versionCode] is fully rolled out on this track.
  bool containsCompletedVersionCode(int versionCode) => releases.any(
    (release) => release.status == GooglePlayReleaseStatus.completed && release.versionCodes.contains(versionCode),
  );

  /// Release containing [versionCode], if Google Play currently returns one.
  GooglePlayRelease? releaseForVersionCode(int versionCode) =>
      releases.where((release) => release.versionCodes.contains(versionCode)).firstOrNull;
}
