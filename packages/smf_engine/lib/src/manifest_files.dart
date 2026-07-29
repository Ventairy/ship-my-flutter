import 'dart:io';

import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/json_file.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/release_branch.dart';

/// Persists planned platform releases in the app-scoped registry.
final class ReleaseRegistry {
  const ReleaseRegistry._();

  /// Applies [plan] to the generated manifest and changelog.
  static Future<void> apply({
    required String root,
    required ReleasePlanDto plan,
    required String gitHubToken,
    DateTime? preparedAt,
  }) async {
    final paths = SmfPaths.resolve(root);
    final config = await SmfState.config(root);
    final manifest = await SmfState.manifest(root);
    final changelog = await SmfState.changelog(root);
    final gitClient = GitClient(root: paths.repositoryRoot);
    final releases = List<ChangelogPlatformReleaseVersionDto>.of(
      changelog.platforms.select(plan.platform).releases,
    );
    final previousState = manifest.forPlatform(plan.platform);
    if (previousState.isReleasePending &&
        previousState.version != plan.nextVersion &&
        await gitClient.remoteTagCommitHash(
              ReleaseReference.tag(
                config.appId,
                plan.platform,
                previousState.version,
              ),
              gitHubToken,
            ) ==
            null) {
      releases.removeWhere(
        (release) => release.version == previousState.version,
      );
      final releaseCandidateReceiptFile = File(
        paths.releaseCandidateReceiptPath(
          platform: plan.platform,
          version: previousState.version,
        ),
      );
      final releaseCandidateIntentFile = File(
        paths.releaseCandidateIntentPath(
          platform: plan.platform,
          version: previousState.version,
        ),
      );
      await Future.wait(<Future<void>>[
        if (await releaseCandidateReceiptFile.exists()) releaseCandidateReceiptFile.delete(),
        if (await releaseCandidateIntentFile.exists()) releaseCandidateIntentFile.delete(),
      ]);
    }
    releases
      ..removeWhere((release) => release.version == plan.nextVersion)
      ..insert(
        0,
        ChangelogPlatformReleaseVersionDto(
          version: plan.nextVersion,
          preparedAt: (preparedAt ?? DateTime.now()).toUtc(),
          baseCommitHash: plan.baseCommitHash,
          endCommitHash: plan.endCommitHash,
          changes: plan.changes,
        ),
      );

    final nextManifest = switch (plan.platform) {
      ReleasePlatform.ios => manifest.copyWith(
        platforms: manifest.platforms.copyWith(
          ios: manifest.platforms.ios.copyWith(
            version: plan.nextVersion,
            endCommitHash: plan.endCommitHash,
            isReleasePending: true,
          ),
        ),
      ),
      ReleasePlatform.android => manifest.copyWith(
        platforms: manifest.platforms.copyWith(
          android: manifest.platforms.android.copyWith(
            version: plan.nextVersion,
            endCommitHash: plan.endCommitHash,
            isReleasePending: true,
          ),
        ),
      ),
    };
    final nextChangelog = switch (plan.platform) {
      ReleasePlatform.ios => changelog.copyWith(
        platforms: changelog.platforms.copyWith(
          ios: changelog.platforms.ios.copyWith(releases: releases),
        ),
      ),
      ReleasePlatform.android => changelog.copyWith(
        platforms: changelog.platforms.copyWith(
          android: changelog.platforms.android.copyWith(releases: releases),
        ),
      ),
    };
    await (
      JsonFile(paths.manifest).write(nextManifest.toJson()),
      JsonFile(paths.changelog).write(nextChangelog.toJson()),
    ).wait;
  }
}
