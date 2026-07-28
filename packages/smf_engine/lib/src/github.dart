import 'package:smf_engine/src/changelog.dart';
import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/github/dtos/release_pull_request_result.dart';
import 'package:smf_engine/src/github_api.dart';
import 'package:smf_engine/src/hooks.dart';
import 'package:smf_engine/src/manifest_files.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/process_runner.dart';
import 'package:smf_engine/src/release_branch.dart';

export 'github/dtos/release_pull_request_result.dart';

/// Creates and finds the app-scoped release pull request.
final class ReleasePullRequest {
  const ReleasePullRequest._();

  static Future<void> _commitAllChanges({
    required GitClient gitClient,
    required String message,
  }) async {
    await gitClient.run(const <String>['add', '.']);
    final staged = await gitClient.run(const <String>[
      'diff',
      '--cached',
      '--name-only',
    ]);
    if (staged.isEmpty) return;
    await gitClient.run(<String>['commit', '-m', message]);
  }

  static Future<String> _ensureReleaseBranch({
    required GitClient gitClient,
    required SmfConfig config,
    required String token,
  }) async {
    final branch = ReleaseReference.branch(config.appId);
    await gitClient.authenticated(<String>[
      'fetch',
      'origin',
      'refs/heads/${config.targetBranch}:refs/remotes/origin/${config.targetBranch}',
    ], token);
    final remoteBranch = await gitClient.authenticated(<String>[
      'ls-remote',
      '--heads',
      'origin',
      'refs/heads/$branch',
    ], token);
    if (remoteBranch.isNotEmpty) {
      await gitClient.authenticated(<String>[
        'fetch',
        'origin',
        'refs/heads/$branch:refs/remotes/origin/$branch',
      ], token);
      await gitClient.run(<String>['checkout', '-B', branch, 'origin/$branch']);
      try {
        await gitClient.run(<String>[
          'merge',
          '--no-edit',
          'origin/${config.targetBranch}',
        ]);
      } on SmfError {
        await gitClient.run(
          const <String>['merge', '--abort'],
          allowFailure: true,
        );
        rethrow;
      }
    } else {
      await gitClient.run(<String>[
        'checkout',
        '-B',
        branch,
        'origin/${config.targetBranch}',
      ]);
    }
    return branch;
  }

  /// Creates or updates the release pull request for [plans].
  static Future<ReleasePullRequestResult> createOrUpdate({
    required String workingDirectory,
    required SmfConfig config,
    required List<ReleasePlan> plans,
    required GitHubContext context,
    GitHubApi? githubApi,
    ProcessRunner hookProcessRunner = const SystemProcessRunner(),
  }) async {
    SmfError.check(
      plans.isNotEmpty,
      'At least one platform release plan is required.',
      'RELEASE_PLANS_EMPTY',
    );
    final paths = SmfPaths.resolve(workingDirectory);
    final repositoryRoot = paths.repositoryRoot;
    final gitClient = GitClient(root: repositoryRoot);
    if (!(await gitClient.isClean())) {
      throw const SmfError(
        'The worktree must be clean before updating a release PR.',
        'DIRTY_WORKTREE',
      );
    }
    GitHubRestApi? ownedApi;
    final api = githubApi ?? (ownedApi = GitHubRestApi(context: context));
    final startingBranch = await gitClient.currentBranch();
    await gitClient.configureBotIdentity();
    late final String branch;
    try {
      branch = await _ensureReleaseBranch(
        gitClient: gitClient,
        config: config,
        token: context.token,
      );
      for (final plan in plans) {
        await ReleaseRegistry.apply(root: paths.directory, plan: plan);
      }
      final releaseSummary = plans.map((plan) => '${plan.platform.displayName} ${plan.nextVersion}').join(', ');
      await _commitAllChanges(
        gitClient: gitClient,
        message: 'chore(release): prepare $releaseSummary',
      );
      final hookRan = await RepositoryHooks.beforeCreatePullRequest(
        workingDirectory: paths.directory,
        plans: plans,
        processRunner: hookProcessRunner,
      );
      if (hookRan) {
        await _commitAllChanges(
          gitClient: gitClient,
          message: 'chore(release): apply before_create_pr hook',
        );
      }
      await gitClient.authenticated(<String>[
        'push',
        '--set-upstream',
        'origin',
        branch,
      ], context.token);

      final changelog = await SmfState.changelog(paths.directory);
      final releases = <Platform, ChangelogRelease>{};
      for (final plan in plans) {
        final release = changelog.releasesFor(plan.platform)[plan.nextVersion];
        if (release == null) {
          throw SmfError(
            'Missing changelog entry for ${plan.platform.value} '
                '${plan.nextVersion}',
            'MISSING_CHANGELOG',
          );
        }
        releases[plan.platform] = release;
      }
      final existing = await api.listPullRequests(
        state: 'open',
        head: '${context.owner}:$branch',
        base: config.targetBranch,
        perPage: 1,
      );
      final title = 'chore(${config.appId}): release $releaseSummary';
      final body = ReleaseChangelog.pullRequestBody(releases: releases);
      final pull = existing.isEmpty
          ? await api.createPullRequest(
              head: branch,
              base: config.targetBranch,
              title: title,
              body: body,
            )
          : existing.first;
      if (existing.isNotEmpty) {
        await api.updatePullRequest(
          number: pull.number,
          title: title,
          body: body,
        );
      }
      const label = 'autorelease: pending';
      if (!(await api.labelExists(label))) {
        await api.createLabel(name: label, color: 'fbca04');
      }
      await api.addLabels(
        issueNumber: pull.number,
        labels: const <String>[label],
      );
      return ReleasePullRequestResult(
        branch: branch,
        pullRequestNumber: pull.number,
      );
    } finally {
      try {
        if (await gitClient.isClean() &&
            startingBranch.isNotEmpty &&
            await gitClient.currentBranch() != startingBranch) {
          await gitClient.run(<String>['checkout', startingBranch]);
        }
      } finally {
        ownedApi?.close();
      }
    }
  }

  /// Finds the newest release pull request for [config], if one exists.
  static Future<int?> find({
    required GitHubContext context,
    required SmfConfig config,
    GitHubApi? githubApi,
  }) async {
    GitHubRestApi? ownedApi;
    final api = githubApi ?? (ownedApi = GitHubRestApi(context: context));
    try {
      final pulls = await api.listPullRequests(
        state: 'all',
        head: '${context.owner}:${ReleaseReference.branch(config.appId)}',
        base: config.targetBranch,
        perPage: 10,
      );
      return pulls.isEmpty ? null : pulls.first.number;
    } finally {
      ownedApi?.close();
    }
  }
}
