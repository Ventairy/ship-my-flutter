import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

final class _ChangelogFixture {
  const _ChangelogFixture._();

  static ChangelogRelease release({
    String version = '1.2.3',
    List<ConventionalChange>? changes,
  }) {
    return ChangelogRelease(
      version: version,
      preparedAt: DateTime.utc(2026, 7, 28),
      baseSha: List<String>.filled(40, 'a').join(),
      headSha: List<String>.filled(40, 'b').join(),
      changes:
          changes ??
          <ConventionalChange>[
            const ConventionalChange(
              sha: '1234567890abcdef',
              type: 'feat',
              scope: 'search',
              description: 'show nearby work',
              body: null,
              breaking: false,
              versionBump: VersionBump.minor,
              platforms: <Platform>[Platform.ios],
            ),
          ],
    );
  }
}

void main() {
  test('when formatting a release, it should group changes into readable Markdown', () {
    final markdown = ReleaseChangelog.markdown(
      platform: Platform.ios,
      release: _ChangelogFixture.release(),
    );

    expect(
      markdown,
      '# iOS 1.2.3\n\n'
      '## Features\n\n'
      '- **search:** show nearby work (1234567)\n',
    );
  });

  test('when formatting a multi-platform pull request, it should include every candidate checklist', () {
    final body = ReleaseChangelog.pullRequestBody(
      releases: <Platform, ChangelogRelease>{
        Platform.ios: _ChangelogFixture.release(),
        Platform.android: _ChangelogFixture.release(version: '2.0.0'),
      },
    );

    expect(
      body,
      contains(
        '- [ ] iOS candidate receipt is committed and tested\n'
        '- [ ] Android candidate receipt is committed and tested',
      ),
    );
  });
}
