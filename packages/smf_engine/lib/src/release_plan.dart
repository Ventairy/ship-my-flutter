import 'package:pub_semver/pub_semver.dart';

import 'package:smf_engine/src/conventional_commit.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/model.dart';

String releaseTag(Platform platform, String version) =>
    '${platform.value}-v$version';

final class ReleasePlanner {
  const ReleasePlanner({required this.gitClient});

  final GitClient gitClient;

  Future<bool> needsPromotion(SmfManifest manifest, Platform platform) async {
    final state = manifest.forPlatform(platform);
    if (!state.pendingRelease) return false;
    return !(await gitClient.tagExists(releaseTag(platform, state.version)));
  }

  Future<ReleasePlan?> create(SmfManifest manifest, Platform platform) async {
    final state = manifest.forPlatform(platform);
    final currentTag = releaseTag(platform, state.version);
    final baseSha = await gitClient.tagExists(currentTag)
        ? await gitClient.tagSha(currentTag)
        : state.baselineSha;
    final headSha = await gitClient.currentSha();
    final commits = await gitClient.commitsBetween(baseSha, headSha);
    final changes = commits
        .map(
          (commit) => parseConventionalCommitForPlatform(
            commit.sha,
            commit.message,
            platform,
          ),
        )
        .where(
          (change) =>
              change.platforms.contains(platform) &&
              (change.bump != null || change.releaseAs != null),
        )
        .toList(growable: false);
    if (changes.isEmpty) return null;

    final releaseAsValues = changes
        .map((change) => change.releaseAs)
        .whereType<String>();
    final releaseAs = releaseAsValues.isEmpty ? null : releaseAsValues.last;
    final bump = highestBump(changes) ?? Bump.patch;
    final currentVersion = Version.parse(state.version);
    final nextVersion =
        releaseAs ??
        switch (bump) {
          Bump.major => currentVersion.nextMajor.toString(),
          Bump.minor => currentVersion.nextMinor.toString(),
          Bump.patch => currentVersion.nextPatch.toString(),
        };
    invariant(
      Version.parse(nextVersion) > currentVersion,
      'Requested version $nextVersion must be greater than ${state.version}',
      'SEMVER_ORDER',
    );
    return ReleasePlan(
      platform: platform,
      currentVersion: state.version,
      nextVersion: nextVersion,
      bump: bump,
      baseSha: baseSha,
      headSha: headSha,
      changes: changes,
    );
  }
}

Future<bool> releaseNeedsPromotion(
  String root,
  SmfManifest manifest,
  Platform platform,
) => ReleasePlanner(
  gitClient: GitClient(root: root),
).needsPromotion(manifest, platform);

Future<ReleasePlan?> createReleasePlan(
  String root,
  SmfManifest manifest,
  Platform platform,
) =>
    ReleasePlanner(gitClient: GitClient(root: root)).create(manifest, platform);
