import 'package:smf_engine/src/model.dart';

/// Parses Conventional Commits and derives their semantic version impact.
final class ConventionalCommit {
  const ConventionalCommit._();

  static const Set<String> _platformScopes = <String>{
    'ios',
    'android',
    'macos',
    'windows',
    'linux',
    'web',
  };

  static final RegExp _headerPattern = RegExp(
    r'^([a-z][a-z0-9-]*)(?:\(([^)]+)\))?(!)?:\s*(.+)$',
    caseSensitive: false,
  );
  static final RegExp _breakingFooterPattern = RegExp(
    '^(?:BREAKING CHANGE|BREAKING-CHANGE):',
    caseSensitive: false,
    multiLine: true,
  );

  /// Parses one Git [message] and associates it with [sha].
  static ConventionalChange parse(String sha, String message) {
    final lines = message.split('\n');
    final header = lines.isEmpty ? '' : lines.first;
    final match = _headerPattern.firstMatch(header);
    final type = match?.group(1) ?? 'other';
    final scope = match?.group(2);
    final breaking = match?.group(3) == '!' || _breakingFooterPattern.hasMatch(message);
    final bodyText = lines.skip(1).join('\n').trim();
    final body = bodyText.isEmpty ? null : bodyText;
    final platforms = List<Platform>.unmodifiable(_platformForScope(scope));
    return ConventionalChange(
      sha: sha,
      type: type,
      scope: scope,
      description: match?.group(4) ?? header,
      body: body,
      breaking: breaking,
      versionBump: _versionBumpFor(type, breaking),
      platforms: platforms,
    );
  }

  /// Returns the greatest semantic version impact in [changes].
  static VersionBump? highestVersionBump(
    Iterable<ConventionalChange> changes,
  ) {
    VersionBump? result;
    for (final change in changes) {
      final versionBump = change.versionBump;
      if (versionBump != null && (result == null || _versionBumpRank(versionBump) > _versionBumpRank(result))) {
        result = versionBump;
      }
    }
    return result;
  }

  static List<Platform> _platformForScope(String? scope) {
    if (scope == null) return Platform.values;
    final scopes = scope
        .toLowerCase()
        .split(RegExp(r'[,/\\|]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty);
    final explicit = scopes.where((value) => _platformScopes.contains(value)).toList();
    if (explicit.isEmpty) return Platform.values;
    return <Platform>[
      for (final platform in Platform.values)
        if (explicit.contains(platform.value)) platform,
    ];
  }

  static VersionBump? _versionBumpFor(String type, bool breaking) {
    if (breaking) return VersionBump.major;
    return switch (type.toLowerCase()) {
      'feat' => VersionBump.minor,
      'fix' || 'perf' || 'deps' => VersionBump.patch,
      _ => null,
    };
  }

  static int _versionBumpRank(VersionBump versionBump) => switch (versionBump) {
    VersionBump.patch => 1,
    VersionBump.minor => 2,
    VersionBump.major => 3,
  };
}
