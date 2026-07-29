import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_release_dto.freezed.dart';
part 'github_release_dto.g.dart';

/// GitHub Release fields used by smf.
@freezed
abstract class GitHubReleaseDto with _$GitHubReleaseDto {
  /// Creates a GitHub Release response.
  @JsonSerializable(checked: true)
  const factory GitHubReleaseDto({
    @JsonKey(name: 'html_url') required String htmlUrl,
    @JsonKey(name: 'tag_name') required String tagName,
    @JsonKey(name: 'target_commitish') required String targetCommitish,
  }) = _GitHubReleaseDto;

  /// Decodes a release from GitHub JSON.
  factory GitHubReleaseDto.fromJson(Map<String, Object?> json) => _$GitHubReleaseDtoFromJson(json);
}
