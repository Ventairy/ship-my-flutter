import 'package:json_annotation/json_annotation.dart';

/// A release platform supported by smf.
enum ReleasePlatform {
  /// Apple's iOS platform.
  @JsonValue('ios')
  ios,

  /// Google's Android platform.
  @JsonValue('android')
  android;

  /// The stable serialized platform name.
  String get value => name;

  /// Parses a supported serialized platform name.
  static ReleasePlatform parse(String value) => switch (value) {
    'ios' => ReleasePlatform.ios,
    'android' => ReleasePlatform.android,
    _ => throw FormatException('Unsupported platform "$value".'),
  };

  /// Human-readable platform name.
  String get displayName => switch (this) {
    ReleasePlatform.ios => 'iOS',
    ReleasePlatform.android => 'Android',
  };
}
