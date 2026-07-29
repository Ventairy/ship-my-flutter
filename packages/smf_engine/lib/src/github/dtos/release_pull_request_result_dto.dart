import 'package:freezed_annotation/freezed_annotation.dart';

part 'release_pull_request_result_dto.freezed.dart';

/// Branch and pull-request identity produced by release preparation.
@freezed
abstract class ReleasePullRequestResultDto with _$ReleasePullRequestResultDto {
  /// Creates a release pull-request result.
  const factory ReleasePullRequestResultDto({
    required String branch,
    required int pullRequestNumber,
  }) = _ReleasePullRequestResultDto;
}
