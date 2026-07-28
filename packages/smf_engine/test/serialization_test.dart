import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when YAML contains a non-string mapping key, it should reject the document',
    () {
      expect(
        () => SmfFileSystem.parseYaml('1: numeric\n'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('mapping keys must be strings'),
          ),
        ),
      );
    },
  );
}
