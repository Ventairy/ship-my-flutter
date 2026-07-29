/// Google Play destination used by the ship phase.
enum GooglePlayShipTarget {
  /// One or more named Google Play closed-testing tracks.
  closedTesting('closed-testing'),

  /// Google Play open testing.
  openTesting('open-testing'),

  /// Google Play production.
  production('production');

  const GooglePlayShipTarget(this.value);

  /// Stable configuration value.
  final String value;
}
