import 'package:smf_engine/smf_engine.dart';

final class GooglePlayTrackNames {
  const GooglePlayTrackNames._();

  static const String internalTesting = 'qa';
  static const String openTesting = 'beta';
  static const String production = 'production';

  static List<String> releaseCandidate(
    GooglePlayReleaseCandidateConfig config,
  ) => switch (config.target) {
    GooglePlayReleaseCandidateTarget.internalTesting => const <String>[
      internalTesting,
    ],
    GooglePlayReleaseCandidateTarget.closedTesting => config.tracks,
    GooglePlayReleaseCandidateTarget.openTesting => const <String>[
      openTesting,
    ],
  };

  static List<String> ship(GooglePlayShipConfig config) => switch (config.target) {
    GooglePlayShipTarget.closedTesting => config.tracks,
    GooglePlayShipTarget.openTesting => const <String>[openTesting],
    GooglePlayShipTarget.production => const <String>[production],
  };
}
