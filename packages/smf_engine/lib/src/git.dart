import 'dart:convert';

import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git/git_commit.dart';
import 'package:smf_engine/src/process_runner.dart';

export 'git/git_commit.dart';

/// Runs repository-scoped Git commands through an injectable process boundary.
final class GitClient {
  /// Creates a Git client rooted at [root].
  const GitClient({
    required this.root,
    this.processRunner = const SystemProcessRunner(),
  });

  /// Repository working directory used for every command.
  final String root;

  /// Process boundary used to invoke Git.
  final ProcessRunner processRunner;

  static const String _recordSeparator = '\u001e';
  static const String _fieldSeparator = '\u001f';

  /// Runs Git with trimmed output.
  Future<String> run(
    List<String> arguments, {
    bool allowFailure = false,
    Map<String, String> environment = const <String, String>{},
  }) async => (await _run(
    arguments,
    allowFailure: allowFailure,
    environment: environment,
  )).trim();

  /// Runs Git while preserving output whitespace and record separators.
  Future<String> runRaw(List<String> arguments) => _run(arguments, allowFailure: false);

  Future<String> _run(
    List<String> arguments, {
    required bool allowFailure,
    Map<String, String> environment = const <String, String>{},
  }) async {
    final result = await processRunner.run(
      'git',
      arguments,
      options: RunOptions(
        workingDirectory: root,
        environment: environment,
        allowFailure: allowFailure,
      ),
    );
    return result.stdout;
  }

  /// Runs an authenticated GitHub command without placing [token] in arguments.
  Future<String> authenticated(
    List<String> arguments,
    String token, {
    bool allowFailure = false,
  }) {
    final authorization = base64Encode(utf8.encode('x-access-token:$token'));
    return run(
      arguments,
      allowFailure: allowFailure,
      environment: <String, String>{
        'GIT_CONFIG_COUNT': '1',
        'GIT_CONFIG_KEY_0': 'http.https://github.com/.extraheader',
        'GIT_CONFIG_VALUE_0': 'AUTHORIZATION: basic $authorization',
      },
    );
  }

  /// Returns the current `HEAD` commit SHA.
  Future<String> currentSha() => run(const <String>['rev-parse', 'HEAD']);

  /// Returns the current branch, or an empty string for a detached checkout.
  Future<String> currentBranch() => run(const <String>['branch', '--show-current']);

  /// Whether the repository has no staged, unstaged, or untracked changes.
  Future<bool> isClean() async => (await run(const <String>['status', '--porcelain'])).isEmpty;

  /// Whether a local Git tag named [tag] exists.
  Future<bool> tagExists(String tag) async {
    final result = await processRunner.run('git', <String>[
      'rev-parse',
      '--verify',
      '--quiet',
      'refs/tags/$tag',
    ], options: RunOptions(workingDirectory: root, allowFailure: true));
    return result.exitCode == 0;
  }

  /// Returns the default branch advertised by [remote].
  ///
  /// This queries the remote directly instead of relying on a possibly stale
  /// local `origin/HEAD` symbolic reference.
  Future<String> remoteDefaultBranch(
    String token, {
    String remote = 'origin',
  }) async {
    final output = await authenticated(
      <String>['ls-remote', '--symref', remote, 'HEAD'],
      token,
    );
    final match = RegExp(
      r'^ref: refs/heads/(.+)\s+HEAD$',
      multiLine: true,
    ).firstMatch(output);
    final branch = match?.group(1)?.trim();
    if (branch == null || branch.isEmpty) {
      throw SmfError(
        'Could not determine the default branch advertised by $remote.',
        'REMOTE_DEFAULT_BRANCH',
      );
    }
    return branch;
  }

  /// Whether [tag] currently exists on [remote].
  ///
  /// A direct remote query prevents a stale local tag from influencing an
  /// irreversible ship decision.
  Future<bool> remoteTagExists(
    String tag,
    String token, {
    String remote = 'origin',
  }) async {
    final output = await authenticated(
      <String>[
        'ls-remote',
        '--tags',
        '--refs',
        remote,
        'refs/tags/$tag',
      ],
      token,
    );
    return output.isNotEmpty;
  }

  /// Returns the commit SHA referenced by a local [tag].
  Future<String> tagSha(String tag) => run(<String>['rev-list', '-n', '1', tag]);

  /// Reads commits after [baseSha] through [headSha], optionally path-filtered.
  Future<List<GitCommit>> commitsBetween(
    String baseSha, {
    String headSha = 'HEAD',
    List<String> paths = const <String>[],
  }) async {
    const format = '%H$_fieldSeparator%B$_recordSeparator';
    final output = await run(<String>[
      'log',
      '--reverse',
      '--format=$format',
      '$baseSha..$headSha',
      if (paths.isNotEmpty) '--',
      ...paths,
    ]);
    if (output.isEmpty) return const <GitCommit>[];

    return <GitCommit>[
      for (final record
          in output.split(_recordSeparator).map((value) => value.trim()).where((value) => value.isNotEmpty))
        _parseCommit(record),
    ];
  }

  /// Configures the repository-local SMF bot commit identity.
  Future<void> configureBotIdentity() async {
    await run(const <String>['config', 'user.name', 'smf[bot]']);
    await run(const <String>[
      'config',
      'user.email',
      'smf[bot]@users.noreply.github.com',
    ]);
  }

  static GitCommit _parseCommit(String record) {
    final separatorIndex = record.indexOf(_fieldSeparator);
    SmfError.check(separatorIndex > 0, 'Could not parse git history', 'GIT_PARSE');
    return GitCommit(
      sha: record.substring(0, separatorIndex),
      message: record.substring(separatorIndex + 1).trim(),
    );
  }
}
