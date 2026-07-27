import 'package:smf/smf.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when encoding a changelog release, it should normalize its time to UTC',
    () {
      final release = ChangelogRelease(
        version: '1.2.0',
        preparedAt: DateTime.parse('2026-07-26T18:00:00-03:00'),
        baseSha: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        headSha: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        changes: const <ConventionalChange>[],
      );

      expect(release.toJson()['preparedAt'], '2026-07-26T21:00:00.000Z');
    },
  );
}
