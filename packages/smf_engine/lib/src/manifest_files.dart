import 'dart:io';

import 'config.dart';
import 'git.dart';
import 'model.dart';
import 'paths.dart';
import 'release_plan.dart';
import 'serialization.dart';

Future<void> applyReleasePlan(
  String root,
  ReleasePlan plan, [
  DateTime? preparedAt,
]) async {
  final paths = resolveSmfPaths(root);
  final manifest = await loadManifest(root);
  final changelog = await loadChangelog(root);
  final releases = Map<String, ChangelogRelease>.of(
    changelog.releasesFor(plan.platform),
  );
  final previousState = manifest.forPlatform(plan.platform);
  if (previousState.pendingRelease &&
      previousState.version != plan.nextVersion &&
      !(await tagExists(
        root,
        releaseTag(plan.platform, previousState.version),
      ))) {
    releases.remove(previousState.version);
    final candidate = File(
      candidatePath(root, plan.platform, previousState.version),
    );
    if (await candidate.exists()) await candidate.delete();
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
  };
  final nextChangelog = switch (plan.platform) {
    Platform.ios => changelog.copyWith(iosReleases: releases),
  };
  await (
    writeJson(paths.manifest, nextManifest.toJson()),
    writeJson(paths.changelog, nextChangelog.toJson()),
  ).wait;
}

ChangelogManifest emptyChangelog() =>
    const ChangelogManifest(iosReleases: <String, ChangelogRelease>{});
