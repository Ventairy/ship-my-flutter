import 'dart:convert';
import 'dart:io';

import 'package:googleapis/androidpublisher/v3.dart' as play;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:smf_android/src/models/google_play_credentials.dart';
import 'package:smf_engine/smf_engine.dart';

/// One Google Play edit.
final class GooglePlayEdit {
  /// Creates an edit reference.
  const GooglePlayEdit({required this.id});

  /// Server-assigned edit identifier.
  final String id;
}

/// One uploaded Android App Bundle.
final class GooglePlayBundle {
  /// Creates bundle evidence.
  const GooglePlayBundle({
    required this.versionCode,
    required this.sha256,
  });

  /// Manifest version code.
  final int versionCode;

  /// SHA-256 digest returned by Google Play.
  final String sha256;
}

/// One release configured on a Google Play track.
final class GooglePlayRelease {
  /// Creates a track release.
  const GooglePlayRelease({
    required this.status,
    required this.versionCodes,
    this.name,
    this.releaseNotes = const <String, String>{},
  });

  /// Google Play release state.
  final String status;

  /// Version codes currently included in the release.
  final List<int> versionCodes;

  /// Optional release name.
  final String? name;

  /// Localized "What's new" text keyed by BCP-47 language.
  final Map<String, String> releaseNotes;
}

/// Current desired state for a Google Play track.
final class GooglePlayTrack {
  /// Creates track state.
  const GooglePlayTrack({
    required this.name,
    this.releases = const <GooglePlayRelease>[],
  });

  /// Track identifier.
  final String name;

  /// Active or desired releases.
  final List<GooglePlayRelease> releases;

  /// Whether [versionCode] is already assigned to this track.
  bool containsVersionCode(int versionCode) => releases.any(
    (release) => release.versionCodes.contains(versionCode),
  );
}

/// Google Play operations required by SMF candidate and promotion workflows.
abstract interface class GooglePlayApi {
  /// Starts an isolated application edit.
  Future<GooglePlayEdit> createEdit(String packageName);

  /// Deletes an uncommitted edit.
  Future<void> deleteEdit(String packageName, String editId);

  /// Lists app bundles visible inside an edit.
  Future<List<GooglePlayBundle>> listBundles(
    String packageName,
    String editId,
  );

  /// Uploads an AAB to an edit.
  Future<GooglePlayBundle> uploadBundle(
    String packageName,
    String editId,
    String aabPath,
  );

  /// Reads a track inside an edit.
  Future<GooglePlayTrack> getTrack(
    String packageName,
    String editId,
    String track,
  );

  /// Replaces the desired releases on a track inside an edit.
  Future<GooglePlayTrack> updateTrack(
    String packageName,
    String editId,
    GooglePlayTrack track,
  );

  /// Validates all changes in an edit without committing them.
  Future<void> validateEdit(String packageName, String editId);

  /// Commits an edit without canceling an already-running Play review.
  Future<void> commitEdit(
    String packageName,
    String editId, {
    required bool changesNotSentForReview,
  });

  /// Releases authentication and transport resources.
  void close();
}

/// Authenticated implementation backed by the official Google API packages.
final class GooglePlayClient implements GooglePlayApi {
  /// Uses an already-authenticated Android Publisher HTTP client.
  ///
  /// The client must authorize the Android Publisher scope. SMF owns and
  /// closes it after use.
  GooglePlayClient.authenticated(http.Client client)
    : this._(client, play.AndroidPublisherApi(client));

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
  Future<void> deleteEdit(String packageName, String editId) => _guard(
    'delete an application edit',
    () => _api.edits.delete(packageName, editId),
  );

  @override
  Future<List<GooglePlayBundle>> listBundles(
    String packageName,
    String editId,
  ) => _guard(
    'list app bundles',
    () async {
      final response = await _api.edits.bundles.list(packageName, editId);
      return <GooglePlayBundle>[
        for (final bundle in response.bundles ?? const <play.Bundle>[])
          _bundle(bundle),
      ];
    },
  );

  @override
  Future<GooglePlayBundle> uploadBundle(
    String packageName,
    String editId,
    String aabPath,
  ) => _guard(
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
  Future<GooglePlayTrack> getTrack(
    String packageName,
    String editId,
    String track,
  ) => _guard(
    'read Google Play track "$track"',
    () async => _track(
      await _api.edits.tracks.get(packageName, editId, track),
      fallbackName: track,
    ),
  );

  @override
  Future<GooglePlayTrack> updateTrack(
    String packageName,
    String editId,
    GooglePlayTrack track,
  ) => _guard(
    'update Google Play track "${track.name}"',
    () async {
      final result = await _api.edits.tracks.update(
        play.Track(
          track: track.name,
          releases: <play.TrackRelease>[
            for (final release in track.releases)
              play.TrackRelease(
                status: release.status,
                versionCodes: release.versionCodes
                    .map((value) => value.toString())
                    .toList(growable: false),
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
  Future<void> validateEdit(String packageName, String editId) => _guard(
    'validate the Google Play edit',
    () async {
      await _api.edits.validate(packageName, editId);
    },
  );

  @override
  Future<void> commitEdit(
    String packageName,
    String editId, {
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

  @override
  void close() => _client.close();
}

GooglePlayBundle _bundle(play.Bundle bundle) {
  final versionCode = bundle.versionCode;
  final sha256 = bundle.sha256;
  if (versionCode == null || sha256 == null || sha256.isEmpty) {
    throw const SmfError(
      'Google Play returned incomplete Android App Bundle evidence.',
      'GOOGLE_PLAY_RESPONSE',
    );
  }
  return GooglePlayBundle(versionCode: versionCode, sha256: sha256);
}

GooglePlayTrack _track(play.Track track, {required String fallbackName}) =>
    GooglePlayTrack(
      name: track.track ?? fallbackName,
      releases: <GooglePlayRelease>[
        for (final release in track.releases ?? const <play.TrackRelease>[])
          GooglePlayRelease(
            status: release.status ?? 'statusUnspecified',
            versionCodes: _versionCodes(release.versionCodes),
            name: release.name,
            releaseNotes: _releaseNotes(release.releaseNotes),
          ),
      ],
    );

List<int> _versionCodes(List<String>? values) => <int>[
  for (final value in values ?? const <String>[]) ?int.tryParse(value),
];

Map<String, String> _releaseNotes(List<play.LocalizedText>? notes) {
  final result = <String, String>{};
  for (final note in notes ?? const <play.LocalizedText>[]) {
    final language = note.language;
    final text = note.text;
    if (language != null && text != null) result[language] = text;
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
    // The status code remains useful when Google returns a non-JSON response.
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
