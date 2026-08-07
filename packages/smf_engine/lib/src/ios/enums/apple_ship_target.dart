/// Apple delivery performed by the ship phase.
enum AppleShipTarget {
  /// Distributes the release candidate through external TestFlight groups.
  externalTesting('external-testing'),

  /// Submits to App Review and waits for a manual release after approval.
  submitForReview('submit-for-review'),

  /// Submits to App Review and releases automatically after approval.
  production('production');

  const AppleShipTarget(this.value);

  /// Stable configuration value.
  final String value;
}
