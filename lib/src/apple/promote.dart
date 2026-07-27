import 'package:path/path.dart' as p;

import '../candidate_receipt.dart';
import '../changelog.dart';
import '../config.dart';
import '../error.dart';
import '../fingerprint.dart';
import '../git.dart';
import '../github_api.dart';
import '../model.dart';
import '../paths.dart';
import '../release_plan.dart';
import '../validate.dart';
import 'client.dart';
import 'dtos/promotion_result.dart';
import 'promotion_options.dart';

export 'dtos/promotion_result.dart';
export 'promotion_options.dart';

Future<PromotionResult> promoteIosRelease(PromotionOptions options) async {
  final workingDirectory = p.normalize(p.absolute(options.workingDirectory));
  final paths = resolveSmfPaths(workingDirectory, smfPath: options.smfPath);
  final repositoryRoot = paths.repositoryRoot;
  await validateRepository(paths.directory);
  final (config, manifest) = await (
    loadConfig(paths.directory),
    loadManifest(paths.directory),
  ).wait;
  invariant(
    config.ios.enabled,
    'iOS delivery is disabled in configuration.',
    'IOS_DISABLED',
  );
  invariant(
    await currentBranch(repositoryRoot) == config.targetBranch,
    'Shipping only runs on ${config.targetBranch}.',
    'PROMOTION_BRANCH',
  );
  invariant(
    await isClean(repositoryRoot),
    'The promotion checkout must be clean before its source is verified.',
    'DIRTY_WORKTREE',
  );
  final state = manifest.ios;
  invariant(
    state.pendingRelease,
    'The iOS manifest does not contain a pending release.',
    'NO_PENDING_RELEASE',
  );
  final receipt = await loadCandidateReceipt(
    candidatePath(paths.directory, Platform.ios, state.version),
  );
  invariant(
    receipt.version == state.version && receipt.platform == Platform.ios,
    'The candidate receipt does not match the pending iOS release.',
    'CANDIDATE_MISMATCH',
  );
  invariant(
    await sourceFingerprint(paths.directory) == receipt.sourceFingerprint,
    'The merged source does not match the tested TestFlight candidate. '
        'Produce a new candidate before promoting this version.',
    'UNTESTED_SOURCE',
  );

  final client =
      options.client ?? AppStoreConnectClient(options.appleCredentials);
  final bundleId = await options.resolveBundleIdentifier(
    paths.appRoot,
    config.ios,
    flavor: config.flavor,
  );
  invariant(
    receipt.bundleId == bundleId,
    'The candidate receipt bundle identifier does not match the current iOS '
        'configuration.',
    'CANDIDATE_BUNDLE_MISMATCH',
  );
  final app = await client.findApp(bundleId);
  invariant(
    receipt.appId == app.id,
    'The candidate receipt App Store app does not match the configured bundle '
        'identifier.',
    'CANDIDATE_APP_MISMATCH',
  );
  final versionBuilds = await client.buildsForVersion(app.id, state.version);
  final build = versionBuilds
      .where((ApiResource<BuildAttributes> item) => item.id == receipt.buildId)
      .firstOrNull;
  invariant(
    build?.attributes.processingState == 'VALID' &&
        build?.attributes.version == receipt.buildNumber,
    'The recorded Apple build is not a valid build for the configured app and '
        'marketing version.',
    'CANDIDATE_INVALID',
  );

  String? appStoreVersionId;
  String? reviewSubmissionId;
  if (config.ios.appStore.mode != ReleaseMode.upload) {
    final appStoreVersion = await client.findOrCreateAppStoreVersion(
      app.id,
      state.version,
      releaseAutomatically: config.ios.appStore.mode == ReleaseMode.automatic,
    );
    appStoreVersionId = appStoreVersion.id;
    if (appStoreVersion.attributes.appStoreState == 'PREPARE_FOR_SUBMISSION') {
      await client.attachBuildToVersion(appStoreVersion.id, receipt.buildId);
      final notes = await loadStoreReleaseNotes(paths.directory);
      for (final entry
          in (notes[Platform.ios]?[state.version] ?? const <String, String>{})
              .entries) {
        await client.setAppStoreReleaseNotes(
          appStoreVersion.id,
          entry.key,
          entry.value,
        );
      }
    }
    invariant(
      await client.appStoreVersionBuildId(appStoreVersion.id) ==
          receipt.buildId,
      'The App Store version is not attached to the exact tested candidate '
          'build.',
      'APP_STORE_BUILD_MISMATCH',
    );
    reviewSubmissionId = await client.submitVersionForReview(
      app.id,
      appStoreVersion.id,
    );
  }

  final changelog = await loadChangelog(paths.directory);
  final release = changelog.iosReleases[state.version];
  if (release == null) {
    throw SmfError(
      'Missing changelog for iOS ${state.version}',
      'MISSING_CHANGELOG',
    );
  }
  final tag = releaseTag(Platform.ios, state.version);
  final githubApi = options.githubApi ?? GitHubRestApi(context: options.github);
  final githubRelease =
      await githubApi.releaseByTag(tag) ??
      await githubApi.createRelease(
        tag: tag,
        targetCommitish: await currentSha(repositoryRoot),
        name: 'iOS v${state.version}',
        body: releaseNotesMarkdown(Platform.ios, release),
      );
  return PromotionResult(
    version: state.version,
    tag: tag,
    buildId: receipt.buildId,
    appStoreVersionId: appStoreVersionId,
    reviewSubmissionId: reviewSubmissionId,
    githubReleaseUrl: githubRelease.htmlUrl,
  );
}
