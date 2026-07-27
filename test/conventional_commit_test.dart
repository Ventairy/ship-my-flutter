import 'package:smf/smf.dart';
import 'package:test/test.dart';

void main() {
  group('platform-scoped Conventional Commits', () {
    final cases = <(String, List<Platform>, Bump?)>[
      ('feat: shared feature', <Platform>[Platform.ios], Bump.minor),
      (
        'feat(auth): shared scoped feature',
        <Platform>[Platform.ios],
        Bump.minor,
      ),
      ('fix(ios): iPhone fix', <Platform>[Platform.ios], Bump.patch),
      ('fix(android): Android-only fix', <Platform>[], Bump.patch),
      ('fix(web): browser-only fix', <Platform>[], Bump.patch),
      (
        'perf(ios,android): faster startup',
        <Platform>[Platform.ios],
        Bump.patch,
      ),
      ('chore(ios): maintenance', <Platform>[Platform.ios], null),
    ];

    for (final (message, platforms, bump) in cases) {
      test('parses $message', () {
        final change = parseConventionalCommit('abcdef123456', message);
        expect(change.platforms, platforms);
        expect(change.bump, bump);
      });
    }

    test('treats a breaking footer as a major release', () {
      final change = parseConventionalCommit(
        'abcdef123456',
        'refactor(ios): replace storage\n\n'
            'BREAKING CHANGE: old data is unsupported',
      );
      expect(change.breaking, isTrue);
      expect(change.bump, Bump.major);
    });

    test('supports global and platform Release-As footers', () {
      expect(
        parseConventionalCommit(
          'a',
          'chore: release\n\nRelease-As: 2.0.0',
        ).releaseAs,
        '2.0.0',
      );
      expect(
        parseConventionalCommit(
          'b',
          'chore: release\n\nRelease-As-ios: 3.0.0',
        ).releaseAs,
        '3.0.0',
      );
    });

    test('ignores prerelease and build-metadata Release-As values', () {
      expect(
        parseConventionalCommit(
          'a',
          'chore: release\n\nRelease-As: 2.0.0-beta.1',
        ).releaseAs,
        isNull,
      );
      expect(
        parseConventionalCommit(
          'b',
          'chore: release\n\nRelease-As: 2.0.0+7',
        ).releaseAs,
        isNull,
      );
    });

    test('selects the highest required bump', () {
      final changes = <ConventionalChange>[
        parseConventionalCommit('a', 'fix: one'),
        parseConventionalCommit('b', 'feat: two'),
        parseConventionalCommit('c', 'fix!: three'),
      ];
      expect(highestBump(changes), Bump.major);
    });
  });
}
