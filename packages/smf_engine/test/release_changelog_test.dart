import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

final class _ChangelogFixture {
  const _ChangelogFixture._();

  static ChangelogPlatformReleaseVersionDto release({
    String version = '1.2.3',
    List<ConventionalChangeDto>? changes,
  }) {
    return ChangelogPlatformReleaseVersionDto(
      version: version,
      preparedAt: DateTime.utc(2026, 7, 28),
      baseCommitHash: List<String>.filled(40, 'a').join(),
      endCommitHash: List<String>.filled(40, 'b').join(),
      changes:
          changes ??
          <ConventionalChangeDto>[
            const ConventionalChangeDto(
              commitHash: '1234567890abcdef',
              type: 'feat',
              scope: 'search',
              description: 'show nearby work',
              body: null,
              isBreaking: false,
              versionBumpType: VersionBumpType.minor,
              platforms: <ReleasePlatform>[ReleasePlatform.ios],
            ),
          ],
    );
  }
}

void main() {
  test('when formatting a release, it should group changes into readable Markdown', () {
    final markdown = ReleaseChangelog.markdown(
      platform: ReleasePlatform.ios,
      release: _ChangelogFixture.release(),
    );

    expect(
      markdown,
      '# iOS 1.2.3\n\n'
      '## Features\n\n'
      '- **search:** show nearby work (1234567)\n',
    );
  });

  test('when formatting a multi-platform pull request, it should include every release candidate checklist', () {
    final body = ReleaseChangelog.pullRequestBody(
      releases: <ReleasePlatform, ChangelogPlatformReleaseVersionDto>{
        ReleasePlatform.ios: _ChangelogFixture.release(),
        ReleasePlatform.android: _ChangelogFixture.release(version: '2.0.0'),
      },
    );

    expect(
      body,
      contains(
        '- [ ] iOS release candidate receipt is committed and tested\n'
        '- [ ] Android release candidate receipt is committed and tested',
      ),
    );
  });
}
