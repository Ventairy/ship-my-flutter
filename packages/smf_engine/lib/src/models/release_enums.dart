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
enum Bump {
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
  static Bump? maybeParse(Object? value) => switch (value) {
    null => null,
    'patch' => Bump.patch,
    'minor' => Bump.minor,
    'major' => Bump.major,
    _ => throw FormatException('Unsupported version bump "$value".'),
  };
}

/// Determines how the tested build is delivered after promotion.
enum ReleaseMode {
  /// Submits for review and releases automatically after store approval.
  automatic('auto'),

  /// Submits for review and waits for an explicit store release.
  review('review'),

  /// Leaves the tested build on its testing track without production review.
  upload('upload');

  const ReleaseMode(this.value);

  /// The stable configuration value.
  final String value;
}
