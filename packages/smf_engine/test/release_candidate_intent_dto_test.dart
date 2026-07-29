import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when an intent contains an unknown field, it should reject the persisted contract',
    () {
      final intent = ReleaseCandidateIntentDto(
        schemaVersion: 1,
        platform: ReleasePlatform.ios,
        version: '1.2.3',
        buildNumber: '17',
        applicationId: 'dev.example.app',
        storeApplicationId: 'app-1',
        sourceCommitHash: List<String>.filled(40, 'a').join(),
        sourceFingerprint: List<String>.filled(64, 'b').join(),
        artifactSha256: List<String>.filled(64, 'c').join(),
        preparedAt: DateTime.utc(2026, 7, 28),
      );

      expect(
        () => ReleaseCandidateIntentDto.fromJson(<String, Object?>{
          ...intent.toJson(),
          'unexpected': true,
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.invalidReleaseCandidateIntent,
          ),
        ),
      );
    },
  );

  test(
    'when an intent schema version is not exactly one, it should reject the persisted contract',
    () {
      final intent = ReleaseCandidateIntentDto(
        schemaVersion: 1,
        platform: ReleasePlatform.ios,
        version: '1.2.3',
        buildNumber: '17',
        applicationId: 'dev.example.app',
        storeApplicationId: 'app-1',
        sourceCommitHash: List<String>.filled(40, 'a').join(),
        sourceFingerprint: List<String>.filled(64, 'b').join(),
        artifactSha256: List<String>.filled(64, 'c').join(),
        preparedAt: DateTime.utc(2026, 7, 28),
      );

      for (final invalidSchemaVersion in <Object?>[null, 1.5, 2]) {
        expect(
          () => ReleaseCandidateIntentDto.fromJson(<String, Object?>{
            ...intent.toJson(),
            'schemaVersion': invalidSchemaVersion,
          }),
          throwsA(
            isA<SmfError>().having(
              (error) => error.code,
              'code',
              SmfErrorCode.invalidReleaseCandidateIntent,
            ),
          ),
        );
      }
    },
  );

  test(
    'when an intent contains a whitespace-only application identifier, it should reject the evidence',
    () {
      final intent = ReleaseCandidateIntentDto(
        schemaVersion: 1,
        platform: ReleasePlatform.ios,
        version: '1.2.3',
        buildNumber: '17',
        applicationId: 'dev.example.app',
        storeApplicationId: 'app-1',
        sourceCommitHash: List<String>.filled(40, 'a').join(),
        sourceFingerprint: List<String>.filled(64, 'b').join(),
        artifactSha256: List<String>.filled(64, 'c').join(),
        preparedAt: DateTime.utc(2026, 7, 28),
      );

      expect(
        () => ReleaseCandidateIntentDto.fromJson(<String, Object?>{
          ...intent.toJson(),
          'applicationId': '  ',
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.invalidReleaseCandidateIntent,
          ),
        ),
      );
    },
  );

  test('validates every pattern-constrained JSON field', () {
    final intent = ReleaseCandidateIntentDto(
      schemaVersion: 1,
      platform: ReleasePlatform.ios,
      version: '1.2.3',
      buildNumber: '17',
      applicationId: 'dev.example.app',
      storeApplicationId: 'app-1',
      sourceCommitHash: List<String>.filled(40, 'a').join(),
      sourceFingerprint: List<String>.filled(64, 'b').join(),
      artifactSha256: List<String>.filled(64, 'c').join(),
      preparedAt: DateTime.utc(2026, 7, 28),
    );
    final invalidValues = <String, Object?>{
      'version': '1.2',
      'buildNumber': 'build-17',
      'applicationId': ' ',
      'storeApplicationId': '\t',
      'sourceCommitHash': 'abc123',
      'sourceFingerprint': 'not-a-digest',
      'artifactSha256': 'not-a-digest',
    };

    for (final invalidValue in invalidValues.entries) {
      expect(
        () => ReleaseCandidateIntentDto.fromJson(
          <String, Object?>{
            ...intent.toJson(),
            invalidValue.key: invalidValue.value,
          },
          source: 'intent.json',
        ),
        throwsA(
          isA<SmfError>()
              .having(
                (error) => error.code,
                'code',
                SmfErrorCode.invalidReleaseCandidateIntent,
              )
              .having(
                (error) => error.message,
                'message',
                allOf(contains('intent.json is invalid'), contains(invalidValue.key)),
              ),
        ),
      );
    }
  });

  test('rejects a preparedAt timestamp without an explicit UTC offset', () {
    final intent = ReleaseCandidateIntentDto(
      schemaVersion: 1,
      platform: ReleasePlatform.ios,
      version: '1.2.3',
      buildNumber: '17',
      applicationId: 'dev.example.app',
      storeApplicationId: 'app-1',
      sourceCommitHash: List<String>.filled(40, 'a').join(),
      sourceFingerprint: List<String>.filled(64, 'b').join(),
      artifactSha256: List<String>.filled(64, 'c').join(),
      preparedAt: DateTime.utc(2026, 7, 28),
    );

    expect(
      () => ReleaseCandidateIntentDto.fromJson(<String, Object?>{
        ...intent.toJson(),
        'preparedAt': '2026-07-28T12:00:00',
      }),
      throwsA(
        isA<SmfError>()
            .having(
              (error) => error.code,
              'code',
              SmfErrorCode.invalidReleaseCandidateIntent,
            )
            .having(
              (error) => error.message,
              'message',
              contains('preparedAt must be an ISO-8601 UTC timestamp'),
            ),
      ),
    );
  });

  test('round-trips a strict durable release candidate intent', () async {
    final directory = await Directory.systemTemp.createTemp(
      'smf-release-candidate-intent-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'ios-1.2.3.intent.json');
    final intent = ReleaseCandidateIntentDto(
      schemaVersion: 1,
      platform: ReleasePlatform.ios,
      version: '1.2.3',
      buildNumber: '17',
      applicationId: 'dev.example.app',
      storeApplicationId: 'app-1',
      sourceCommitHash: List<String>.filled(40, 'a').join(),
      sourceFingerprint: List<String>.filled(64, 'b').join(),
      artifactSha256: List<String>.filled(64, 'c').join(),
      preparedAt: DateTime.utc(2026, 7, 28),
    );

    await JsonFile(path).write(intent.toJson());

    expect(await ReleaseCandidateIntentDto.fromJsonFile(path), intent);
    expect(
      () => ReleaseCandidateIntentDto.fromJson(<String, Object?>{
        ...intent.toJson(),
        'artifactSha256': 'not-a-digest',
      }),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          SmfErrorCode.invalidReleaseCandidateIntent,
        ),
      ),
    );
  });
}
