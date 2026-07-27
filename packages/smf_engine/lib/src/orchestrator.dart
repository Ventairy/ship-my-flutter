import 'config.dart';
import 'git.dart';
import 'github.dart';
import 'github_api.dart';
import 'model.dart';
import 'paths.dart';
import 'release_branch.dart';
import 'release_plan.dart';
import 'validate.dart';

final class ReleaseOrchestrator {
  const ReleaseOrchestrator({this.githubApi});

  final GitHubApi? githubApi;

  Future<CommandResult> plan({
    required String workingDirectory,
    String? smfPath,
    required GitHubContext github,
  }) async {
    final paths = resolveSmfPaths(workingDirectory, smfPath: smfPath);
    final repositoryRoot = paths.repositoryRoot;
    final (config, manifest) = await (
      loadConfig(paths.directory),
      loadManifest(paths.directory),
    ).wait;
    if (!config.ios.enabled) return const CommandResult(phase: 'noop');
    final branch = await currentBranch(repositoryRoot);
    final releaseBranch = releaseBranchName(Platform.ios);
    if (branch != releaseBranch && branch != config.targetBranch) {
      return const CommandResult(phase: 'noop');
    }
    await validateRepository(paths.directory);
    if (branch == releaseBranch) {
      final state = manifest.ios;
      return state.pendingRelease &&
              await releaseNeedsPromotion(
                repositoryRoot,
                manifest,
                Platform.ios,
              )
          ? CommandResult(
              phase: 'release-candidate',
              platform: Platform.ios,
              version: state.version,
              branch: releaseBranch,
            )
          : const CommandResult(phase: 'noop');
    }
    if (await releaseNeedsPromotion(repositoryRoot, manifest, Platform.ios)) {
      return CommandResult(
        phase: 'ship',
        platform: Platform.ios,
        version: manifest.ios.version,
      );
    }
    final plan = await createReleasePlan(
      repositoryRoot,
      manifest,
      Platform.ios,
    );
    if (plan == null) return const CommandResult(phase: 'noop');
    final pull = await createOrUpdateReleasePullRequest(
      paths.directory,
      config,
      plan,
      github,
      githubApi: githubApi,
    );
    return CommandResult(
      phase: 'release-candidate',
      platform: Platform.ios,
      version: plan.nextVersion,
      branch: pull.branch,
      pullRequestNumber: pull.pullRequestNumber,
    );
  }
}

Future<CommandResult> planGitHubRelease({
  required String workingDirectory,
  String? smfPath,
  required GitHubContext github,
  GitHubApi? githubApi,
}) => ReleaseOrchestrator(
  githubApi: githubApi,
).plan(workingDirectory: workingDirectory, smfPath: smfPath, github: github);
