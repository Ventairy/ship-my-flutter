import 'dart:io';

import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/release_branch.dart';
import 'package:smf_engine/src/serialization.dart';

/// Persists planned platform releases in the app-scoped registry.
final class ReleaseRegistry {
  const ReleaseRegistry._();

  /// Applies [plan] to the generated manifest and changelog.
  static Future<void> apply({
    required String root,
    required ReleasePlan plan,
    DateTime? preparedAt,
  }) async {
    final paths = SmfPaths.resolve(root);
    final config = await SmfState.config(root);
    final manifest = await SmfState.manifest(root);
    final changelog = await SmfState.changelog(root);
    final gitClient = GitClient(root: paths.repositoryRoot);
    final releases = Map<String, ChangelogRelease>.of(
      changelog.releasesFor(plan.platform),
    );
    final previousState = manifest.forPlatform(plan.platform);
    if (previousState.pendingRelease &&
        previousState.version != plan.nextVersion &&
        !(await gitClient.tagExists(
          ReleaseReference.tag(
            config.appId,
            plan.platform,
            previousState.version,
          ),
        ))) {
      releases.remove(previousState.version);
      final candidate = File(
        paths.candidatePath(
          platform: plan.platform,
          version: previousState.version,
        ),
      );
      final candidateIntent = File(
        paths.candidateIntentPath(
          platform: plan.platform,
          version: previousState.version,
        ),
      );
      await Future.wait(<Future<void>>[
        if (await candidate.exists()) candidate.delete(),
        if (await candidateIntent.exists()) candidateIntent.delete(),
      ]);
    }
    releases[plan.nextVersion] = ChangelogRelease(
      version: plan.nextVersion,
      preparedAt: (preparedAt ?? DateTime.now()).toUtc(),
      baseSha: plan.baseSha,
      headSha: plan.headSha,
      changes: plan.changes,
    );

    final nextManifest = switch (plan.platform) {
      Platform.ios => manifest.copyWith(
        ios: manifest.ios.copyWith(
          version: plan.nextVersion,
          pendingRelease: true,
        ),
      ),
      Platform.android => manifest.copyWith(
        android: manifest.android.copyWith(
          version: plan.nextVersion,
          pendingRelease: true,
        ),
      ),
    };
    final nextChangelog = switch (plan.platform) {
      Platform.ios => changelog.copyWith(iosReleases: releases),
      Platform.android => changelog.copyWith(androidReleases: releases),
    };
    await (
      SmfFileSystem.writeJson(paths.manifest, nextManifest.toJson()),
      SmfFileSystem.writeJson(paths.changelog, nextChangelog.toJson()),
    ).wait;
  }
}
