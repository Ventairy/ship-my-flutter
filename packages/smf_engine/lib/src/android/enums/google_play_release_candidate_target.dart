/// Google Play testing destination for an Android release candidate.
enum GooglePlayReleaseCandidateTarget {
  /// Google Play internal testing.
  internalTesting('internal-testing'),

  /// One or more named Google Play closed-testing tracks.
  closedTesting('closed-testing'),

  /// Google Play open testing.
  openTesting('open-testing');

  const GooglePlayReleaseCandidateTarget(this.value);

  /// Stable configuration value.
  final String value;
}
