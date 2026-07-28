import 'package:smf_engine/smf_engine.dart';

part 'review_submission_enums.dart';

/// One App Store review submission associated with an app version.
final class ReviewSubmission {
  /// Creates typed review-submission state.
  const ReviewSubmission({
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
