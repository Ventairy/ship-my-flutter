import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/models/github_context.dart';
import 'package:smf_engine/src/models/release_enums.dart';

/// Git operations that persist deterministic candidate state.
final class CandidateGit {
  const CandidateGit._();

  /// Commits and pushes one platform candidate receipt.
  static Future<void> commitReceipt({
    required String repositoryRoot,
    required String receiptPath,
    required Platform platform,
    required String version,
    required GitHubContext? github,
  }) async {
    final gitClient = GitClient(root: repositoryRoot);
    await gitClient.configureBotIdentity();
    await gitClient.run(<String>['add', receiptPath]);
    final staged = await gitClient.run(const <String>[
      'diff',
      '--cached',
      '--name-only',
    ]);
    if (staged.isEmpty) return;
    await gitClient.run(<String>[
      'commit',
      '-m',
      'chore(${platform.value}): record store candidate $version',
    ]);
    await _pushCurrentBranch(gitClient, github);
  }

  /// Commits and pushes deterministic changes made by a before-build hook.
  static Future<void> commitBeforeBuildChanges({
    required String repositoryRoot,
    required Platform platform,
    required String version,
    required String startingSha,
    required GitHubContext? github,
  }) async {
    final gitClient = GitClient(root: repositoryRoot);
    await gitClient.configureBotIdentity();
    await gitClient.run(const <String>['add', '.']);
    final staged = await gitClient.run(const <String>[
      'diff',
      '--cached',
      '--name-only',
    ]);
    if (staged.isNotEmpty) {
      await gitClient.run(<String>[
        'commit',
        '-m',
        'chore(${platform.value}): apply before_build hook for $version',
      ]);
    }
    if (await gitClient.currentSha() == startingSha) return;
    await _pushCurrentBranch(gitClient, github);
  }

  static Future<void> _pushCurrentBranch(
    GitClient gitClient,
    GitHubContext? github,
  ) async {
    final branch = await gitClient.currentBranch();
    SmfError.check(
      branch.isNotEmpty,
      'Candidate checkout must be on a branch.',
      'DETACHED_HEAD',
    );
    if (github == null) {
      await gitClient.run(<String>['push', 'origin', branch]);
      return;
    }
    await gitClient.authenticated(<String>['push', 'origin', branch], github.token);
  }
}
