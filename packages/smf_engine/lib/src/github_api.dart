import 'package:smf_engine/src/github/dtos/github_pull_request_dto.dart';
import 'package:smf_engine/src/github/dtos/github_release_dto.dart';

export 'github/dtos/github_pull_request_dto.dart';
export 'github/dtos/github_release_dto.dart';
export 'github/github_api_exception.dart';

/// GitHub operations required by SMF release workflows.
abstract interface class GitHubApi {
  /// Lists pull requests matching an exact state, head, and base branch.
  Future<List<GitHubPullRequestDto>> listPullRequests({
    required String state,
    required String head,
    required String base,
    required int perPage,
  });

  /// Creates a pull request.
  Future<GitHubPullRequestDto> createPullRequest({
    required String head,
    required String base,
    required String title,
    required String body,
  });

  /// Replaces the title and body of an existing pull request.
  Future<void> updatePullRequest({
    required int number,
    required String title,
    required String body,
  });

  /// Whether a repository label named [name] exists.
  Future<bool> labelExists(String name);

  /// Creates a repository label.
  Future<void> createLabel({required String name, required String color});

  /// Adds [labels] to one issue or pull request.
  Future<void> addLabels({
    required int issueNumber,
    required List<String> labels,
  });

  /// Finds the GitHub Release attached to [tag], if one exists.
  Future<GitHubReleaseDto?> releaseByTag(String tag);

  /// Creates a GitHub Release for an existing tag target.
  Future<GitHubReleaseDto> createRelease({
    required String tag,
    required String name,
    required String body,
    required String targetCommitish,
  });
}
