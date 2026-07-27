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

Future<void> _commitAllChanges(String root, String message) async {
  await git(root, const <String>['add', '.']);
  final staged = await git(root, const <String>[
    'diff',
    '--cached',
    '--name-only',
  ]);
  if (staged.isEmpty) return;
  await git(root, <String>['commit', '-m', message]);
}

Future<String> _ensureReleaseBranch(
  String root,
  SmfConfig config,
  Platform platform,
  String token,
) async {
  final branch = releaseBranchName(platform);
  await authenticatedGit(root, <String>[
    'fetch',
    'origin',
    config.targetBranch,
  ], token);
  final remoteBranch = await authenticatedGit(root, <String>[
    'ls-remote',
    '--heads',
    'origin',
    'refs/heads/$branch',
  ], token);
  if (remoteBranch.isNotEmpty) {
    await authenticatedGit(root, <String>['fetch', 'origin', branch], token);
    await git(root, <String>['checkout', '-B', branch, 'origin/$branch']);
    try {
      await git(root, <String>[
        'merge',
        '--no-edit',
        'origin/${config.targetBranch}',
      ]);
    } on SmfError {
      await git(root, const <String>['merge', '--abort'], allowFailure: true);
      rethrow;
    }
  } else {
    await git(root, <String>[
      'checkout',
      '-B',
      branch,
      'origin/${config.targetBranch}',
    ]);
  }
  return branch;
}

Future<ReleasePullRequestResult> createOrUpdateReleasePullRequest(
  String workingDirectory,
  SmfConfig config,
  ReleasePlan plan,
  GitHubContext context, {
  GitHubApi? githubApi,
  ProcessRunner hookProcessRunner = const SystemProcessRunner(),
}) async {
  final paths = resolveSmfPaths(workingDirectory);
  final repositoryRoot = paths.repositoryRoot;
  if (!(await isClean(repositoryRoot))) {
    throw const SmfError(
      'The worktree must be clean before updating a release PR.',
      'DIRTY_WORKTREE',
    );
  }
  final api = githubApi ?? GitHubRestApi(context: context);
  final startingBranch = await currentBranch(repositoryRoot);
  await configureBotIdentity(repositoryRoot);
  late final String branch;
  try {
    branch = await _ensureReleaseBranch(
      repositoryRoot,
      config,
      plan.platform,
      context.token,
    );
    await applyReleasePlan(paths.directory, plan);
    await _commitAllChanges(
      repositoryRoot,
      'chore(${plan.platform.value}): release ${plan.nextVersion}',
    );
    final commitHookChanges = await runBeforeCreatePrHook(
      paths.directory,
      config,
      plan,
      processRunner: hookProcessRunner,
    );
    if (commitHookChanges ?? false) {
      await _commitAllChanges(
        repositoryRoot,
        'chore(${plan.platform.value}): apply before_create_pr hook for '
        '${plan.nextVersion}',
      );
    } else {
      invariant(
        await isClean(repositoryRoot),
        'The before_create_pr hook changed tracked or unignored files while '
            'commit is false. Commit or ignore those files in the hook.',
        'CREATE_PR_HOOK_DIRTY_WORKTREE',
      );
    }
    await authenticatedGit(repositoryRoot, <String>[
      'push',
      '--set-upstream',
      'origin',
      branch,
    ], context.token);

    final changelog = await loadChangelog(paths.directory);
    final release = changelog.releasesFor(plan.platform)[plan.nextVersion];
    if (release == null) {
      throw SmfError(
        'Missing changelog entry for ${plan.platform.value} '
            '${plan.nextVersion}',
        'MISSING_CHANGELOG',
      );
    }
    final existing = await api.listPullRequests(
      state: 'open',
      head: '${context.owner}:$branch',
      base: config.targetBranch,
      perPage: 1,
    );
    final title = 'chore(${plan.platform.value}): release ${plan.nextVersion}';
    final body = releasePullRequestBody(plan.platform, release);
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
    if (await isClean(repositoryRoot) &&
        startingBranch.isNotEmpty &&
        await currentBranch(repositoryRoot) != startingBranch) {
      await git(repositoryRoot, <String>['checkout', startingBranch]);
    }
  }
}

Future<int?> findReleasePullRequest(
  GitHubContext context,
  SmfConfig config,
  Platform platform, {
  GitHubApi? githubApi,
}) async {
  final pulls = await (githubApi ?? GitHubRestApi(context: context))
      .listPullRequests(
        state: 'all',
        head: '${context.owner}:${releaseBranchName(platform)}',
        base: config.targetBranch,
        perPage: 10,
      );
  return pulls.isEmpty ? null : pulls.first.number;
}
