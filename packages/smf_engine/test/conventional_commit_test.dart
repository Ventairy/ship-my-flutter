import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  group('platform-scoped Conventional Commits', () {
    final cases = <(String, List<ReleasePlatform>, VersionBumpType?)>[
      ('feat: shared feature', ReleasePlatform.values, VersionBumpType.minor),
      (
        'feat(auth): shared scoped feature',
        ReleasePlatform.values,
        VersionBumpType.minor,
      ),
      (
        'fix(ios): iPhone fix',
        <ReleasePlatform>[ReleasePlatform.ios],
        VersionBumpType.patch,
      ),
      (
        'fix(android): Android-only fix',
        <ReleasePlatform>[ReleasePlatform.android],
        VersionBumpType.patch,
      ),
      ('fix(web): browser-only fix', <ReleasePlatform>[], VersionBumpType.patch),
      (
        'perf(ios,android): faster startup',
        ReleasePlatform.values,
        VersionBumpType.patch,
      ),
      ('chore(ios): maintenance', <ReleasePlatform>[ReleasePlatform.ios], null),
    ];

    for (final (message, platforms, versionBumpType) in cases) {
      test('parses $message', () {
        final change = ConventionalCommit.parse('abcdef123456', message);
        expect(change.platforms, platforms);
        expect(change.versionBumpType, versionBumpType);
      });
    }

    test('treats a breaking footer as a major release', () {
      final change = ConventionalCommit.parse(
        'abcdef123456',
        'refactor(ios): replace storage\n\n'
            'BREAKING CHANGE: old data is unsupported',
      );
      expect(change.isBreaking, isTrue);
      expect(change.versionBumpType, VersionBumpType.major);
    });

    test('selects the highest required bump', () {
      final changes = <ConventionalChangeDto>[
        ConventionalCommit.parse('a', 'fix: one'),
        ConventionalCommit.parse('b', 'feat: two'),
        ConventionalCommit.parse('c', 'fix!: three'),
      ];
      expect(
        ConventionalCommit.highestVersionBumpType(changes),
        VersionBumpType.major,
      );
    });
  });
}
