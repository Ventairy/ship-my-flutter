import 'package:json_annotation/json_annotation.dart';

/// A semantic-version change type.
enum VersionBumpType {
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
  static VersionBumpType? maybeParse(Object? value) => switch (value) {
    null => null,
    'patch' => VersionBumpType.patch,
    'minor' => VersionBumpType.minor,
    'major' => VersionBumpType.major,
    _ => throw FormatException('Unsupported version bump "$value".'),
  };
}
