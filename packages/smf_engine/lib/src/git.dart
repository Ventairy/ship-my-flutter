import 'dart:convert';

import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git/git_commit.dart';
import 'package:smf_engine/src/process_runner.dart';
import 'package:smf_engine/src/system_process_runner.dart';

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
    bool isFailureAllowed = false,
    Map<String, String> environment = const <String, String>{},
  }) async => (await _run(
    arguments,
    isFailureAllowed: isFailureAllowed,
    environment: environment,
  )).trim();

  /// Runs Git while preserving output whitespace and record separators.
  Future<String> runRaw(List<String> arguments) => _run(arguments, isFailureAllowed: false);

  Future<String> _run(
    List<String> arguments, {
    required bool isFailureAllowed,
    Map<String, String> environment = const <String, String>{},
  }) async {
    final result = await processRunner.run(
      'git',
      arguments,
      options: RunOptions(
        workingDirectory: root,
        environment: environment,
        isFailureAllowed: isFailureAllowed,
      ),
    );
    return result.stdout;
  }

  /// Runs an authenticated GitHub command without placing [token] in arguments.
  Future<String> authenticated(
    List<String> arguments,
    String token, {
    bool isFailureAllowed = false,
  }) {
    final authorization = base64Encode(utf8.encode('x-access-token:$token'));
    return run(
      arguments,
      isFailureAllowed: isFailureAllowed,
      environment: <String, String>{
        'GIT_CONFIG_COUNT': '1',
        'GIT_CONFIG_KEY_0': 'http.https://github.com/.extraheader',
        'GIT_CONFIG_VALUE_0': 'AUTHORIZATION: basic $authorization',
      },
    );
  }

  /// Returns the current `HEAD` commit hash.
  Future<String> currentCommitHash() => run(const <String>['rev-parse', 'HEAD']);

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
    ], options: RunOptions(workingDirectory: root, isFailureAllowed: true));
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
        SmfErrorCode.remoteDefaultBranch,
      );
    }
    return branch;
  }

  /// Returns the commit hash referenced by [tag] on [remote], if it exists.
  ///
  /// Both lightweight and annotated tags are supported. A direct remote query
  /// prevents missing or stale local tags from influencing release decisions.
  Future<String?> remoteTagCommitHash(
    String tag,
    String token, {
    String remote = 'origin',
  }) async {
    final output = await authenticated(
      <String>[
        'ls-remote',
        '--tags',
        remote,
        'refs/tags/$tag',
        'refs/tags/$tag^{}',
      ],
      token,
    );
    if (output.isEmpty) return null;

    String? directCommitHash;
    String? peeledCommitHash;
    for (final line in output.split('\n').where((line) => line.isNotEmpty)) {
      final fields = line.split('\t');
      SmfError.check(
        fields.length == 2 && RegExp(r'^[0-9a-fA-F]{40,64}$').hasMatch(fields.first),
        'Could not parse remote tag $tag.',
        SmfErrorCode.gitParse,
      );
      if (fields.last == 'refs/tags/$tag') {
        directCommitHash = fields.first.toLowerCase();
      } else if (fields.last == 'refs/tags/$tag^{}') {
        peeledCommitHash = fields.first.toLowerCase();
      } else {
        throw SmfError(
          'Git returned an unexpected reference for remote tag $tag.',
          SmfErrorCode.gitParse,
        );
      }
    }
    return peeledCommitHash ?? directCommitHash;
  }

  /// Whether [tag] currently exists on [remote].
  ///
  /// A direct remote query prevents a stale local tag from influencing an
  /// irreversible ship decision.
  Future<bool> remoteTagExists(
    String tag,
    String token, {
    String remote = 'origin',
  }) async => await remoteTagCommitHash(tag, token, remote: remote) != null;

  /// Verifies that an existing remote [tag] targets [expectedCommitHash].
  ///
  /// A missing tag is valid because the release operation may create it. A
  /// conflicting tag is rejected before any irreversible store mutation.
  Future<void> verifyRemoteTagCommitIfPresent({
    required String tag,
    required String expectedCommitHash,
    required String token,
    String remote = 'origin',
  }) async {
    final actualCommitHash = await remoteTagCommitHash(
      tag,
      token,
      remote: remote,
    );
    if (actualCommitHash == null) return;
    SmfError.check(
      actualCommitHash == expectedCommitHash.toLowerCase(),
      'Remote tag $tag points to $actualCommitHash instead of the verified '
      'release commit $expectedCommitHash.',
      SmfErrorCode.remoteTagMismatch,
    );
  }

  /// Reads commits after [baseCommitHash] through [endCommitHash], optionally path-filtered.
  Future<List<GitCommit>> commitsBetween(
    String baseCommitHash, {
    String endCommitHash = 'HEAD',
    List<String> paths = const <String>[],
  }) async {
    const format = '%H$_fieldSeparator%B$_recordSeparator';
    final output = await run(<String>[
      'log',
      '--reverse',
      '--format=$format',
      '$baseCommitHash..$endCommitHash',
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
    SmfError.check(separatorIndex > 0, 'Could not parse git history', SmfErrorCode.gitParse);
    return GitCommit(
      commitHash: record.substring(0, separatorIndex),
      message: record.substring(separatorIndex + 1).trim(),
    );
  }
}
