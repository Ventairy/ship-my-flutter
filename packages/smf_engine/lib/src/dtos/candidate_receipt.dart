import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/models/release_enums.dart';
import 'package:smf_engine/src/serialization.dart';

part 'candidate_receipt.freezed.dart';

/// Evidence identifying an exact tested store artifact and source tree.
@freezed
abstract class CandidateReceipt with _$CandidateReceipt {
  /// Creates candidate evidence.
  const factory CandidateReceipt({
    required Platform platform,
    required String version,
    required String buildNumber,
    required String artifactId,
    required String applicationId,
    required String storeApplicationId,
    required String sourceSha,
    required String sourceFingerprint,
    required String artifactSha256,
    required DateTime uploadedAt,
    required List<String> testingDestinations,
    @Default('VALID') String processingState,
    @Default(2) int schemaVersion,
  }) = _CandidateReceipt;

  const CandidateReceipt._();

  /// Decodes and validates candidate evidence from persisted JSON.
  factory CandidateReceipt.fromJson(
    Object? value, {
    String source = 'candidate receipt',
  }) {
    try {
      final receipt = _object(value);
      final schemaVersion = receipt['schemaVersion'];
      if (schemaVersion != 1 && schemaVersion != 2) {
        _fail('schemaVersion must be 1 or 2');
      }
      final platform = Platform.parse(
        _nonEmptyString(receipt['platform'], 'platform'),
      );
      if (schemaVersion == 1 && platform != Platform.ios) {
        _fail('schemaVersion 1 only supports ios');
      }
      _equal(receipt['processingState'], 'VALID', 'processingState');
      final version = _string(receipt['version'], 'version');
      if (!_versionPattern.hasMatch(version)) {
        _fail('version must be major.minor.patch');
      }
      final buildNumber = _string(receipt['buildNumber'], 'buildNumber');
      if (!_buildNumberPattern.hasMatch(buildNumber)) {
        _fail('buildNumber must contain only digits');
      }
      final sourceSha = _string(receipt['sourceSha'], 'sourceSha');
      if (!_gitShaPattern.hasMatch(sourceSha)) {
        _fail('sourceSha must be a complete Git SHA');
      }
      final sourceFingerprint = _digest(
        receipt['sourceFingerprint'],
        'sourceFingerprint',
      );
      final artifactSha256 = _digest(
        schemaVersion == 1 ? receipt['ipaSha256'] : receipt['artifactSha256'],
        'artifactSha256',
      );
      final uploadedAt = _dateTime(receipt['uploadedAt'], 'uploadedAt');
      final destinationsValue = schemaVersion == 1 ? receipt['testflightGroups'] : receipt['testingDestinations'];
      if (destinationsValue is! List<Object?>) {
        _fail('testingDestinations must be a list');
      }
      return CandidateReceipt(
        platform: platform,
        version: version,
        buildNumber: buildNumber,
        artifactId: _nonEmptyString(
          schemaVersion == 1 ? receipt['buildId'] : receipt['artifactId'],
          'artifactId',
        ),
        applicationId: _nonEmptyString(
          schemaVersion == 1 ? receipt['bundleId'] : receipt['applicationId'],
          'applicationId',
        ),
        storeApplicationId: _nonEmptyString(
          schemaVersion == 1 ? receipt['appId'] : receipt['storeApplicationId'],
          'storeApplicationId',
        ),
        sourceSha: sourceSha,
        sourceFingerprint: sourceFingerprint,
        artifactSha256: artifactSha256,
        uploadedAt: uploadedAt,
        testingDestinations: <String>[
          for (final destination in destinationsValue) _nonEmptyString(destination, 'testingDestinations'),
        ],
      );
    } on Object catch (error) {
      final message = error is SmfError ? error.message : error.toString();
      throw SmfError(
        '$source is invalid:\n$message',
        'INVALID_CANDIDATE_RECEIPT',
        cause: error,
      );
    }
  }

  /// Reads and validates candidate evidence from [filePath].
  static Future<CandidateReceipt> read(String filePath) async {
    try {
      return CandidateReceipt.fromJson(
        await SmfFileSystem.readJson(filePath),
        source: filePath,
      );
    } on FileSystemException catch (error) {
      throw SmfError(
        'Could not read $filePath: ${error.message}',
        'CANDIDATE_RECEIPT_NOT_FOUND',
        cause: error,
      );
    } on FormatException catch (error) {
      throw SmfError(
        '$filePath contains malformed JSON.',
        'INVALID_CANDIDATE_RECEIPT',
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

  /// Encodes the immutable candidate receipt contract.
  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'platform': platform.value,
    'version': version,
    'buildNumber': buildNumber,
    'artifactId': artifactId,
    'applicationId': applicationId,
    'storeApplicationId': storeApplicationId,
    'sourceSha': sourceSha,
    'sourceFingerprint': sourceFingerprint,
    'artifactSha256': artifactSha256,
    'uploadedAt': uploadedAt.toUtc().toIso8601String(),
    'processingState': processingState,
    'testingDestinations': testingDestinations,
  };

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
    final source = _string(value, path);
    try {
      return DateTime.parse(source).toUtc();
    } on FormatException {
      _fail('$path must be an ISO-8601 date-time');
    }
  }

  static Never _fail(String message) {
    throw SmfError(message, 'INVALID_CANDIDATE_RECEIPT');
  }
}
