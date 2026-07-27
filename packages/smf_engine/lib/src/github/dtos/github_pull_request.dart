import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_pull_request.freezed.dart';
part 'github_pull_request.g.dart';

/// Pull-request fields used by smf.
@freezed
abstract class GitHubPullRequest with _$GitHubPullRequest {
  /// Creates a GitHub pull-request response.
  @JsonSerializable(checked: true)
  const factory GitHubPullRequest({required int number}) = _GitHubPullRequest;

  /// Decodes a pull request from GitHub JSON.
  factory GitHubPullRequest.fromJson(Map<String, Object?> json) =>
      _$GitHubPullRequestFromJson(json);
}
