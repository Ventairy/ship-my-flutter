part of 'build_attributes.dart';

/// Processing state returned for an uploaded Apple build.
@JsonEnum(valueField: 'value')
enum BuildProcessingState {
  /// Apple is still processing the uploaded build.
  processing('PROCESSING'),

  /// Processing failed before the build became usable.
  failed('FAILED'),

  /// Apple finished processing but rejected the build as invalid.
  invalid('INVALID'),

  /// The build finished processing and can be distributed.
  valid('VALID');

  const BuildProcessingState(this.value);

  /// Stable App Store Connect API value.
  final String value;
}
