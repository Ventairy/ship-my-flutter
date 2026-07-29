import 'package:smf_engine/smf_engine.dart';

/// State of one release returned by Google Play.
enum GooglePlayReleaseStatus {
  /// Google Play did not assign a meaningful state.
  unspecified('statusUnspecified'),

  /// The release exists but is not served.
  draft('draft'),

  /// The release is served to a configured fraction of eligible users.
  inProgress('inProgress'),

  /// The release is no longer served to new users.
  halted('halted'),

  /// The release is fully rolled out on its track.
  completed('completed');

  const GooglePlayReleaseStatus(this.value);

  /// Stable Android Publisher API value.
  final String value;

  /// Parses a release state at the Google Play response boundary.
  static GooglePlayReleaseStatus parse(Object? value) => switch (value) {
    'statusUnspecified' => GooglePlayReleaseStatus.unspecified,
    'draft' => GooglePlayReleaseStatus.draft,
    'inProgress' => GooglePlayReleaseStatus.inProgress,
    'halted' => GooglePlayReleaseStatus.halted,
    'completed' => GooglePlayReleaseStatus.completed,
    _ => throw SmfError(
      'Google Play returned unsupported release status "$value".',
      SmfErrorCode.googlePlayResponse,
    ),
  };
}
