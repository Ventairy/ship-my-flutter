import 'changelog.dart';
import 'config.dart';
import 'error.dart';
import 'git.dart';
import 'github_api.dart';
import 'hooks.dart';
import 'manifest_files.dart';
import 'model.dart';

String releaseBranchName(ShipConfig config, Platform platform) =>
    '${config.releaseBranchPrefix}/${platform.value}';

Future<String> _ensureReleaseBranch(
  String root,
  ShipConfig config,
  Platform platform,
  String token,
) async {
  final branch = releaseBranchName(config, platform);
  await authenticatedGit(
    root,
    <String>['fetch', 'origin', config.targetBranch, branch],
    token,
    allowFailure: true,
  );
  final remoteBranch = await git(root, <String>[
    'rev-parse',
    '--verify',
    '--quiet',
    'origin/$branch',
  ], allowFailure: true);
  if (remoteBranch.isNotEmpty) {
    await git(root, <String>['checkout', '-B', branch, 'origin/$branch']);
    await git(root, <String>[
      'merge',
      '--no-edit',
      'origin/${config.targetBranch}',
    ]);
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

final class ReleasePullRequestResult {
  const ReleasePullRequestResult({
    required this.branch,
    required this.pullRequestNumber,
  });

  final String branch;
  final int pullRequestNumber;
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
  final branch = await _ensureReleaseBranch(
    root,
    config,
    plan.platform,
    context.token,
  );
  try {
    await applyReleasePlan(root, plan);
    await runBeforeReleasePrHook(root, config, plan);
    await git(root, const <String>['add', '.']);
    final staged = await git(root, const <String>[
      'diff',
      '--cached',
      '--name-only',
    ]);
    if (staged.isNotEmpty) {
      await git(root, <String>[
        'commit',
        '-m',
        'chore(${plan.platform.value}): release ${plan.nextVersion}',
      ]);
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
    if (startingBranch.isNotEmpty && startingBranch != branch) {
      await git(root, <String>['checkout', startingBranch], allowFailure: true);
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
