import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when a release manifest is encoded, it should preserve its nested JSON shape',
    () {
      final json = <String, Object?>{
        'schemaVersion': 1,
        'platforms': <String, Object?>{
          'ios': <String, Object?>{
            'version': '1.2.0',
            'endCommitHash': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
            'isReleasePending': true,
          },
          'android': <String, Object?>{
            'version': '2.3.0',
            'endCommitHash': 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
            'isReleasePending': false,
          },
        },
      };

      expect(ManifestDto.fromJson(json).toJson(), json);
    },
  );
}
