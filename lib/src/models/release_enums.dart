import 'package:json_annotation/json_annotation.dart';

/// A release platform supported by ship-my-flutter.
enum Platform {
  /// Apple's iOS platform.
  @JsonValue('ios')
  ios;

  /// The stable serialized platform name.
  String get value => name;

  /// Parses a supported serialized platform name.
  static Platform parse(String value) => switch (value) {
    'ios' => Platform.ios,
    _ => throw FormatException('Unsupported platform "$value".'),
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

/// Determines whether promotion uploads only or submits for App Review.
enum ReleaseMode {
  /// Submits the tested build to App Review.
  submitForReview('submit-for-review'),

  /// Leaves the tested build uploaded without submitting it.
  uploadOnly('upload-only');

  const ReleaseMode(this.value);

  /// The stable configuration value.
  final String value;
}
