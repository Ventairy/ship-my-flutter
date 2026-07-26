import 'package:freezed_annotation/freezed_annotation.dart';

part 'release_pull_request_result.freezed.dart';

/// Branch and pull-request identity produced by release preparation.
@freezed
abstract class ReleasePullRequestResult with _$ReleasePullRequestResult {
  /// Creates a release pull-request result.
  const factory ReleasePullRequestResult({
    required String branch,
    required int pullRequestNumber,
  }) = _ReleasePullRequestResult;
}
