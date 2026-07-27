import 'package:smf_android/smf_android.dart';
import 'package:smf_engine/smf_engine.dart';

final class FakeGooglePlayApi implements GooglePlayApi {
  FakeGooglePlayApi({
    this.bundles = const <GooglePlayBundle>[],
    Map<String, GooglePlayTrack>? tracks,
  }) : tracks = tracks ?? <String, GooglePlayTrack>{};

  List<GooglePlayBundle> bundles;
  final Map<String, GooglePlayTrack> tracks;
  final List<GooglePlayTrack> updates = <GooglePlayTrack>[];
  final List<String> deletedEdits = <String>[];
  final List<bool> committedReviewStates = <bool>[];
  int editCount = 0;
  int validateCount = 0;
  bool closed = false;

  @override
  Future<GooglePlayEdit> createEdit(String packageName) async =>
      GooglePlayEdit(id: 'edit-${++editCount}');

  @override
  Future<void> deleteEdit(String packageName, String editId) async {
    deletedEdits.add(editId);
  }

  @override
  Future<List<GooglePlayBundle>> listBundles(
    String packageName,
    String editId,
  ) async => bundles;

  @override
  Future<GooglePlayBundle> uploadBundle(
    String packageName,
    String editId,
    String aabPath,
  ) async {
    final bundle = GooglePlayBundle(
      versionCode:
          bundles.fold<int>(
            0,
            (maximum, item) =>
                item.versionCode > maximum ? item.versionCode : maximum,
          ) +
          1,
      sha256: await fileSha256(aabPath),
    );
    bundles = <GooglePlayBundle>[...bundles, bundle];
    return bundle;
  }

  @override
  Future<GooglePlayTrack> getTrack(
    String packageName,
    String editId,
    String track,
  ) async => tracks[track] ?? GooglePlayTrack(name: track);

  @override
  Future<GooglePlayTrack> updateTrack(
    String packageName,
    String editId,
    GooglePlayTrack track,
  ) async {
    tracks[track.name] = track;
    updates.add(track);
    return track;
  }

  @override
  Future<void> validateEdit(String packageName, String editId) async {
    validateCount += 1;
  }

  @override
  Future<void> commitEdit(
    String packageName,
    String editId, {
    required bool changesNotSentForReview,
  }) async {
    committedReviewStates.add(changesNotSentForReview);
  }

  @override
  void close() {
    closed = true;
  }
}

final class FakeGitHubApi implements GitHubApi {
  final createdTags = <String>[];

  @override
  Future<GitHubRelease?> releaseByTag(String tag) async => null;

  @override
  Future<GitHubRelease> createRelease({
    required String tag,
    required String name,
    required String body,
    required String targetCommitish,
  }) async {
    createdTags.add(tag);
    return GitHubRelease(
      htmlUrl: 'https://github.example/releases/$tag',
    );
  }

  @override
  Future<void> addLabels({
    required int issueNumber,
    required List<String> labels,
  }) => throw UnimplementedError();

  @override
  Future<void> createLabel({required String name, required String color}) =>
      throw UnimplementedError();

  @override
  Future<GitHubPullRequest> createPullRequest({
    required String head,
    required String base,
    required String title,
    required String body,
  }) => throw UnimplementedError();

  @override
  Future<bool> labelExists(String name) => throw UnimplementedError();

  @override
  Future<List<GitHubPullRequest>> listPullRequests({
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
