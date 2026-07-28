import 'dart:convert';
import 'dart:io';

import 'package:googleapis/androidpublisher/v3.dart' as play;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:smf_android/src/android/google_play_api.dart';
import 'package:smf_android/src/android/google_play_bundle.dart';
import 'package:smf_android/src/android/google_play_edit.dart';
import 'package:smf_android/src/android/google_play_release.dart';
import 'package:smf_android/src/android/google_play_track.dart';
import 'package:smf_android/src/models/google_play_credentials.dart';
import 'package:smf_engine/smf_engine.dart';

export 'google_play_api.dart';
export 'google_play_bundle.dart';
export 'google_play_edit.dart';
export 'google_play_release.dart';
export 'google_play_track.dart';

/// Authenticated implementation backed by the official Google API packages.
final class GooglePlayClient implements GooglePlayApi {
  /// Uses an already-authenticated Android Publisher HTTP client.
  ///
  /// The client must authorize the Android Publisher scope. SMF owns and
  /// closes it after use.
  GooglePlayClient.authenticated(http.Client client) : this._(client, play.AndroidPublisherApi(client));

  GooglePlayClient._(this._client, this._api);

  final http.Client _client;
  final play.AndroidPublisherApi _api;

  /// Authenticates a service account for Android Publisher access.
  static Future<GooglePlayClient> open(
    GooglePlayCredentials credentials, {
    http.Client? baseClient,
  }) async {
    try {
      final serviceAccount = ServiceAccountCredentials.fromJson(
        credentials.serviceAccountJson,
      );
      final client = await clientViaServiceAccount(
        serviceAccount,
        const <String>[play.AndroidPublisherApi.androidpublisherScope],
        baseClient: baseClient,
      );
      return GooglePlayClient._(
        client,
        play.AndroidPublisherApi(client),
      );
    } on Object catch (error) {
      throw SmfError(
        'Could not authenticate the Google Play service account.',
        'GOOGLE_PLAY_AUTH',
        cause: error,
      );
    }
  }

  @override
  Future<GooglePlayEdit> createEdit(String packageName) => _guard(
    'create an application edit',
    () async {
      final edit = await _api.edits.insert(play.AppEdit(), packageName);
      return GooglePlayEdit(
        id: _required(edit.id, 'Google Play did not return an edit ID.'),
      );
    },
  );

  @override
  Future<void> deleteEdit({
    required String packageName,
    required String editId,
  }) => _guard(
    'delete an application edit',
    () => _api.edits.delete(packageName, editId),
  );

  @override
  Future<List<GooglePlayBundle>> listBundles({
    required String packageName,
    required String editId,
  }) => _guard(
    'list app bundles',
    () async {
      final response = await _api.edits.bundles.list(packageName, editId);
      return <GooglePlayBundle>[
        for (final bundle in response.bundles ?? const <play.Bundle>[]) _bundle(bundle),
      ];
    },
  );

  @override
  Future<Set<int>> listArtifactVersionCodes({
    required String packageName,
    required String editId,
  }) => _guard(
    'list APK and app bundle version codes',
    () async {
      final (bundles, apks) = await (
        _api.edits.bundles.list(packageName, editId),
        _api.edits.apks.list(packageName, editId),
      ).wait;
      return <int>{
        for (final bundle in bundles.bundles ?? const <play.Bundle>[])
          _positiveVersionCode(
            bundle.versionCode,
            artifact: 'Android App Bundle',
          ),
        for (final apk in apks.apks ?? const <play.Apk>[]) _positiveVersionCode(apk.versionCode, artifact: 'APK'),
      };
    },
  );

  @override
  Future<GooglePlayBundle> uploadBundle({
    required String packageName,
    required String editId,
    required String aabPath,
  }) => _guard(
    'upload the Android App Bundle',
    () async {
      final file = File(aabPath);
      final bundle = await _api.edits.bundles.upload(
        packageName,
        editId,
        uploadMedia: play.Media(
          file.openRead(),
          await file.length(),
        ),
        uploadOptions: play.UploadOptions.resumable,
      );
      return _bundle(bundle);
    },
  );

  @override
  Future<GooglePlayTrack> getTrack({
    required String packageName,
    required String editId,
    required String track,
  }) => _guard(
    'read Google Play track "$track"',
    () async => _track(
      await _api.edits.tracks.get(packageName, editId, track),
      fallbackName: track,
    ),
  );

  @override
  Future<GooglePlayTrack> updateTrack({
    required String packageName,
    required String editId,
    required GooglePlayTrack track,
  }) => _guard(
    'update Google Play track "${track.name}"',
    () async {
      final result = await _api.edits.tracks.update(
        play.Track(
          track: track.name,
          releases: <play.TrackRelease>[
            for (final release in track.releases)
              play.TrackRelease(
                status: release.status.value,
                versionCodes: release.versionCodes.map((value) => value.toString()).toList(growable: false),
                name: release.name,
                releaseNotes: <play.LocalizedText>[
                  for (final note in release.releaseNotes.entries)
                    play.LocalizedText(language: note.key, text: note.value),
                ],
              ),
          ],
        ),
        packageName,
        editId,
        track.name,
      );
      return _track(result, fallbackName: track.name);
    },
  );

