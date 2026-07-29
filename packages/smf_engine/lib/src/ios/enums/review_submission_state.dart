import 'package:smf_engine/smf_engine.dart';

/// Lifecycle state of one App Store review submission.
enum ReviewSubmissionState {
  /// Items were added, but the submission has not been sent to Apple.
  readyForReview('READY_FOR_REVIEW'),

  /// Apple received the submission and has not started review.
  waitingForReview('WAITING_FOR_REVIEW'),

  /// App Review is actively reviewing the submission.
  inReview('IN_REVIEW'),

  /// One or more isSubmitted items require developer action.
  unresolvedIssues('UNRESOLVED_ISSUES'),

  /// Apple is processing a cancellation request.
  canceling('CANCELING'),

  /// Apple is moving the submission into its final state.
  completing('COMPLETING'),

  /// Apple finished processing the submission.
  complete('COMPLETE');

  const ReviewSubmissionState(this.value);

  /// Stable App Store Connect API value.
  final String value;

  /// Parses the state at the App Store Connect response boundary.
  static ReviewSubmissionState parse(Object? value) => switch (value) {
    'READY_FOR_REVIEW' => ReviewSubmissionState.readyForReview,
    'WAITING_FOR_REVIEW' => ReviewSubmissionState.waitingForReview,
    'IN_REVIEW' => ReviewSubmissionState.inReview,
    'UNRESOLVED_ISSUES' => ReviewSubmissionState.unresolvedIssues,
    'CANCELING' => ReviewSubmissionState.canceling,
    'COMPLETING' => ReviewSubmissionState.completing,
    'COMPLETE' => ReviewSubmissionState.complete,
    _ => throw SmfError(
      'App Store Connect returned unsupported review-submission state '
      '"$value".',
      SmfErrorCode.appStoreConnectResponse,
    ),
  };
}
