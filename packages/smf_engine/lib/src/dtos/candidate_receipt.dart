import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/dtos/utc_date_time_converter.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/models/release_enums.dart';
import 'package:smf_engine/src/serialization.dart';

part 'candidate_receipt.freezed.dart';
part 'candidate_receipt.g.dart';

/// Evidence identifying an exact tested store artifact and source tree.
@freezed
abstract class CandidateReceipt with _$CandidateReceipt {
  /// Creates candidate evidence.
  @JsonSerializable(
    checked: true,
    disallowUnrecognizedKeys: true,
  )
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
    @UtcDateTimeConverter() required DateTime uploadedAt,
    required List<String> testingDestinations,
    @Default('VALID') String processingState,
    @JsonKey(required: true) @Default(2) int schemaVersion,
  }) = _CandidateReceipt;

  const CandidateReceipt._();

  /// Decodes and validates candidate evidence from persisted JSON.
  factory CandidateReceipt.fromJson(
    Object? value, {
    String source = 'candidate receipt',
  }) => _decodeCandidateReceipt(value, source);

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

  static const Set<String> _schemaVersionOneFields = <String>{
    'schemaVersion',
    'platform',
    'version',
    'buildNumber',
    'buildId',
    'bundleId',
    'appId',
    'sourceSha',
    'sourceFingerprint',
    'ipaSha256',
    'uploadedAt',
    'processingState',
    'testflightGroups',
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

  static void _nonEmpty(String value, String path) {
    if (value.trim().isEmpty) _fail('$path must not be empty');
  }

  static void _digest(String value, String path) {
    if (!_digestPattern.hasMatch(value)) {
      _fail('$path must be a SHA-256 digest');
    }
  }

  static Map<String, Object?> _normalize(Object? value) {
    final receipt = _object(value);
    final schemaVersion = receipt['schemaVersion'];
    if (schemaVersion is! int) {
      _fail('schemaVersion must be 1 or 2');
    }
    _equal(receipt['processingState'], 'VALID', 'processingState');
    return switch (schemaVersion) {
      1 => _normalizeSchemaVersionOne(receipt),
      2 => receipt,
      _ => _fail('schemaVersion must be 1 or 2'),
    };
  }

  static Map<String, Object?> _normalizeSchemaVersionOne(
    Map<String, Object?> receipt,
  ) {
    _checkedFields(receipt, _schemaVersionOneFields);
    if (receipt['platform'] != 'ios') {
      _fail('schemaVersion 1 only supports ios');
    }
    return <String, Object?>{
      'schemaVersion': 2,
      'platform': receipt['platform'],
      'version': receipt['version'],
      'buildNumber': receipt['buildNumber'],
      'artifactId': receipt['buildId'],
      'applicationId': receipt['bundleId'],
      'storeApplicationId': receipt['appId'],
      'sourceSha': receipt['sourceSha'],
      'sourceFingerprint': receipt['sourceFingerprint'],
      'artifactSha256': receipt['ipaSha256'],
      'uploadedAt': receipt['uploadedAt'],
      'processingState': receipt['processingState'],
      'testingDestinations': receipt['testflightGroups'],
    };
  }

  static Map<String, Object?> _checkedFields(
    Map<String, Object?> value,
    Set<String> allowedFields,
  ) {
    for (final field in value.keys) {
      if (!allowedFields.contains(field)) {
        _fail('contains unknown field "$field"');
      }
    }
    return value;
  }

  static Never _fail(String message) {
    throw SmfError(message, 'INVALID_CANDIDATE_RECEIPT');
  }
}

CandidateReceipt _decodeCandidateReceipt(Object? value, String source) {
  try {
    final receipt = _$CandidateReceiptFromJson(
      CandidateReceipt._normalize(value),
    );
    if (!CandidateReceipt._versionPattern.hasMatch(receipt.version)) {
      CandidateReceipt._fail('version must be major.minor.patch');
    }
    if (!CandidateReceipt._buildNumberPattern.hasMatch(receipt.buildNumber)) {
      CandidateReceipt._fail('buildNumber must contain only digits');
    }
    CandidateReceipt._nonEmpty(receipt.artifactId, 'artifactId');
    CandidateReceipt._nonEmpty(receipt.applicationId, 'applicationId');
    CandidateReceipt._nonEmpty(
      receipt.storeApplicationId,
      'storeApplicationId',
    );
    if (!CandidateReceipt._gitShaPattern.hasMatch(receipt.sourceSha)) {
      CandidateReceipt._fail('sourceSha must be a complete Git SHA');
    }
    CandidateReceipt._digest(
      receipt.sourceFingerprint,
      'sourceFingerprint',
    );
    CandidateReceipt._digest(receipt.artifactSha256, 'artifactSha256');
    for (final destination in receipt.testingDestinations) {
      CandidateReceipt._nonEmpty(destination, 'testingDestinations');
    }
    if (receipt.testingDestinations.toSet().length != receipt.testingDestinations.length) {
      CandidateReceipt._fail('testingDestinations must not contain duplicates');
    }
    return receipt;
  } on Object catch (error) {
    final message = error is SmfError ? error.message : error.toString();
    throw SmfError(
      '$source is invalid:\n$message',
      'INVALID_CANDIDATE_RECEIPT',
      cause: error,
    );
  }
}
