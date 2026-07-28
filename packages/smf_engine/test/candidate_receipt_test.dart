import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

final class _CandidateReceiptFixture {
  const _CandidateReceiptFixture._();

  static Map<String, Object?> json() => <String, Object?>{
    'schemaVersion': 1,
    'platform': 'ios',
    'version': '1.2.3',
    'buildNumber': '7',
    'buildId': 'build-7',
    'appId': 'app-1',
    'bundleId': 'dev.example.app',
    'sourceSha': _repeated('a', 40),
    'sourceFingerprint': _repeated('b', 64),
    'ipaSha256': _repeated('c', 64),
    'uploadedAt': '2026-07-26T00:00:00.000Z',
    'processingState': 'VALID',
    'testflightGroups': <Object?>['Internal'],
  };

  static String _repeated(String value, int count) {
    return List<String>.filled(count, value).join();
  }
}

void main() {
  test(
    'when a receipt contains an unknown field, it should reject the persisted contract',
    () {
      expect(
        () => CandidateReceipt.fromJson(<String, Object?>{
          ..._CandidateReceiptFixture.json(),
          'unexpected': true,
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'INVALID_CANDIDATE_RECEIPT',
          ),
        ),
      );
    },
  );

  test(
    'when a current receipt contains an unknown field, it should reject the generated contract',
    () {
      final receipt = CandidateReceipt.fromJson(
        _CandidateReceiptFixture.json(),
      ).toJson()..['unexpected'] = true;

      expect(
        () => CandidateReceipt.fromJson(receipt),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'INVALID_CANDIDATE_RECEIPT',
          ),
        ),
      );
    },
  );

  test(
    'when a receipt has a fractional schema version, it should reject the persisted contract',
    () {
      expect(
        () => CandidateReceipt.fromJson(<String, Object?>{
          ..._CandidateReceiptFixture.json(),
          'schemaVersion': 1.5,
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'INVALID_CANDIDATE_RECEIPT',
          ),
        ),
      );
    },
  );

  test(
    'when a receipt omits its processing state, it should reject the persisted contract',
    () {
      final receipt = _CandidateReceiptFixture.json()..remove('processingState');

      expect(
        () => CandidateReceipt.fromJson(receipt),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'INVALID_CANDIDATE_RECEIPT',
          ),
        ),
      );
    },
  );

  test(
    'when a receipt time has an offset, it should normalize the time to UTC',
    () {
      final receipt = _CandidateReceiptFixture.json()..['uploadedAt'] = '2026-07-25T21:00:00-03:00';

      expect(
        CandidateReceipt.fromJson(receipt).uploadedAt,
        DateTime.utc(2026, 7, 26),
      );
    },
  );

  test(
    'when a receipt repeats a testing destination, it should reject ambiguous evidence',
    () {
      final receipt = _CandidateReceiptFixture.json()..['testflightGroups'] = <Object?>['Internal', 'Internal'];

      expect(
        () => CandidateReceipt.fromJson(receipt),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'INVALID_CANDIDATE_RECEIPT',
          ),
        ),
      );
    },
  );

  test('maps malformed JSON to a typed candidate receipt failure', () async {
    final directory = await Directory.systemTemp.createTemp('smf-receipt-');
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'candidate.json');
    await File(path).writeAsString('{not-json');

    await expectLater(
      CandidateReceipt.read(path),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'INVALID_CANDIDATE_RECEIPT',
        ),
      ),
    );
  });

  group('candidate receipts', () {
    test('accepts the complete immutable receipt contract', () {
      final parsed = CandidateReceipt.fromJson(_CandidateReceiptFixture.json());
      expect(parsed.version, '1.2.3');
    });

    test('accepts the immutable artifact identity', () {
      final parsed = CandidateReceipt.fromJson(_CandidateReceiptFixture.json());

      expect(parsed.artifactId, 'build-7');
    });

    test('rejects malformed identity and digest fields', () {
      final malformed = _CandidateReceiptFixture.json()
        ..['buildNumber'] = 'latest'
        ..['sourceFingerprint'] = 'short';
      expect(
        () => CandidateReceipt.fromJson(malformed),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('candidate receipt is invalid'),
          ),
        ),
      );
    });
  });
}
