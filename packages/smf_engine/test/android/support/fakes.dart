import 'package:smf_engine/android.dart';
import 'package:smf_engine/smf_engine.dart';

final class FakeGooglePlayApi implements GooglePlayApi {
  FakeGooglePlayApi({
    this.bundles = const <GooglePlayBundle>[],
    Set<int>? artifactVersionCodes,
    Map<String, GooglePlayTrack>? tracks,
  }) : artifactVersionCodes = artifactVersionCodes ?? bundles.map((bundle) => bundle.versionCode).toSet(),
       tracks = tracks ?? <String, GooglePlayTrack>{};

  List<GooglePlayBundle> bundles;
  final Set<int> artifactVersionCodes;
  final Map<String, GooglePlayTrack> tracks;
  final List<GooglePlayTrack> updates = <GooglePlayTrack>[];
  final List<String> deletedEdits = <String>[];
  final List<bool> committedReviewStates = <bool>[];
  int editCount = 0;
  int uploadCount = 0;
  int validateCount = 0;
  bool isClosed = false;

  @override
  Future<GooglePlayEdit> createEdit(String packageName) async => GooglePlayEdit(id: 'edit-${++editCount}');

  @override
  Future<void> deleteEdit({
    required String packageName,
    required String editId,
  }) async {
    deletedEdits.add(editId);
  }

  @override
  Future<List<GooglePlayBundle>> listBundles({
    required String packageName,
    required String editId,
  }) async => bundles;

  @override
  Future<Set<int>> listArtifactVersionCodes({
    required String packageName,
    required String editId,
  }) async => Set<int>.unmodifiable(artifactVersionCodes);

  @override
  Future<GooglePlayBundle> uploadBundle({
    required String packageName,
    required String editId,
    required String aabPath,
  }) async {
    uploadCount += 1;
    final bundle = GooglePlayBundle(
      versionCode:
          artifactVersionCodes.fold<int>(
            0,
            (maximum, versionCode) => versionCode > maximum ? versionCode : maximum,
          ) +
          1,
      sha256: await FileDigest.sha256(aabPath),
    );
    bundles = <GooglePlayBundle>[...bundles, bundle];
    artifactVersionCodes.add(bundle.versionCode);
    return bundle;
  }

  @override
  Future<GooglePlayTrack> getTrack({
    required String packageName,
    required String editId,
    required String track,
  }) async => tracks[track] ?? GooglePlayTrack(name: track);

  @override
  Future<GooglePlayTrack> updateTrack({
    required String packageName,
    required String editId,
    required GooglePlayTrack track,
  }) async {
    tracks[track.name] = track;
    updates.add(track);
    return track;
  }

  @override
  Future<void> validateEdit({
    required String packageName,
    required String editId,
  }) async {
    validateCount += 1;
  }

  @override
  Future<void> commitEdit({
    required String packageName,
    required String editId,
    required bool areChangesNotSentForReview,
  }) async {
    committedReviewStates.add(areChangesNotSentForReview);
  }

  @override
  void close() {
    isClosed = true;
  }
}

final class FakeGitHubApi implements GitHubApi {
  final createdTags = <String>[];

  @override
  Future<GitHubReleaseDto?> releaseByTag(String tag) async => null;

  @override
  Future<GitHubReleaseDto> createRelease({
    required String tag,
    required String name,
    required String body,
    required String targetCommitish,
  }) async {
    createdTags.add(tag);
    return GitHubReleaseDto(
      htmlUrl: 'https://github.example/releases/$tag',
      tagName: tag,
      targetCommitish: targetCommitish,
    );
  }

  @override
  Future<void> addLabels({
    required int issueNumber,
    required List<String> labels,
  }) => throw UnimplementedError();

  @override
  Future<void> createLabel({required String name, required String color}) => throw UnimplementedError();

  @override
  Future<GitHubPullRequestDto> createPullRequest({
    required String head,
    required String base,
    required String title,
    required String body,
  }) => throw UnimplementedError();

  @override
  Future<bool> labelExists(String name) => throw UnimplementedError();

  @override
  Future<List<GitHubPullRequestDto>> listPullRequests({
    required String state,
    required String head,
    required String base,
    required int perPage,
  }) => throw UnimplementedError();

  @override
  Future<void> updatePullRequest({
    required int number,
    required String title,
    required String body,
  }) => throw UnimplementedError();
}
