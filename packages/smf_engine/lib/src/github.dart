import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/github/dtos/release_pull_request_result_dto.dart';
import 'package:smf_engine/src/github_api.dart';
import 'package:smf_engine/src/github_rest_api.dart';
import 'package:smf_engine/src/hooks.dart';
import 'package:smf_engine/src/manifest_files.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/process_runner.dart';
import 'package:smf_engine/src/release_branch.dart';
import 'package:smf_engine/src/release_changelog.dart';
import 'package:smf_engine/src/system_process_runner.dart';

export 'github/dtos/release_pull_request_result_dto.dart';

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
      await gitClient.run(<String>['checkout', '--detach', 'origin/$branch']);
      try {
        await gitClient.run(<String>[
          'merge',
          '--no-edit',
          'origin/${config.targetBranch}',
        ]);
      } on SmfError {
        await gitClient.run(
          const <String>['merge', '--abort'],
          isFailureAllowed: true,
        );
        rethrow;
      }
    } else {
      await gitClient.run(<String>[
        'checkout',
        '--detach',
        'origin/${config.targetBranch}',
      ]);
    }
    return branch;
  }

  /// Creates or updates the release pull request for [plans].
  static Future<ReleasePullRequestResultDto> createOrUpdate({
    required String workingDirectory,
    required SmfConfig config,
    required List<ReleasePlanDto> plans,
    required GitHubContext context,
    GitHubApi? githubApi,
    ProcessRunner hookProcessRunner = const SystemProcessRunner(),
  }) async {
    SmfError.check(
      plans.isNotEmpty,
      'At least one platform release plan is required.',
      SmfErrorCode.releasePlansEmpty,
    );
    final callerPaths = SmfPaths.resolve(workingDirectory);
    final callerGitClient = GitClient(root: callerPaths.repositoryRoot);
    if (!(await callerGitClient.isClean())) {
      throw const SmfError(
        'The worktree must be clean before updating a release PR.',
        SmfErrorCode.dirtyWorktree,
      );
    }
    GitHubRestApi? ownedApi;
    final api = githubApi ?? (ownedApi = GitHubRestApi(context: context));
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'smf-pull-request-',
    );
    final checkoutRoot = p.join(temporaryDirectory.path, 'repository');
    var isWorktreeCreated = false;
    var didOperationFail = true;
    late final String branch;
    try {
      await callerGitClient.run(<String>[
        'worktree',
        'add',
        '--detach',
        checkoutRoot,
        'HEAD',
      ]);
      isWorktreeCreated = true;
      final gitClient = GitClient(root: checkoutRoot);
      await gitClient.configureBotIdentity();
      final paths = SmfPaths.resolve(
        p.join(
          checkoutRoot,
          p.relative(
            callerPaths.directory,
            from: callerPaths.repositoryRoot,
          ),
        ),
      );
      branch = await _ensureReleaseBranch(
        gitClient: gitClient,
        config: config,
        token: context.token,
      );
      for (final plan in plans) {
        await ReleaseRegistry.apply(
          root: paths.directory,
          plan: plan,
          gitHubToken: context.token,
        );
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
        'origin',
        'HEAD:refs/heads/$branch',
      ], context.token);

      final changelog = await SmfState.changelog(paths.directory);
      final releases = <ReleasePlatform, ChangelogPlatformReleaseVersionDto>{};
      for (final plan in plans) {
        final release = changelog.platforms.select(plan.platform).releaseVersion(plan.nextVersion);
        if (release == null) {
          throw SmfError(
            'Missing changelog entry for ${plan.platform.value} '
            '${plan.nextVersion}',
            SmfErrorCode.missingChangelog,
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
      final result = ReleasePullRequestResultDto(
        branch: branch,
        pullRequestNumber: pull.number,
      );
      didOperationFail = false;
      return result;
    } finally {
      try {
        if (isWorktreeCreated) {
          await callerGitClient.run(
            <String>['worktree', 'remove', '--force', checkoutRoot],
            isFailureAllowed: didOperationFail,
          );
        }
        if (await temporaryDirectory.exists()) {
          try {
            await temporaryDirectory.delete(recursive: true);
          } on FileSystemException {
            if (!didOperationFail) rethrow;
          }
        }
      } finally {
        if (isWorktreeCreated) {
          await callerGitClient.run(
            const <String>['worktree', 'prune'],
            isFailureAllowed: true,
          );
        }
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
