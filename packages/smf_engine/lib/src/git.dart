import 'dart:convert';

import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git/git_commit.dart';
import 'package:smf_engine/src/process_runner.dart';

export 'git/git_commit.dart';

final class GitClient {
  const GitClient({
    required this.root,
    this.processRunner = const SystemProcessRunner(),
  });

  final String root;
  final ProcessRunner processRunner;

  static const String _recordSeparator = '\u001e';
  static const String _fieldSeparator = '\u001f';

  Future<String> run(
    List<String> arguments, {
    bool allowFailure = false,
    Map<String, String> environment = const <String, String>{},
  }) async => (await _run(
    arguments,
    allowFailure: allowFailure,
    environment: environment,
  )).trim();

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

  Future<String> currentSha() => run(const <String>['rev-parse', 'HEAD']);

  Future<String> currentBranch() => run(const <String>['branch', '--show-current']);

  Future<bool> isClean() async => (await run(const <String>['status', '--porcelain'])).isEmpty;

  Future<bool> tagExists(String tag) async {
    final result = await processRunner.run('git', <String>[
      'rev-parse',
      '--verify',
      '--quiet',
      'refs/tags/$tag',
    ], options: RunOptions(workingDirectory: root, allowFailure: true));
    return result.exitCode == 0;
  }

  Future<String> tagSha(String tag) => run(<String>['rev-list', '-n', '1', tag]);

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
