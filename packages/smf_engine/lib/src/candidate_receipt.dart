import 'dart:io';

import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/serialization.dart';

CandidateReceipt validateCandidateReceipt(
  Object? value, {
  String source = 'candidate receipt',
}) {
  try {
    final receipt = _map(value);
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
    final artifactSha256 = _digest(
      schemaVersion == 1 ? receipt['ipaSha256'] : receipt['artifactSha256'],
      'artifactSha256',
    );
    final uploadedAt = _dateTime(receipt['uploadedAt'], 'uploadedAt');
    final groupsValue = schemaVersion == 1
        ? receipt['testflightGroups']
        : receipt['testingDestinations'];
    if (groupsValue is! List<Object?>) {
      _fail('testingDestinations must be a list');
    }
    final groups = <String>[
      for (final group in groupsValue)
        _nonEmptyString(group, 'testingDestinations'),
    ];
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
      testingDestinations: groups,
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

Future<CandidateReceipt> loadCandidateReceipt(String filePath) async {
  try {
    return validateCandidateReceipt(await readJson(filePath), source: filePath);
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

Map<String, Object?> _map(Object? value) {
  if (value is! Map<Object?, Object?>) _fail('must be an object');
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) _fail('keys must be strings');
    result[key] = entry.value;
  }
  return result;
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
    throw SmfError(message, 'INVALID_CANDIDATE_RECEIPT');
