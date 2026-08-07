import 'package:smf_engine/src/enums/release_platform.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/models/github_context.dart';

/// Git operations that persist deterministic release candidate state.
final class ReleaseCandidateGit {
  const ReleaseCandidateGit._();

  /// Commits and pushes one platform release candidate receipt.
  static Future<void> commitReceipt({
    required String repositoryRoot,
    required String receiptPath,
    required ReleasePlatform platform,
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
    if (staged.isNotEmpty) {
      await gitClient.run(<String>[
        'commit',
        '-m',
        'chore(${platform.value}): record store release candidate $version',
      ]);
    }
    await _pushCurrentBranch(gitClient, github);
  }

  /// Commits and pushes a durable intent before a store upload begins.
  static Future<void> commitIntent({
    required String repositoryRoot,
    required String intentPath,
    required ReleasePlatform platform,
    required String version,
    required GitHubContext? github,
  }) async {
    final gitClient = GitClient(root: repositoryRoot);
    await gitClient.configureBotIdentity();
    await gitClient.run(<String>['add', intentPath]);
    final staged = await gitClient.run(const <String>[
      'diff',
      '--cached',
      '--name-only',
    ]);
    if (staged.isNotEmpty) {
      await gitClient.run(<String>[
        'commit',
        '-m',
        'chore(${platform.value}): prepare store release candidate $version',
      ]);
    }
    await _pushCurrentBranch(gitClient, github);
  }

  /// Atomically replaces a remote intent with its final release candidate receipt.
  static Future<void> finalizeReceipt({
    required String repositoryRoot,
    required String intentPath,
    required String receiptPath,
    required ReleasePlatform platform,
    required String version,
    required GitHubContext? github,
  }) async {
    final gitClient = GitClient(root: repositoryRoot);
    await gitClient.configureBotIdentity();
    await gitClient.run(<String>['add', receiptPath]);
    await gitClient.run(<String>[
      'rm',
      '--cached',
      '--ignore-unmatch',
      '--',
      intentPath,
    ]);
    final staged = await gitClient.run(const <String>[
      'diff',
      '--cached',
      '--name-only',
    ]);
    if (staged.isNotEmpty) {
      await gitClient.run(<String>[
        'commit',
        '-m',
        'chore(${platform.value}): record store release candidate $version',
      ]);
    }
    await _pushCurrentBranch(gitClient, github);
  }

  /// Commits and pushes deterministic changes made by a before-build hook.
  static Future<void> commitBeforeBuildChanges({
    required String repositoryRoot,
    required ReleasePlatform platform,
    required String version,
    required String startingCommitHash,
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
    if (await gitClient.currentCommitHash() == startingCommitHash) return;
    await _pushCurrentBranch(gitClient, github);
  }

  static Future<void> _pushCurrentBranch(
    GitClient gitClient,
    GitHubContext? github,
  ) async {
    final branch = await gitClient.currentBranch();
    SmfError.check(
      branch.isNotEmpty,
      'Release candidate checkout must be on a branch.',
      SmfErrorCode.detachedHead,
    );
    if (github == null) {
      await gitClient.run(<String>['push', 'origin', branch]);
      return;
    }
    await gitClient.authenticated(<String>['push', 'origin', branch], github.token);
  }
}
