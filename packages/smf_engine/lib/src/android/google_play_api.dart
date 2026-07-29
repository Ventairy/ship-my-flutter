import 'package:smf_engine/src/android/google_play_bundle.dart';
import 'package:smf_engine/src/android/google_play_edit.dart';
import 'package:smf_engine/src/android/google_play_track.dart';

/// Google Play operations required by SMF release candidate and promotion workflows.
abstract interface class GooglePlayApi {
  /// Starts an isolated application edit.
  Future<GooglePlayEdit> createEdit(String packageName);

  /// Deletes an uncommitted edit.
  Future<void> deleteEdit({
    required String packageName,
    required String editId,
  });

  /// Lists app bundles visible inside an edit.
  Future<List<GooglePlayBundle>> listBundles({
    required String packageName,
    required String editId,
  });

  /// Lists every APK and AAB version code visible inside an edit.
  Future<Set<int>> listArtifactVersionCodes({
    required String packageName,
    required String editId,
  });

  /// Uploads an AAB to an edit.
  Future<GooglePlayBundle> uploadBundle({
    required String packageName,
    required String editId,
    required String aabPath,
  });

  /// Reads a track inside an edit.
  Future<GooglePlayTrack> getTrack({
    required String packageName,
    required String editId,
    required String track,
  });

  /// Replaces the desired releases on a track inside an edit.
  Future<GooglePlayTrack> updateTrack({
    required String packageName,
    required String editId,
    required GooglePlayTrack track,
  });

  /// Validates all changes in an edit without committing them.
  Future<void> validateEdit({
    required String packageName,
    required String editId,
  });

  /// Commits an edit without canceling an already-running Play review.
  Future<void> commitEdit({
    required String packageName,
    required String editId,
    required bool areChangesNotSentForReview,
  });

  /// Releases authentication and transport resources.
  void close();
}
