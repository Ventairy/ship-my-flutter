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

  /// Parses one Git [message] and associates it with [commitHash].
  static ConventionalChangeDto parse(String commitHash, String message) {
    final lines = message.split('\n');
    final header = lines.isEmpty ? '' : lines.first;
    final match = _headerPattern.firstMatch(header);
    final type = match?.group(1) ?? 'other';
    final scope = match?.group(2);
    final isBreaking = match?.group(3) == '!' || _breakingFooterPattern.hasMatch(message);
    final bodyText = lines.skip(1).join('\n').trim();
    final body = bodyText.isEmpty ? null : bodyText;
    final platforms = List<ReleasePlatform>.unmodifiable(_platformForScope(scope));
    return ConventionalChangeDto(
      commitHash: commitHash,
      type: type,
      scope: scope,
      description: match?.group(4) ?? header,
      body: body,
      isBreaking: isBreaking,
      versionBumpType: _versionBumpTypeFor(type, isBreaking),
      platforms: platforms,
    );
  }

  /// Returns the greatest semantic version impact in [changes].
  static VersionBumpType? highestVersionBumpType(
    Iterable<ConventionalChangeDto> changes,
  ) {
    VersionBumpType? result;
    for (final change in changes) {
      final versionBumpType = change.versionBumpType;
      if (versionBumpType != null &&
          (result == null || _versionBumpTypeRank(versionBumpType) > _versionBumpTypeRank(result))) {
        result = versionBumpType;
      }
    }
    return result;
  }

  static List<ReleasePlatform> _platformForScope(String? scope) {
    if (scope == null) return ReleasePlatform.values;
    final scopes = scope
        .toLowerCase()
        .split(RegExp(r'[,/\\|]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty);
    final explicit = scopes.where((value) => _platformScopes.contains(value)).toList();
    if (explicit.isEmpty) return ReleasePlatform.values;
    return <ReleasePlatform>[
      for (final platform in ReleasePlatform.values)
        if (explicit.contains(platform.value)) platform,
    ];
  }

  static VersionBumpType? _versionBumpTypeFor(String type, bool isBreaking) {
    if (isBreaking) return VersionBumpType.major;
    return switch (type.toLowerCase()) {
      'feat' => VersionBumpType.minor,
      'fix' || 'perf' || 'deps' => VersionBumpType.patch,
      _ => null,
    };
  }

  static int _versionBumpTypeRank(VersionBumpType versionBumpType) => switch (versionBumpType) {
    VersionBumpType.patch => 1,
    VersionBumpType.minor => 2,
    VersionBumpType.major => 3,
  };
}
