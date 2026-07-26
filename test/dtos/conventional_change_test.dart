import 'package:ship_my_flutter/ship_my_flutter.dart';
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
        'bump': 'minor',
        'platforms': <Object?>['ios'],
      };

      expect(ConventionalChange.fromJson(json).toJson(), json);
    },
  );
}
