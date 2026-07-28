import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  group('platform-scoped Conventional Commits', () {
    final cases = <(String, List<Platform>, VersionBump?)>[
      ('feat: shared feature', Platform.values, VersionBump.minor),
      (
        'feat(auth): shared scoped feature',
        Platform.values,
        VersionBump.minor,
      ),
      (
        'fix(ios): iPhone fix',
        <Platform>[Platform.ios],
        VersionBump.patch,
      ),
      (
        'fix(android): Android-only fix',
        <Platform>[Platform.android],
        VersionBump.patch,
      ),
      ('fix(web): browser-only fix', <Platform>[], VersionBump.patch),
      (
        'perf(ios,android): faster startup',
        Platform.values,
        VersionBump.patch,
      ),
      ('chore(ios): maintenance', <Platform>[Platform.ios], null),
    ];

    for (final (message, platforms, versionBump) in cases) {
      test('parses $message', () {
        final change = ConventionalCommit.parse('abcdef123456', message);
        expect(change.platforms, platforms);
        expect(change.versionBump, versionBump);
      });
    }

    test('treats a breaking footer as a major release', () {
      final change = ConventionalCommit.parse(
        'abcdef123456',
        'refactor(ios): replace storage\n\n'
            'BREAKING CHANGE: old data is unsupported',
      );
      expect(change.breaking, isTrue);
      expect(change.versionBump, VersionBump.major);
    });

    test('selects the highest required bump', () {
      final changes = <ConventionalChange>[
        ConventionalCommit.parse('a', 'fix: one'),
        ConventionalCommit.parse('b', 'feat: two'),
        ConventionalCommit.parse('c', 'fix!: three'),
      ];
      expect(
        ConventionalCommit.highestVersionBump(changes),
        VersionBump.major,
      );
    });
  });
}
