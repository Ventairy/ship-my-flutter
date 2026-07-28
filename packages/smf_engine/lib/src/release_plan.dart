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
  Future<bool> needsPromotion({
    required SmfManifest manifest,
    required Platform platform,
  }) async {
    final state = manifest.forPlatform(platform);
    if (!state.pendingRelease) return false;
    return !(await gitClient.tagExists(
      ReleaseReference.tag(appId, platform, state.version),
    ));
  }

  /// Creates the next release for [platform], or `null` when no change applies.
  Future<ReleasePlan?> create({
    required SmfManifest manifest,
    required Platform platform,
  }) async {
    final state = manifest.forPlatform(platform);
    final currentTag = ReleaseReference.tag(
      appId,
      platform,
      state.version,
    );
    final baseSha = await gitClient.tagExists(currentTag) ? await gitClient.tagSha(currentTag) : state.baselineSha;
    final headSha = await gitClient.currentSha();
    final commits = await gitClient.commitsBetween(
      baseSha,
      headSha: headSha,
      paths: releaseTriggerPaths,
    );
    final changes = commits
        .map(
          (commit) => ConventionalCommit.parse(commit.sha, commit.message),
        )
        .where(
          (change) => change.platforms.contains(platform) && change.versionBump != null,
        )
        .toList(growable: false);
    if (changes.isEmpty) return null;

    final versionBump = ConventionalCommit.highestVersionBump(changes) ?? VersionBump.patch;
    final currentVersion = Version.parse(state.version);
    final nextVersion = switch (versionBump) {
      VersionBump.major => currentVersion.nextMajor.toString(),
      VersionBump.minor => currentVersion.nextMinor.toString(),
      VersionBump.patch => currentVersion.nextPatch.toString(),
    };
    SmfError.check(
      Version.parse(nextVersion) > currentVersion,
      'Requested version $nextVersion must be greater than ${state.version}',
      'SEMVER_ORDER',
    );
    return ReleasePlan(
      platform: platform,
      currentVersion: state.version,
      nextVersion: nextVersion,
      versionBump: versionBump,
      baseSha: baseSha,
      headSha: headSha,
      changes: changes,
    );
  }
}
