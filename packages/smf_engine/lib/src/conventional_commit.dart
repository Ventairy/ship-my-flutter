import 'package:pub_semver/pub_semver.dart';

import 'package:smf_engine/src/model.dart';

const Set<String> _platformScopes = <String>{
  'ios',
  'android',
  'macos',
  'windows',
  'linux',
  'web',
};

final RegExp _headerPattern = RegExp(
  r'^([a-z][a-z0-9-]*)(?:\(([^)]+)\))?(!)?:\s*(.+)$',
  caseSensitive: false,
);
final RegExp _breakingFooterPattern = RegExp(
  '^(?:BREAKING CHANGE|BREAKING-CHANGE):',
  caseSensitive: false,
  multiLine: true,
);

ConventionalChange parseConventionalCommit(String sha, String message) {
  final lines = message.split('\n');
  final header = lines.isEmpty ? '' : lines.first;
  final match = _headerPattern.firstMatch(header);
  final type = match?.group(1) ?? 'other';
  final scope = match?.group(2);
  final breaking =
      match?.group(3) == '!' || _breakingFooterPattern.hasMatch(message);
  final bodyText = lines.skip(1).join('\n').trim();
  final body = bodyText.isEmpty ? null : bodyText;
  final platforms = List<Platform>.unmodifiable(_platformForScope(scope));
  final releaseAs = platforms.length == 1
      ? _footerVersion(message, platforms.single)
      : _globalFooterVersion(message);
  return ConventionalChange(
    sha: sha,
    type: type,
    scope: scope,
    description: match?.group(4) ?? header,
    body: body,
    breaking: breaking,
    bump: _bumpFor(type, breaking),
    platforms: platforms,
    releaseAs: releaseAs,
  );
}

/// Parses [message] while resolving a platform-specific `Release-As` footer.
ConventionalChange parseConventionalCommitForPlatform(
  String sha,
  String message,
  Platform platform,
) {
  final change = parseConventionalCommit(sha, message);
  return change.copyWith(releaseAs: _footerVersion(message, platform));
}

List<Platform> _platformForScope(String? scope) {
  if (scope == null) return Platform.values;
  final scopes = scope
      .toLowerCase()
      .split(RegExp(r'[,/\\|]'))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty);
  final explicit = scopes
      .where((value) => _platformScopes.contains(value))
      .toList();
  if (explicit.isEmpty) return Platform.values;
  return <Platform>[
    for (final platform in Platform.values)
      if (explicit.contains(platform.value)) platform,
  ];
}

Bump? _bumpFor(String type, bool breaking) {
  if (breaking) return Bump.major;
  return switch (type.toLowerCase()) {
    'feat' => Bump.minor,
    'fix' || 'perf' || 'deps' => Bump.patch,
    _ => null,
  };
}

String? _footerVersion(String message, Platform platform) {
  final platformMatch = RegExp(
    '^Release-As-${platform.value}:\\s*(\\S+)\\s*\$',
    caseSensitive: false,
    multiLine: true,
  ).firstMatch(message);
  final value = platformMatch?.group(1) ?? _globalFooterVersion(message);
  if (value == null) return null;
  try {
    final version = Version.parse(value);
    return version.isPreRelease || version.build.isNotEmpty
        ? null
        : version.toString();
  } on FormatException {
    return null;
  }
}

String? _globalFooterVersion(String message) {
  final globalMatch = RegExp(
    r'^Release-As:\s*(\S+)\s*$',
    caseSensitive: false,
    multiLine: true,
  ).firstMatch(message);
  final value = globalMatch?.group(1);
  if (value == null) return null;
  try {
    final version = Version.parse(value);
    return version.isPreRelease || version.build.isNotEmpty
        ? null
        : version.toString();
  } on FormatException {
    return null;
  }
}

Bump? highestBump(Iterable<ConventionalChange> changes) {
  Bump? result;
  for (final change in changes) {
    final bump = change.bump;
    if (bump != null &&
        (result == null || _bumpRank(bump) > _bumpRank(result))) {
      result = bump;
    }
  }
  return result;
}

int _bumpRank(Bump bump) => switch (bump) {
  Bump.patch => 1,
  Bump.minor => 2,
  Bump.major => 3,
};
