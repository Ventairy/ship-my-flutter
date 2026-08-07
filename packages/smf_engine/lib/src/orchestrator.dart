import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/github.dart';
import 'package:smf_engine/src/github_api.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/release_branch.dart';
import 'package:smf_engine/src/release_plan.dart';
import 'package:smf_engine/src/validate.dart';

/// Plans and creates app-scoped release pull requests.
final class ReleaseOrchestrator {
  /// Creates an orchestrator with an optional GitHub test double.
  const ReleaseOrchestrator({this.githubApi});

  /// GitHub boundary used for pull-request operations.
  final GitHubApi? githubApi;

  /// Plans the next workflow operation for the selected app and platform.
  Future<PullRequestPhaseResultDto> plan({
    required String workingDirectory,
    required GitHubContext github,
    String? smfPath,
    ReleasePlatform? selectedPlatform,
  }) async {
    final paths = SmfPaths.resolve(workingDirectory, smfPath: smfPath);
    final repositoryRoot = paths.repositoryRoot;
    final gitClient = GitClient(root: repositoryRoot);
    final (config, manifest) = await (
      SmfState.config(paths.directory),
      SmfState.manifest(paths.directory),
    ).wait;
    final platforms = <ReleasePlatform>[
      for (final platform in config.enabledPlatforms)
        if (selectedPlatform == null || platform == selectedPlatform) platform,
    ];
    if (platforms.isEmpty) {
      return const PullRequestPhaseResultDto.noop();
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
      return const PullRequestPhaseResultDto.noop();
    }
    await RepositoryValidator.validate(paths.directory);
    final pending = <ReleaseTargetDto>[];
    for (final platform in platforms) {
      final state = manifest.forPlatform(platform);
      if (state.isReleasePending &&
          await releasePlanner.isPromotionNeeded(
            manifest: manifest,
            platform: platform,
            gitHubToken: github.token,
          )) {
        pending.add(
          ReleaseTargetDto(platform: platform, version: state.version),
        );
      }
    }
    if (branch == releaseBranch) {
      return pending.isNotEmpty
          ? PullRequestPhaseResultDto.releaseCandidate(
              targets: pending,
              releaseBranch: releaseBranch,
            )
          : const PullRequestPhaseResultDto.noop();
    }
    if (pending.isNotEmpty) {
      return PullRequestPhaseResultDto.ship(
        targets: pending,
      );
    }
    final plans = <ReleasePlanDto>[];
    for (final platform in platforms) {
      final plan = await releasePlanner.create(
        manifest: manifest,
        platform: platform,
        gitHubToken: github.token,
      );
      if (plan != null) plans.add(plan);
    }
    if (plans.isEmpty) {
      return const PullRequestPhaseResultDto.noop();
    }
    final pull = await ReleasePullRequest.createOrUpdate(
      workingDirectory: paths.directory,
      config: config,
      plans: plans,
      context: github,
      githubApi: githubApi,
    );
    return PullRequestPhaseResultDto.releaseCandidate(
      targets: <ReleaseTargetDto>[
        for (final plan in plans)
          ReleaseTargetDto(
            platform: plan.platform,
            version: plan.nextVersion,
          ),
      ],
      releaseBranch: pull.branch,
      pullRequestNumber: pull.pullRequestNumber,
    );
  }
}
