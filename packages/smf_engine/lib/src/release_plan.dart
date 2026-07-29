import 'package:pub_semver/pub_semver.dart';

import 'package:smf_engine/src/conventional_commit.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/release_branch.dart';

/// Derives deterministic platform releases from Git history.
final class ReleasePlanner {
  /// Creates a planner over [gitClient] for one SMF app.
  ReleasePlanner({
    required this.gitClient,
    required this.appId,
    List<String> releaseTriggerPaths = const <String>[],
  }) : releaseTriggerPaths = List<String>.unmodifiable(releaseTriggerPaths);

  /// Creates a planner using the system Git process boundary.
  factory ReleasePlanner.forRepository({
    required String repositoryRoot,
    required String appId,
    List<String> releaseTriggerPaths = const <String>[],
  }) {
    return ReleasePlanner(
      gitClient: GitClient(root: repositoryRoot),
      appId: appId,
      releaseTriggerPaths: releaseTriggerPaths,
    );
  }

  /// Repository Git client used to inspect release history.
  final GitClient gitClient;

  /// App identifier used to derive platform tags.
  final String appId;

  /// Additional repository paths whose commits can trigger this app.
  final List<String> releaseTriggerPaths;

  /// Whether [platform] has a pending version without its immutable tag.
  Future<bool> isPromotionNeeded({
    required ManifestDto manifest,
    required ReleasePlatform platform,
    required String gitHubToken,
  }) async {
    final state = manifest.forPlatform(platform);
    if (!state.isReleasePending) return false;
    return await gitClient.remoteTagCommitHash(
          ReleaseReference.tag(appId, platform, state.version),
          gitHubToken,
        ) ==
        null;
  }

  /// Creates the next release for [platform], or `null` when no change applies.
  Future<ReleasePlanDto?> create({
    required ManifestDto manifest,
    required ReleasePlatform platform,
    required String gitHubToken,
  }) async {
    final state = manifest.forPlatform(platform);
    final currentTag = ReleaseReference.tag(
      appId,
      platform,
      state.version,
    );
    final baseCommitHash = await gitClient.remoteTagCommitHash(currentTag, gitHubToken) ?? state.endCommitHash;
    final endCommitHash = await gitClient.currentCommitHash();
    final commits = await gitClient.commitsBetween(
      baseCommitHash,
      endCommitHash: endCommitHash,
      paths: releaseTriggerPaths,
    );
    final changes = commits
        .map(
          (commit) => ConventionalCommit.parse(commit.commitHash, commit.message),
        )
        .where(
          (change) => change.platforms.contains(platform) && change.versionBumpType != null,
        )
        .toList(growable: false);
    if (changes.isEmpty) return null;

    final versionBumpType = ConventionalCommit.highestVersionBumpType(changes) ?? VersionBumpType.patch;
    final currentVersion = Version.parse(state.version);
    final nextVersion = switch (versionBumpType) {
      VersionBumpType.major => currentVersion.nextMajor.toString(),
      VersionBumpType.minor => currentVersion.nextMinor.toString(),
      VersionBumpType.patch => currentVersion.nextPatch.toString(),
    };
    SmfError.check(
      Version.parse(nextVersion) > currentVersion,
      'Requested version $nextVersion must be greater than ${state.version}',
      SmfErrorCode.semverOrder,
    );
    return ReleasePlanDto(
      platform: platform,
      currentVersion: state.version,
      nextVersion: nextVersion,
      versionBumpType: versionBumpType,
      baseCommitHash: baseCommitHash,
      endCommitHash: endCommitHash,
      changes: changes,
    );
  }
}
