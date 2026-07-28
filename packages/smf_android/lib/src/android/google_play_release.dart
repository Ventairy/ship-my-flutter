import 'package:smf_engine/smf_engine.dart';

part 'google_play_release_enums.dart';

/// One release configured on a Google Play track.
final class GooglePlayRelease {
  /// Creates a track release.
  factory GooglePlayRelease({
    required GooglePlayReleaseStatus status,
    required List<int> versionCodes,
    String? name,
    Map<String, String> releaseNotes = const <String, String>{},
  }) => GooglePlayRelease._(
    status: status,
    versionCodes: List<int>.unmodifiable(versionCodes),
    name: name,
    releaseNotes: Map<String, String>.unmodifiable(releaseNotes),
  );

  const GooglePlayRelease._({
    required this.status,
    required this.versionCodes,
    required this.name,
    required this.releaseNotes,
  });

  /// Google Play release state.
  final GooglePlayReleaseStatus status;

  /// Version codes currently included in the release.
  final List<int> versionCodes;

  /// Optional release name.
  final String? name;

  /// Localized "What's new" text keyed by BCP-47 language.
  final Map<String, String> releaseNotes;
}
