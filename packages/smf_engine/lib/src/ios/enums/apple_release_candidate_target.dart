/// TestFlight audience that receives an Apple release candidate.
enum AppleReleaseCandidateTarget {
  /// App Store Connect team members in internal TestFlight groups.
  internalTesting('internal-testing'),

  /// Testers in external TestFlight groups after Beta App Review.
  externalTesting('external-testing');

  const AppleReleaseCandidateTarget(this.value);

  /// Stable configuration value.
  final String value;
}
