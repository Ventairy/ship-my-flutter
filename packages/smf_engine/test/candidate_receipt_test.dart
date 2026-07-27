import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

String repeated(String value, int count) =>
    List<String>.filled(count, value).join();

Map<String, Object?> receipt() => <String, Object?>{
  'schemaVersion': 1,
  'platform': 'ios',
  'version': '1.2.3',
  'buildNumber': '7',
  'buildId': 'build-7',
  'appId': 'app-1',
  'bundleId': 'dev.example.app',
  'sourceSha': repeated('a', 40),
  'sourceFingerprint': repeated('b', 64),
  'ipaSha256': repeated('c', 64),
  'uploadedAt': '2026-07-26T00:00:00.000Z',
  'processingState': 'VALID',
  'testflightGroups': <Object?>['Internal'],
};

void main() {
  test('maps malformed JSON to a typed candidate receipt failure', () async {
    final directory = await Directory.systemTemp.createTemp('smf-receipt-');
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'candidate.json');
    await File(path).writeAsString('{not-json');

    await expectLater(
      loadCandidateReceipt(path),
      throwsA(
        isA<SmfError>().having(
          (SmfError error) => error.code,
          'code',
          'INVALID_CANDIDATE_RECEIPT',
        ),
      ),
    );
  });

  group('candidate receipts', () {
    test('accepts the complete immutable receipt contract', () {
      final parsed = validateCandidateReceipt(receipt());
      expect(parsed.version, '1.2.3');
      expect(parsed.buildId, 'build-7');
    });

    test('rejects malformed identity and digest fields', () {
      final malformed = receipt()
        ..['buildNumber'] = 'latest'
        ..['sourceFingerprint'] = 'short';
      expect(
        () => validateCandidateReceipt(malformed),
        throwsA(
          isA<SmfError>().having(
            (SmfError error) => error.message,
            'message',
            contains('candidate receipt is invalid'),
          ),
        ),
      );
    });
  });
}
