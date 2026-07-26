import 'model.dart';

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
        (MapEntry<String, List<ConventionalChange>> entry) =>
            '## ${entry.key}\n\n'
            '${entry.value.map(formatChange).join('\n')}',
      )
      .join('\n\n');
  final platformName = platform == Platform.ios ? 'iOS' : platform.value;
  return '# $platformName ${release.version}\n\n$sections\n';
}

String releasePullRequestBody(Platform platform, ChangelogRelease release) {
  final notes = releaseNotesMarkdown(platform, release);
  const deliveryMessage =
      'Merging this PR promotes the exact committed TestFlight candidate. If '
      'build inputs change after the candidate is uploaded, ship-my-flutter '
      'refuses promotion until a new candidate is produced.';
  return <String>[
    '<!-- ship-my-flutter:release-pr -->',
    notes.trim(),
    '',
    '## Delivery',
    '',
    '- [ ] The TestFlight candidate receipt is committed',
    '- [ ] The candidate has been tested',
    '- [ ] Store release notes have been reviewed',
    '',
    deliveryMessage,
  ].join('\n');
}
