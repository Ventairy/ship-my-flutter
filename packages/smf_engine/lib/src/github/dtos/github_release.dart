import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_release.freezed.dart';
part 'github_release.g.dart';

/// GitHub Release fields used by smf.
@freezed
abstract class GitHubRelease with _$GitHubRelease {
  /// Creates a GitHub Release response.
  @JsonSerializable(checked: true)
  const factory GitHubRelease({
    @JsonKey(name: 'html_url') required String htmlUrl,
  }) = _GitHubRelease;

  /// Decodes a release from GitHub JSON.
  factory GitHubRelease.fromJson(Map<String, Object?> json) => _$GitHubReleaseFromJson(json);
}
