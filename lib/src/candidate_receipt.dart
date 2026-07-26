import 'dart:io';

import 'error.dart';
import 'model.dart';
import 'serialization.dart';

CandidateReceipt validateCandidateReceipt(
  Object? value, {
  String source = 'candidate receipt',
}) {
  try {
    final receipt = _map(value);
    _equal(receipt['schemaVersion'], 1, 'schemaVersion');
    _equal(receipt['platform'], 'ios', 'platform');
    _equal(receipt['processingState'], 'VALID', 'processingState');
    final version = _string(receipt['version'], 'version');
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) {
      _fail('version must be major.minor.patch');
    }
    final buildNumber = _string(receipt['buildNumber'], 'buildNumber');
    if (!RegExp(r'^\d+$').hasMatch(buildNumber)) {
      _fail('buildNumber must contain only digits');
    }
    final sourceSha = _string(receipt['sourceSha'], 'sourceSha');
    if (!RegExp(r'^(?:[a-f0-9]{40}|[a-f0-9]{64})$').hasMatch(sourceSha)) {
      _fail('sourceSha must be a complete Git SHA');
    }
    final sourceFingerprint = _digest(
      receipt['sourceFingerprint'],
      'sourceFingerprint',
    );
    final ipaSha256 = _digest(receipt['ipaSha256'], 'ipaSha256');
    final uploadedAt = _dateTime(receipt['uploadedAt'], 'uploadedAt');
    final groupsValue = receipt['testflightGroups'];
    if (groupsValue is! List<Object?>) {
      _fail('testflightGroups must be a list');
    }
    final groups = <String>[
      for (final group in groupsValue)
        _nonEmptyString(group, 'testflightGroups'),
    ];
    return CandidateReceipt(
      version: version,
      buildNumber: buildNumber,
      buildId: _nonEmptyString(receipt['buildId'], 'buildId'),
      appId: _nonEmptyString(receipt['appId'], 'appId'),
      bundleId: _nonEmptyString(receipt['bundleId'], 'bundleId'),
      sourceSha: sourceSha,
      sourceFingerprint: sourceFingerprint,
      ipaSha256: ipaSha256,
      uploadedAt: uploadedAt,
      testflightGroups: List<String>.unmodifiable(groups),
    );
  } on ShipError catch (error) {
    throw ShipError(
      '$source is invalid:\n${error.message}',
      'INVALID_CANDIDATE_RECEIPT',
      cause: error,
    );
  }
}

Future<CandidateReceipt> loadCandidateReceipt(String filePath) async {
  try {
    return validateCandidateReceipt(await readJson(filePath), source: filePath);
  } on FileSystemException catch (error) {
    throw ShipError(
      'Could not read $filePath: ${error.message}',
      'CANDIDATE_RECEIPT_NOT_FOUND',
      cause: error,
    );
  }
}

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) _fail('must be an object');
  return <String, Object?>{
    for (final entry in value.entries)
      if (entry.key is String) entry.key! as String: entry.value,
  };
}

void _equal(Object? actual, Object expected, String path) {
  if (actual != expected) _fail('$path must be $expected');
}

String _string(Object? value, String path) {
  if (value is! String) _fail('$path must be a string');
  return value;
}

String _nonEmptyString(Object? value, String path) {
  final result = _string(value, path);
  if (result.isEmpty) _fail('$path must not be empty');
  return result;
}

String _digest(Object? value, String path) {
  final result = _string(value, path);
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(result)) {
    _fail('$path must be a SHA-256 digest');
  }
  return result;
}

DateTime _dateTime(Object? value, String path) {
  final source = _string(value, path);
  try {
    return DateTime.parse(source).toUtc();
  } on FormatException {
    _fail('$path must be an ISO-8601 date-time');
  }
}

Never _fail(String message) =>
    throw ShipError(message, 'INVALID_CANDIDATE_RECEIPT');
