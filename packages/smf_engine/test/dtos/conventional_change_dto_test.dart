import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when decoding a conventional change, it should preserve its typed JSON',
    () {
      final json = <String, Object?>{
        'commitHash': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        'type': 'feat',
        'scope': 'ios',
        'description': 'add release automation',
        'body': null,
        'isBreaking': false,
        'versionBumpType': 'minor',
        'platforms': <Object?>['ios'],
      };

      expect(ConventionalChangeDto.fromJson(json).toJson(), json);
    },
  );
}