  @override
  Future<void> validateEdit({
    required String packageName,
    required String editId,
  }) => _guard(
    'validate the Google Play edit',
    () async {
      await _api.edits.validate(packageName, editId);
    },
  );

  @override
  Future<void> commitEdit({
    required String packageName,
    required String editId,
    required bool changesNotSentForReview,
  }) => _guard(
    'commit the Google Play edit',
    () async {
      final uri = Uri.https(
        'androidpublisher.googleapis.com',
        '/androidpublisher/v3/applications/'
            '${Uri.encodeComponent(packageName)}/edits/'
            '${Uri.encodeComponent(editId)}:commit',
        <String, String>{
          'changesNotSentForReview': changesNotSentForReview.toString(),
          'changesInReviewBehavior': 'ERROR_IF_IN_REVIEW',
        },
      );
      final response = await _client.post(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SmfError(
          'Google Play rejected the edit commit '
              '(HTTP ${response.statusCode}): '
              '${_responseMessage(response.body)}',
          'GOOGLE_PLAY_API',
        );
      }
    },
  );

  GooglePlayBundle _bundle(play.Bundle bundle) {
    final versionCode = _positiveVersionCode(
      bundle.versionCode,
      artifact: 'Android App Bundle',
    );
    final sha256 = bundle.sha256;
    if (sha256 == null || !RegExp(r'^[a-f0-9]{64}$').hasMatch(sha256)) {
      throw const SmfError(
        'Google Play returned incomplete Android App Bundle evidence.',
        'GOOGLE_PLAY_RESPONSE',
      );
    }
    return GooglePlayBundle(versionCode: versionCode, sha256: sha256);
  }

  int _positiveVersionCode(int? value, {required String artifact}) {
    if (value == null || value <= 0) {
      throw SmfError(
        'Google Play returned an invalid $artifact versionCode.',
        'GOOGLE_PLAY_RESPONSE',
      );
    }
    return value;
  }

  GooglePlayTrack _track(
    play.Track track, {
    required String fallbackName,
  }) => GooglePlayTrack(
    name: track.track ?? fallbackName,
    releases: <GooglePlayRelease>[
      for (final release in track.releases ?? const <play.TrackRelease>[])
        GooglePlayRelease(
          status: GooglePlayReleaseStatus.parse(release.status),
          versionCodes: _versionCodes(release.versionCodes),
          name: release.name,
          releaseNotes: _releaseNotes(release.releaseNotes),
        ),
    ],
  );

  List<int> _versionCodes(List<String>? values) {
    final versionCodes = <int>[];
    for (final value in values ?? const <String>[]) {
      final versionCode = int.tryParse(value);
      if (versionCode == null || versionCode <= 0) {
        throw SmfError(
          'Google Play returned invalid versionCode "$value".',
          'GOOGLE_PLAY_RESPONSE',
        );
      }
      versionCodes.add(versionCode);
    }
    return versionCodes;
  }

  Map<String, String> _releaseNotes(List<play.LocalizedText>? notes) {
    final result = <String, String>{};
    for (final note in notes ?? const <play.LocalizedText>[]) {
      final language = note.language;
      final text = note.text;
      if (language == null || language.trim().isEmpty || text == null || text.trim().isEmpty) {
        throw const SmfError(
          'Google Play returned an incomplete localized release note.',
          'GOOGLE_PLAY_RESPONSE',
        );
      }
      if (result.containsKey(language)) {
        throw SmfError(
          'Google Play returned duplicate release-note locale "$language".',
          'GOOGLE_PLAY_RESPONSE',
        );
      }
      result[language] = text;
    }
    return result;
  }

  String _required(String? value, String message) {
    if (value == null || value.isEmpty) {
      throw SmfError(message, 'GOOGLE_PLAY_RESPONSE');
    }
    return value;
  }

  String _responseMessage(String body) {
    try {
      final value = jsonDecode(body);
      if (value case <String, Object?>{
        'error': <String, Object?>{'message': final String message},
      }) {
        return message;
      }
    } on FormatException {
      // The status code remains useful when Google returns non-JSON.
    }
    return 'no structured error message';
  }

  Future<T> _guard<T>(
    String operation,
    Future<T> Function() callback,
  ) async {
    try {
      return await callback();
    } on SmfError {
      rethrow;
    } on play.DetailedApiRequestError catch (error) {
      throw SmfError(
        'Could not $operation (HTTP ${error.status ?? 'unknown'}): '
            '${error.message ?? 'Google Play returned no error message.'}',
        'GOOGLE_PLAY_API',
        cause: error,
      );
    } on Object catch (error) {
      throw SmfError(
        'Could not $operation.',
        'GOOGLE_PLAY_API',
        cause: error,
      );
    }
  }

  @override
  void close() => _client.close();
}
