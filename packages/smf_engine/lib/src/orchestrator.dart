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
    final paths = SmfPaths.resolve(workingDirectory, smfPath: smfPath);
    final repositoryRoot = paths.repositoryRoot;
    final gitClient = GitClient(root: repositoryRoot);
    final (config, manifest) = await (
      SmfState.config(paths.directory),
      SmfState.manifest(paths.directory),
    ).wait;
    if (config.enabledPlatforms.isEmpty) {
      return const CommandResult(phase: 'noop');
    }
    final branch = await gitClient.currentBranch();
    final releaseBranch = ReleaseReference.branch(config.appId);
    final releasePlanner = ReleasePlanner(
      gitClient: gitClient,
      appId: config.appId,
      releaseTriggerPaths: paths.releaseTriggerPaths(
        config.releaseTriggerPaths,
      ),
    );
    if (branch != releaseBranch && branch != config.targetBranch) {
      return const CommandResult(phase: 'noop');
    }
    await RepositoryValidator.validate(paths.directory);
    final pending = <ReleaseTarget>[];
    for (final platform in config.enabledPlatforms) {
      final state = manifest.forPlatform(platform);
      if (state.pendingRelease &&
          await releasePlanner.needsPromotion(
            manifest: manifest,
            platform: platform,
          )) {
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
      final plan = await releasePlanner.create(
        manifest: manifest,
        platform: platform,
      );
      if (plan != null) plans.add(plan);
    }
    if (plans.isEmpty) return const CommandResult(phase: 'noop');
    final pull = await ReleasePullRequest.createOrUpdate(
      workingDirectory: paths.directory,
      config: config,
      plans: plans,
      context: github,
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
