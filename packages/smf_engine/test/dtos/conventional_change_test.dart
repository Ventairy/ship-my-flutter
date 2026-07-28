import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when decoding a conventional change, it should preserve its typed JSON',
    () {
      final json = <String, Object?>{
        'sha': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        'type': 'feat',
        'scope': 'ios',
        'description': 'add release automation',
        'body': null,
        'breaking': false,
        'versionBump': 'minor',
        'platforms': <Object?>['ios'],
      };

      expect(ConventionalChange.fromJson(json).toJson(), json);
    },
  );
}
