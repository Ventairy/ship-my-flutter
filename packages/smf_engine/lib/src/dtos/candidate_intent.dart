import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/models/release_enums.dart';
import 'package:smf_engine/src/serialization.dart';

part 'candidate_intent.freezed.dart';
part 'candidate_intent.g.dart';

/// Durable evidence written before SMF uploads a candidate to a store.
///
/// The intent lets a fresh runner recover the exact build after an upload or
/// receipt-push failure without selecting an unrelated store artifact.
@freezed
abstract class CandidateIntent with _$CandidateIntent {
  /// Creates a candidate upload intent.
  @JsonSerializable(
    checked: true,
    dateTimeUtc: true,
    disallowUnrecognizedKeys: true,
  )
  const factory CandidateIntent({
    required Platform platform,
    required String version,
    required String buildNumber,
    required String applicationId,
    required String storeApplicationId,
    required String sourceSha,
    required String sourceFingerprint,
    required String artifactSha256,
    required DateTime preparedAt,
    @JsonKey(required: true) @Default(1) int schemaVersion,
  }) = _CandidateIntent;

  const CandidateIntent._();

  /// Decodes and validates a persisted candidate intent.
  factory CandidateIntent.fromJson(
    Object? value, {
    String source = 'candidate intent',
  }) => _decodeCandidateIntent(value, source);

  /// Reads and validates candidate intent JSON from [filePath].
  static Future<CandidateIntent> read(String filePath) async {
    try {
      return CandidateIntent.fromJson(
        await SmfFileSystem.readJson(filePath),
        source: filePath,
      );
    } on FileSystemException catch (error) {
      throw SmfError(
        'Could not read $filePath: ${error.message}',
        'CANDIDATE_INTENT_NOT_FOUND',
        cause: error,
      );
    } on FormatException catch (error) {
      throw SmfError(
        '$filePath contains malformed JSON.',
        'INVALID_CANDIDATE_INTENT',
        cause: error,
      );
    }
  }

  static final RegExp _versionPattern = RegExp(r'^\d+\.\d+\.\d+$');
  static final RegExp _buildNumberPattern = RegExp(r'^\d+$');
  static final RegExp _gitShaPattern = RegExp(
    r'^(?:[a-f0-9]{40}|[a-f0-9]{64})$',
  );
  static final RegExp _digestPattern = RegExp(r'^[a-f0-9]{64}$');

  static Map<String, Object?> _object(Object? value) {
    if (value is! Map<Object?, Object?>) _fail('must be an object');
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) _fail('keys must be strings');
      result[key] = entry.value;
    }
    return result;
  }

  static void _equal(Object? actual, Object expected, String path) {
    if (actual != expected) _fail('$path must be $expected');
  }

  static void _nonEmpty(String value, String path) {
    if (value.trim().isEmpty) _fail('$path must not be empty');
  }

  static void _digest(String value, String path) {
    if (!_digestPattern.hasMatch(value)) {
      _fail('$path must be a SHA-256 digest');
    }
  }

  static Never _fail(String message) {
    throw SmfError(message, 'INVALID_CANDIDATE_INTENT');
  }
}

CandidateIntent _decodeCandidateIntent(Object? value, String source) {
  try {
    final json = CandidateIntent._object(value);
    CandidateIntent._equal(json['schemaVersion'], 1, 'schemaVersion');
    final intent = _$CandidateIntentFromJson(json);
    if (!CandidateIntent._versionPattern.hasMatch(intent.version)) {
      CandidateIntent._fail('version must be major.minor.patch');
    }
    if (!CandidateIntent._buildNumberPattern.hasMatch(intent.buildNumber)) {
      CandidateIntent._fail('buildNumber must contain only digits');
    }
    CandidateIntent._nonEmpty(intent.applicationId, 'applicationId');
    CandidateIntent._nonEmpty(
      intent.storeApplicationId,
      'storeApplicationId',
    );
    if (!CandidateIntent._gitShaPattern.hasMatch(intent.sourceSha)) {
      CandidateIntent._fail('sourceSha must be a complete Git SHA');
    }
    CandidateIntent._digest(
      intent.sourceFingerprint,
      'sourceFingerprint',
    );
    CandidateIntent._digest(intent.artifactSha256, 'artifactSha256');
    if (!intent.preparedAt.isUtc) {
      CandidateIntent._fail(
        'preparedAt must be an ISO-8601 UTC timestamp',
      );
    }
    return intent;
  } on Object catch (error) {
    final message = error is SmfError ? error.message : error.toString();
    throw SmfError(
      '$source is invalid:\n$message',
      'INVALID_CANDIDATE_INTENT',
      cause: error,
    );
  }
}
