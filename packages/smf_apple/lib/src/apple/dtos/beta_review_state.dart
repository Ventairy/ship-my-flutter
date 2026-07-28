import 'package:smf_engine/smf_engine.dart';

/// State of a build submitted to Beta App Review.
enum BetaReviewState {
  /// Apple received the build and has not started review.
  waitingForReview('WAITING_FOR_REVIEW'),

  /// Beta App Review is actively reviewing the build.
  inReview('IN_REVIEW'),

  /// Beta App Review rejected the build.
  rejected('REJECTED'),

  /// Beta App Review approved the build for external testing.
  approved('APPROVED');

  const BetaReviewState(this.value);

  /// Stable App Store Connect API value.
  final String value;

  /// Parses the state at the App Store Connect response boundary.
  static BetaReviewState parse(Object? value) => switch (value) {
    'WAITING_FOR_REVIEW' => BetaReviewState.waitingForReview,
    'IN_REVIEW' => BetaReviewState.inReview,
    'REJECTED' => BetaReviewState.rejected,
    'APPROVED' => BetaReviewState.approved,
    _ => throw SmfError(
      'App Store Connect returned unsupported Beta App Review state "$value".',
      'APP_STORE_CONNECT_RESPONSE',
    ),
  };
}
