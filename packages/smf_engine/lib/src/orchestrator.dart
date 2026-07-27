import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/github.dart';
import 'package:smf_engine/src/github_api.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/release_branch.dart';
import 'package:smf_engine/src/release_plan.dart';
import 'package:smf_engine/src/validate.dart';

final class ReleaseOrchestrator {
  const ReleaseOrchestrator({this.githubApi});

  final GitHubApi? githubApi;

  Future<CommandResult> plan({
    required String workingDirectory,
    required GitHubContext github,
    String? smfPath,
  }) async {
    final paths = resolveSmfPaths(workingDirectory, smfPath: smfPath);
    final repositoryRoot = paths.repositoryRoot;
    final (config, manifest) = await (
      loadConfig(paths.directory),
      loadManifest(paths.directory),
    ).wait;
    if (config.enabledPlatforms.isEmpty) {
      return const CommandResult(phase: 'noop');
    }
    final branch = await currentBranch(repositoryRoot);
    const releaseBranch = releaseBranchName;
    if (branch != releaseBranch && branch != config.targetBranch) {
      return const CommandResult(phase: 'noop');
    }
    await validateRepository(paths.directory);
    final pending = <ReleaseTarget>[];
    for (final platform in config.enabledPlatforms) {
      final state = manifest.forPlatform(platform);
      if (state.pendingRelease &&
          await releaseNeedsPromotion(repositoryRoot, manifest, platform)) {
        pending.add(
          ReleaseTarget(platform: platform, version: state.version),
        );
      }
    }
    if (branch == releaseBranch) {
      return pending.isNotEmpty
          ? CommandResult(
              phase: 'release-candidate',
              releases: pending,
              branch: releaseBranch,
            )
          : const CommandResult(phase: 'noop');
    }
    if (pending.isNotEmpty) {
      return CommandResult(phase: 'ship', releases: pending);
    }
    final plans = <ReleasePlan>[];
    for (final platform in config.enabledPlatforms) {
      final plan = await createReleasePlan(
        repositoryRoot,
        manifest,
        platform,
      );
      if (plan != null) plans.add(plan);
    }
    if (plans.isEmpty) return const CommandResult(phase: 'noop');
    final pull = await createOrUpdateReleasePullRequest(
      paths.directory,
      config,
      plans,
      github,
      githubApi: githubApi,
    );
    return CommandResult(
      phase: 'release-candidate',
      releases: <ReleaseTarget>[
        for (final plan in plans)
          ReleaseTarget(
            platform: plan.platform,
            version: plan.nextVersion,
          ),
      ],
      branch: pull.branch,
      pullRequestNumber: pull.pullRequestNumber,
    );
  }
}

Future<CommandResult> planGitHubRelease({
  required String workingDirectory,
  required GitHubContext github,
  String? smfPath,
  GitHubApi? githubApi,
}) => ReleaseOrchestrator(
  githubApi: githubApi,
).plan(workingDirectory: workingDirectory, smfPath: smfPath, github: github);
