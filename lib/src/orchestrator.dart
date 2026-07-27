import 'config.dart';
import 'git.dart';
import 'github.dart';
import 'github_api.dart';
import 'model.dart';
import 'release_branch.dart';
import 'release_plan.dart';
import 'validate.dart';

final class ReleaseOrchestrator {
  const ReleaseOrchestrator({this.githubApi});

  final GitHubApi? githubApi;

  Future<CommandResult> plan({
    required String root,
    required GitHubContext github,
  }) async {
    final (config, manifest) = await (
      loadConfig(root),
      loadManifest(root),
    ).wait;
    if (!config.ios.enabled) return const CommandResult(phase: 'noop');
    final branch = await currentBranch(root);
    final releaseBranch = releaseBranchName(Platform.ios);
    if (branch != releaseBranch && branch != config.targetBranch) {
      return const CommandResult(phase: 'noop');
    }
    await validateRepository(root);
    if (branch == releaseBranch) {
      final state = manifest.ios;
      return state.pendingRelease &&
              await releaseNeedsPromotion(root, manifest, Platform.ios)
          ? CommandResult(
              phase: 'candidate',
              platform: Platform.ios,
              version: state.version,
              branch: releaseBranch,
            )
          : const CommandResult(phase: 'noop');
    }
    if (await releaseNeedsPromotion(root, manifest, Platform.ios)) {
      return CommandResult(
        phase: 'promote',
        platform: Platform.ios,
        version: manifest.ios.version,
      );
    }
    final plan = await createReleasePlan(root, manifest, Platform.ios);
    if (plan == null) return const CommandResult(phase: 'noop');
    final pull = await createOrUpdateReleasePullRequest(
      root,
      config,
      plan,
      github,
      githubApi: githubApi,
    );
    return CommandResult(
      phase: 'candidate',
      platform: Platform.ios,
      version: plan.nextVersion,
      branch: pull.branch,
      pullRequestNumber: pull.pullRequestNumber,
    );
  }
}

Future<CommandResult> planGitHubRelease({
  required String root,
  required GitHubContext github,
  GitHubApi? githubApi,
}) =>
    ReleaseOrchestrator(githubApi: githubApi).plan(root: root, github: github);
