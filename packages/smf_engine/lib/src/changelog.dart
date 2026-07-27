import 'package:smf_engine/src/model.dart';

const Map<String, String> _sectionNames = <String, String>{
  'feat': 'Features',
  'fix': 'Bug Fixes',
  'perf': 'Performance',
  'deps': 'Dependencies',
};

String formatChange(ConventionalChange change) {
  final scope = change.scope == null ? '' : '**${change.scope}:** ';
  final breaking = change.breaking ? '**BREAKING:** ' : '';
  final shortSha = change.sha.substring(
    0,
    change.sha.length < 7 ? change.sha.length : 7,
  );
  return '- $breaking$scope${change.description} ($shortSha)';
}

String releaseNotesMarkdown(Platform platform, ChangelogRelease release) {
  final grouped = <String, List<ConventionalChange>>{};
  for (final change in release.changes) {
    final section = _sectionNames[change.type] ?? 'Other Changes';
    grouped.putIfAbsent(section, () => <ConventionalChange>[]).add(change);
  }
  final sections = grouped.entries
      .map(
        (entry) =>
            '## ${entry.key}\n\n'
            '${entry.value.map(formatChange).join('\n')}',
      )
      .join('\n\n');
  return '# ${platform.displayName} ${release.version}\n\n$sections\n';
}

String releasePullRequestBody(Platform platform, ChangelogRelease release) {
  return combinedReleasePullRequestBody(<Platform, ChangelogRelease>{
    platform: release,
  });
}

/// Builds one pull-request body for every platform release in the branch.
String combinedReleasePullRequestBody(
  Map<Platform, ChangelogRelease> releases,
) {
  final notes = releases.entries
      .map((entry) => releaseNotesMarkdown(entry.key, entry.value).trim())
      .join('\n\n---\n\n');
  final checklist = <String>[
    for (final platform in releases.keys)
      '- [ ] ${platform.displayName} candidate receipt is committed and tested',
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
