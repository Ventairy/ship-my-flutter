import 'package:json_annotation/json_annotation.dart';

/// A release platform supported by smf.
enum Platform {
  /// Apple's iOS platform.
  @JsonValue('ios')
  ios,

  /// Google's Android platform.
  @JsonValue('android')
  android;

  /// The stable serialized platform name.
  String get value => name;

  /// Parses a supported serialized platform name.
  static Platform parse(String value) => switch (value) {
    'ios' => Platform.ios,
    'android' => Platform.android,
    _ => throw FormatException('Unsupported platform "$value".'),
  };

  /// Human-readable platform name used in release notes.
  String get displayName => switch (this) {
    Platform.ios => 'iOS',
    Platform.android => 'Android',
  };
}

/// A semantic-version change.
enum VersionBump {
  /// Increments the patch component.
  @JsonValue('patch')
  patch,

  /// Increments the minor component.
  @JsonValue('minor')
  minor,

  /// Increments the major component.
  @JsonValue('major')
  major;

  /// The stable serialized bump name.
  String get value => name;

  /// Parses an optional serialized bump.
  static VersionBump? maybeParse(Object? value) => switch (value) {
    null => null,
    'patch' => VersionBump.patch,
    'minor' => VersionBump.minor,
    'major' => VersionBump.major,
    _ => throw FormatException('Unsupported version bump "$value".'),
  };
}

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

/// Apple delivery performed by the ship phase.
enum AppleShipTarget {
  /// Distributes the candidate through external TestFlight groups.
  externalTesting('external-testing'),

  /// Submits to App Review and waits for a manual release after approval.
  submitForReview('submit-for-review'),

  /// Submits to App Review and releases automatically after approval.
  production('production');

  const AppleShipTarget(this.value);

  /// Stable configuration value.
  final String value;
}

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
