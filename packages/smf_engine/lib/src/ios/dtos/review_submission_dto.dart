import 'package:smf_engine/src/ios/enums/review_submission_state.dart';

/// One App Store review submission associated with an app version.
final class ReviewSubmissionDto {
  /// Creates typed review-submission state.
  const ReviewSubmissionDto({
    required this.id,
    required this.state,
    required this.appStoreVersionId,
  });

  /// App Store Connect resource identifier.
  final String id;

  /// Current submission state.
  final ReviewSubmissionState state;

  /// App Store version included in this submission, when present.
  final String? appStoreVersionId;
}
