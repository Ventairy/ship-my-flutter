import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

final class _ReleaseCandidateReceiptFixture {
  const _ReleaseCandidateReceiptFixture._();

  static Map<String, Object?> json() => <String, Object?>{
    'schemaVersion': 1,
    'platform': 'ios',
    'version': '1.2.3',
    'buildNumber': '7',
    'artifactId': 'build-7',
    'applicationId': 'dev.example.app',
    'storeApplicationId': 'app-1',
    'sourceCommitHash': _repeated('a', 40),
    'sourceFingerprint': _repeated('b', 64),
    'artifactSha256': _repeated('c', 64),
    'uploadedAt': '2026-07-26T00:00:00.000Z',
    'processingState': 'VALID',
    'testingDestinations': <Object?>['Internal'],
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
        () => ReleaseCandidateReceiptDto.fromJson(<String, Object?>{
          ..._ReleaseCandidateReceiptFixture.json(),
          'unexpected': true,
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.invalidReleaseCandidateReceipt,
          ),
        ),
      );
    },
  );

  test(
    'when a current receipt contains an unknown field, it should reject the generated contract',
    () {
      final receipt = ReleaseCandidateReceiptDto.fromJson(
        _ReleaseCandidateReceiptFixture.json(),
      ).toJson()..['unexpected'] = true;

      expect(
        () => ReleaseCandidateReceiptDto.fromJson(receipt),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.invalidReleaseCandidateReceipt,
          ),
        ),
      );
    },
  );

  test(
    'when a receipt uses another schema version, it should reject the persisted contract',
    () {
      expect(
        () => ReleaseCandidateReceiptDto.fromJson(<String, Object?>{
          ..._ReleaseCandidateReceiptFixture.json(),
          'schemaVersion': 2,
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.invalidReleaseCandidateReceipt,
          ),
        ),
      );
    },
  );

  test(
    'when a receipt omits its processing state, it should reject the persisted contract',
    () {
      final receipt = _ReleaseCandidateReceiptFixture.json()..remove('processingState');

      expect(
        () => ReleaseCandidateReceiptDto.fromJson(receipt),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.invalidReleaseCandidateReceipt,
          ),
        ),
      );
    },
  );

  test(
    'when a receipt time has an offset, it should normalize the time to UTC',
    () {
      final receipt = _ReleaseCandidateReceiptFixture.json()..['uploadedAt'] = '2026-07-25T21:00:00-03:00';

      expect(
        ReleaseCandidateReceiptDto.fromJson(receipt).uploadedAt,
        DateTime.utc(2026, 7, 26),
      );
    },
  );

  test(
    'when a receipt repeats a testing destination, it should reject ambiguous evidence',
    () {
      final receipt = _ReleaseCandidateReceiptFixture.json()
        ..['testingDestinations'] = <Object?>['Internal', 'Internal'];

      expect(
        () => ReleaseCandidateReceiptDto.fromJson(receipt),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.invalidReleaseCandidateReceipt,
          ),
        ),
      );
    },
  );

  test('maps malformed JSON to the generic JSON failure', () async {
    final directory = await Directory.systemTemp.createTemp('smf-receipt-');
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'release_candidate.json');
    await File(path).writeAsString('{not-json');

    await expectLater(
      ReleaseCandidateReceiptDto.fromJsonFilePath(path),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          SmfErrorCode.jsonMalformed,
        ),
      ),
    );
  });

  group('release candidate receipts', () {
    test('accepts the complete immutable receipt contract', () {
      final parsed = ReleaseCandidateReceiptDto.fromJson(_ReleaseCandidateReceiptFixture.json());
      expect(parsed.version, '1.2.3');
    });

    test('accepts the immutable artifact identity', () {
      final parsed = ReleaseCandidateReceiptDto.fromJson(_ReleaseCandidateReceiptFixture.json());

      expect(parsed.artifactId, 'build-7');
    });

    test('rejects malformed identity and digest fields', () {
      final malformed = _ReleaseCandidateReceiptFixture.json()
        ..['buildNumber'] = 'latest'
        ..['sourceFingerprint'] = 'short';
      expect(
        () => ReleaseCandidateReceiptDto.fromJson(malformed),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('release candidate receipt is invalid'),
          ),
        ),
      );
    });
  });
}
