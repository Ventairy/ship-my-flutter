part of 'build_attributes.dart';

/// Processing state returned for an uploaded Apple build.
enum BuildProcessingState {
  /// Apple is still processing the uploaded build.
  @JsonValue('PROCESSING')
  processing('PROCESSING'),

  /// Processing failed before the build became usable.
  @JsonValue('FAILED')
  failed('FAILED'),

  /// Apple finished processing but rejected the build as invalid.
  @JsonValue('INVALID')
  invalid('INVALID'),

  /// The build finished processing and can be distributed.
  @JsonValue('VALID')
  valid('VALID');

  const BuildProcessingState(this.value);

  /// Stable App Store Connect API value.
  final String value;
}
