import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when a changelog contains ordered releases, it should round-trip the nested DTO shape',
    () {
      final json = <String, Object?>{
        'schemaVersion': 1,
        'platforms': <String, Object?>{
          'ios': <String, Object?>{
            'releases': <Object?>[
              <String, Object?>{
                'version': '1.2.0',
                'preparedAt': '2026-07-26T21:00:00.000Z',
                'baseCommitHash': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
                'endCommitHash': 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
                'changes': <Object?>[],
              },
            ],
          },
          'android': <String, Object?>{
            'releases': <Object?>[],
          },
        },
      };

      expect(ChangelogDto.fromJson(json).toJson(), json);
    },
  );

  test(
    'when encoding a changelog release, it should normalize its time to UTC',
    () {
      final release = ChangelogPlatformReleaseVersionDto(
        version: '1.2.0',
        preparedAt: DateTime.parse('2026-07-26T18:00:00-03:00'),
        baseCommitHash: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        endCommitHash: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        changes: const <ConventionalChangeDto>[],
      );

      expect(release.toJson()['preparedAt'], '2026-07-26T21:00:00.000Z');
    },
  );
}
