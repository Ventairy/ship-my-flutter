import 'package:smf_engine/src/model.dart';

/// Human-readable release copy derived from typed changelog entries.
final class ReleaseChangelog {
  const ReleaseChangelog._();

  static const Map<String, String> _sectionNames = <String, String>{
    'feat': 'Features',
    'fix': 'Bug Fixes',
    'perf': 'Performance',
    'deps': 'Dependencies',
  };

  /// Formats one platform release for a GitHub Release.
  static String markdown({
    required Platform platform,
    required ChangelogRelease release,
  }) {
    final grouped = <String, List<ConventionalChange>>{};
    for (final change in release.changes) {
      final section = _sectionNames[change.type] ?? 'Other Changes';
      grouped.putIfAbsent(section, () => <ConventionalChange>[]).add(change);
    }
    final sections = grouped.entries
        .map(
          (entry) =>
              '## ${entry.key}\n\n'
              '${entry.value.map(_formatChange).join('\n')}',
        )
        .join('\n\n');
    return '# ${platform.displayName} ${release.version}\n\n$sections\n';
  }

  /// Builds one pull-request body for every platform release in the branch.
  static String pullRequestBody({
    required Map<Platform, ChangelogRelease> releases,
  }) {
    final notes = releases.entries
        .map(
          (entry) => markdown(
            platform: entry.key,
            release: entry.value,
          ).trim(),
        )
        .join('\n\n---\n\n');
    final checklist = <String>[
      for (final platform in releases.keys) '- [ ] ${platform.displayName} candidate receipt is committed and tested',
    ];
    const deliveryMessage =
        'Merging this PR promotes each exact committed store candidate. If build '
        'inputs change after a candidate is uploaded, smf refuses that platform '
        'promotion until a new candidate is produced.';
    return <String>[
      '<!-- smf:release-pr -->',
      notes,
      '',
      '## Delivery',
      '',
      ...checklist,
      '- [ ] Store release notes have been reviewed',
      '',
      deliveryMessage,
    ].join('\n');
  }

  static String _formatChange(ConventionalChange change) {
    final scope = change.scope == null ? '' : '**${change.scope}:** ';
    final breaking = change.breaking ? '**BREAKING:** ' : '';
    final shortSha = change.sha.substring(
      0,
      change.sha.length < 7 ? change.sha.length : 7,
    );
    return '- $breaking$scope${change.description} ($shortSha)';
  }
}
