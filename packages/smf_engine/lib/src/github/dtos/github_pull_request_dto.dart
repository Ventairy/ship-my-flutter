import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_pull_request_dto.freezed.dart';
part 'github_pull_request_dto.g.dart';

/// Pull-request fields used by smf.
@freezed
abstract class GitHubPullRequestDto with _$GitHubPullRequestDto {
  /// Creates a GitHub pull-request response.
  @JsonSerializable(checked: true)
  const factory GitHubPullRequestDto({required int number}) = _GitHubPullRequestDto;

  /// Decodes a pull request from GitHub JSON.
  factory GitHubPullRequestDto.fromJson(Map<String, Object?> json) => _$GitHubPullRequestDtoFromJson(json);
}
