import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/models/release_enums.dart';
import 'package:smf_engine/src/serialization.dart';

part 'candidate_intent.freezed.dart';

/// Durable evidence written before SMF uploads a candidate to a store.
///
/// The intent lets a fresh runner recover the exact build after an upload or
/// receipt-push failure without selecting an unrelated store artifact.
@freezed
abstract class CandidateIntent with _$CandidateIntent {
  /// Creates a candidate upload intent.
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
    @Default(1) int schemaVersion,
  }) = _CandidateIntent;

  const CandidateIntent._();

  /// Decodes and validates a persisted candidate intent.
  factory CandidateIntent.fromJson(
    Object? value, {
    String source = 'candidate intent',
  }) {
    try {
      final intent = _object(value);
      _equal(intent['schemaVersion'], 1, 'schemaVersion');
      final version = _string(intent['version'], 'version');
      if (!_versionPattern.hasMatch(version)) {
        _fail('version must be major.minor.patch');
      }
      final buildNumber = _string(intent['buildNumber'], 'buildNumber');
      if (!_buildNumberPattern.hasMatch(buildNumber)) {
        _fail('buildNumber must contain only digits');
      }
      final sourceSha = _string(intent['sourceSha'], 'sourceSha');
      if (!_gitShaPattern.hasMatch(sourceSha)) {
        _fail('sourceSha must be a complete Git SHA');
      }
      return CandidateIntent(
        platform: Platform.parse(
          _nonEmptyString(intent['platform'], 'platform'),
        ),
        version: version,
        buildNumber: buildNumber,
        applicationId: _nonEmptyString(
          intent['applicationId'],
          'applicationId',
        ),
        storeApplicationId: _nonEmptyString(
          intent['storeApplicationId'],
          'storeApplicationId',
        ),
        sourceSha: sourceSha,
        sourceFingerprint: _digest(
          intent['sourceFingerprint'],
          'sourceFingerprint',
        ),
        artifactSha256: _digest(
          intent['artifactSha256'],
          'artifactSha256',
        ),
        preparedAt: _dateTime(intent['preparedAt'], 'preparedAt'),
      );
    } on Object catch (error) {
      final message = error is SmfError ? error.message : error.toString();
      throw SmfError(
        '$source is invalid:\n$message',
        'INVALID_CANDIDATE_INTENT',
        cause: error,
      );
    }
  }

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

  /// Encodes this intent for deterministic persistence.
  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'platform': platform.value,
    'version': version,
    'buildNumber': buildNumber,
    'applicationId': applicationId,
    'storeApplicationId': storeApplicationId,
    'sourceSha': sourceSha,
    'sourceFingerprint': sourceFingerprint,
    'artifactSha256': artifactSha256,
    'preparedAt': preparedAt.toUtc().toIso8601String(),
  };

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

  static String _string(Object? value, String path) {
    if (value is! String) _fail('$path must be a string');
    return value;
  }

  static String _nonEmptyString(Object? value, String path) {
    final result = _string(value, path);
    if (result.isEmpty) _fail('$path must not be empty');
    return result;
  }

  static String _digest(Object? value, String path) {
    final result = _string(value, path);
    if (!_digestPattern.hasMatch(result)) {
      _fail('$path must be a SHA-256 digest');
    }
    return result;
  }

  static DateTime _dateTime(Object? value, String path) {
    final text = _string(value, path);
    final result = DateTime.tryParse(text);
    if (result == null || !result.isUtc) {
      _fail('$path must be an ISO-8601 UTC timestamp');
    }
    return result;
  }

  static Never _fail(String message) {
    throw SmfError(message, 'INVALID_CANDIDATE_INTENT');
  }
}
