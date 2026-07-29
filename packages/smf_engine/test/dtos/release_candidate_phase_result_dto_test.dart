import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when encoding release candidate evidence, it should use the release candidate receipts field',
    () {
      final candidate = ReleaseCandidateReceiptDto(
        schemaVersion: 1,
        platform: ReleasePlatform.ios,
        version: '1.2.0',
        buildNumber: '7',
        artifactId: 'build-7',
        applicationId: 'dev.example.app',
        storeApplicationId: 'app-1',
        sourceCommitHash: List<String>.filled(40, 'a').join(),
        sourceFingerprint: List<String>.filled(64, 'b').join(),
        artifactSha256: List<String>.filled(64, 'c').join(),
        uploadedAt: DateTime.utc(2026, 7, 28),
        testingDestinations: const <String>['Internal'],
        processingState: 'VALID',
      );

      expect(
        ReleaseCandidatePhaseResultDto(
          releaseCandidateReceipts: <ReleaseCandidateReceiptDto>[candidate],
        ).toJson(),
        <String, Object?>{
          'releaseCandidateReceipts': <Object?>[candidate.toJson()],
        },
      );
    },
  );
}
