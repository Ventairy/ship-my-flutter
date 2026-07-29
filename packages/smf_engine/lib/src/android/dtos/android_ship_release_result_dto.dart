import 'package:smf_engine/src/enums/release_platform.dart';

/// Stable machine-readable evidence produced after shipping an Android release.
final class AndroidShipReleaseResultDto {
  /// Creates an Android ship result.
  AndroidShipReleaseResultDto({
    required this.version,
    required this.tag,
    required this.versionCode,
    required this.testingTrack,
    required this.githubReleaseUrl,
    List<String> testingTracks = const <String>[],
    List<String> shippedTracks = const <String>[],
    this.productionTrack,
  }) : testingTracks = List<String>.unmodifiable(testingTracks),
       shippedTracks = List<String>.unmodifiable(shippedTracks);

  ReleasePlatform get platform => ReleasePlatform.android;

  /// Promoted marketing version.
  final String version;

  /// Git tag created for this Android release.
  final String tag;

  /// Exact Google Play version code.
  final int versionCode;

  String get artifactId => versionCode.toString();

  String get buildNumber => versionCode.toString();

  /// Testing track that contained the release candidate.
  final String testingTrack;

  /// Every testing track that contained the release candidate.
  final List<String> testingTracks;

  /// Every track updated during the ship phase.
  final List<String> shippedTracks;

  /// Production track updated by this promotion, if any.
  final String? productionTrack;

  /// GitHub release URL.
  final String githubReleaseUrl;

  /// Encodes the Android ship result.
  Map<String, Object?> toJson() => <String, Object?>{
    'platform': platform.value,
    'version': version,
    'tag': tag,
    'artifactId': artifactId,
    'buildNumber': buildNumber,
    'testingTrack': testingTrack,
    'testingTracks': testingTracks,
    'shippedTracks': shippedTracks,
    'productionTrack': ?productionTrack,
    'githubReleaseUrl': githubReleaseUrl,
  };
}
