/// Hook phase encoded by the engine.
enum SmfHookProtocolPhase {
  /// Runs before creating or updating the release pull request.
  beforeCreatePr('before_create_pr'),

  /// Runs before fingerprinting and building one store release candidate.
  beforeBuild('before_build');

  const SmfHookProtocolPhase(this.value);

  /// Stable wire value.
  final String value;

  /// Parses one exact wire value.
  static SmfHookProtocolPhase parse(String value) {
    for (final phase in values) {
      if (phase.value == value) return phase;
    }
    throw FormatException('Unsupported SMF hook phase "$value".');
  }
}
