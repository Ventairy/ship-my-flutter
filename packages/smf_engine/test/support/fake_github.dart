import 'package:smf_engine/smf_engine.dart';

final class FakeGitHubApi implements GitHubApi {
  GitHubRelease? existingRelease;
  final List<({String tag, String name, String targetCommitish})> releases =
      <({String tag, String name, String targetCommitish})>[];

  @override
  Future<void> addLabels({
    required int issueNumber,
    required List<String> labels,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> createLabel({required String name, required String color}) {
    throw UnimplementedError();
  }

  @override
  Future<GitHubPullRequest> createPullRequest({
    required String head,
    required String base,
    required String title,
    required String body,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<GitHubRelease> createRelease({
    required String tag,
    required String name,
    required String body,
    required String targetCommitish,
  }) async {
    releases.add((tag: tag, name: name, targetCommitish: targetCommitish));
    return const GitHubRelease(
      htmlUrl: 'https://github.com/example/app/releases/tag/example/ios-v1.1.0',
    );
  }

  @override
  Future<bool> labelExists(String name) {
    throw UnimplementedError();
  }

  @override
  Future<List<GitHubPullRequest>> listPullRequests({
    required String state,
    required String head,
    required String base,
    required int perPage,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<GitHubRelease?> releaseByTag(String tag) async => existingRelease;

  @override
  Future<void> updatePullRequest({
    required int number,
    required String title,
    required String body,
  }) {
    throw UnimplementedError();
  }
}
