import 'changelog.dart';
import 'config.dart';
import 'error.dart';
import 'git.dart';
import 'github/dtos/release_pull_request_result.dart';
import 'github_api.dart';
import 'hooks.dart';
import 'manifest_files.dart';
import 'model.dart';

export 'github/dtos/release_pull_request_result.dart';

String releaseBranchName(ShipConfig config, Platform platform) =>
    '${config.releaseBranchPrefix}/${platform.value}';

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
  ShipConfig config,
  Platform platform,
  String token,
) async {
  final branch = releaseBranchName(config, platform);
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
    } on ShipError {
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
  String root,
  ShipConfig config,
  ReleasePlan plan,
  GitHubContext context, {
  GitHubApi? githubApi,
}) async {
  if (!(await isClean(root))) {
    throw const ShipError(
      'The worktree must be clean before updating a release PR.',
      'DIRTY_WORKTREE',
    );
  }
  final api = githubApi ?? GitHubRestApi(context: context);
  final startingBranch = await currentBranch(root);
  await configureBotIdentity(root);
  late final String branch;
  try {
    branch = await _ensureReleaseBranch(
      root,
      config,
      plan.platform,
      context.token,
    );
    await applyReleasePlan(root, plan);
    await _commitAllChanges(
      root,
      'chore(${plan.platform.value}): release ${plan.nextVersion}',
    );
    await runBeforeCreatePrHook(root, config, plan);
    final beforeCreatePr = config.hooks.beforeCreatePr;
    if (beforeCreatePr != null && beforeCreatePr.commit) {
      await _commitAllChanges(
        root,
        'chore(${plan.platform.value}): apply before_create_pr hook for '
        '${plan.nextVersion}',
      );
    } else {
      invariant(
        await isClean(root),
        'The before_create_pr hook changed tracked or unignored files while '
            'commit is false. Commit or ignore those files in the hook.',
        'CREATE_PR_HOOK_DIRTY_WORKTREE',
      );
    }
    await authenticatedGit(root, <String>[
      'push',
      '--set-upstream',
      'origin',
      branch,
    ], context.token);

    final changelog = await loadChangelog(root);
    final release = changelog.releasesFor(plan.platform)[plan.nextVersion];
    if (release == null) {
      throw ShipError(
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
    if (await isClean(root) &&
        startingBranch.isNotEmpty &&
        await currentBranch(root) != startingBranch) {
      await git(root, <String>['checkout', startingBranch]);
    }
  }
}

Future<int?> findReleasePullRequest(
  GitHubContext context,
  ShipConfig config,
  Platform platform, {
  GitHubApi? githubApi,
}) async {
  final pulls = await (githubApi ?? GitHubRestApi(context: context))
      .listPullRequests(
        state: 'all',
        head: '${context.owner}:${releaseBranchName(config, platform)}',
        base: config.targetBranch,
        perPage: 10,
      );
  return pulls.isEmpty ? null : pulls.first.number;
}
