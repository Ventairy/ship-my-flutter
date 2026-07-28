import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('round-trips a strict durable candidate intent', () async {
    final directory = await Directory.systemTemp.createTemp(
      'smf-candidate-intent-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'ios-1.2.3.intent.json');
    final intent = CandidateIntent(
      platform: Platform.ios,
      version: '1.2.3',
      buildNumber: '17',
      applicationId: 'dev.example.app',
      storeApplicationId: 'app-1',
      sourceSha: List<String>.filled(40, 'a').join(),
      sourceFingerprint: List<String>.filled(64, 'b').join(),
      artifactSha256: List<String>.filled(64, 'c').join(),
      preparedAt: DateTime.utc(2026, 7, 28),
    );

    await SmfFileSystem.writeJson(path, intent.toJson());

    expect(await CandidateIntent.read(path), intent);
    expect(
      () => CandidateIntent.fromJson(<String, Object?>{
        ...intent.toJson(),
        'artifactSha256': 'not-a-digest',
      }),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'INVALID_CANDIDATE_INTENT',
        ),
      ),
    );
  });
}
