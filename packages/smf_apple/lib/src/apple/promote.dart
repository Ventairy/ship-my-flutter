import 'package:path/path.dart' as p;
import 'package:smf_apple/src/apple/client.dart';
import 'package:smf_apple/src/apple/dtos/promotion_result.dart';
import 'package:smf_apple/src/apple/promotion_options.dart';
import 'package:smf_engine/smf_engine.dart';

export 'dtos/promotion_result.dart';
export 'promotion_options.dart';

/// Promotes exact tested App Store Connect candidates without rebuilding.
final class AppleRelease {
  const AppleRelease._();

  /// Verifies and promotes the exact candidate described by [options].
  static Future<ApplePromotionResult> promote(ApplePromotionOptions options) async {
    final workingDirectory = p.normalize(p.absolute(options.workingDirectory));
    final paths = SmfPaths.resolve(
      workingDirectory,
      smfPath: options.smfPath,
    );
    final repositoryRoot = paths.repositoryRoot;
    final gitClient = GitClient(root: repositoryRoot);
    await RepositoryValidator.validate(paths.directory);
    final (config, manifest) = await (
      SmfState.config(paths.directory),
      SmfState.manifest(paths.directory),
    ).wait;
    SmfError.check(
      config.ios.enabled,
      'iOS delivery is disabled in configuration.',
      'IOS_DISABLED',
    );
    SmfError.check(
      await gitClient.currentBranch() == config.targetBranch,
      'Shipping only runs on ${config.targetBranch}.',
      'PROMOTION_BRANCH',
    );
    SmfError.check(
      await gitClient.isClean(),
      'The promotion checkout must be clean before its source is verified.',
      'DIRTY_WORKTREE',
    );
    final state = manifest.ios;
    SmfError.check(
      state.pendingRelease,
      'The iOS manifest does not contain a pending release.',
      'NO_PENDING_RELEASE',
    );
    final receipt = await CandidateReceipt.read(
      paths.candidatePath(
        platform: Platform.ios,
        version: state.version,
      ),
    );
    SmfError.check(
      receipt.version == state.version && receipt.platform == Platform.ios,
      'The candidate receipt does not match the pending iOS release.',
      'CANDIDATE_MISMATCH',
    );
    SmfError.check(
      await SourceFingerprint.calculate(paths.directory) == receipt.sourceFingerprint,
      'The merged source does not match the tested TestFlight candidate. '
          'Produce a new candidate before promoting this version.',
      'UNTESTED_SOURCE',
    );

    final ownsClient = options.client == null;
    final client = options.client ?? AppStoreConnectClient(options.appleCredentials);
    GitHubRestApi? ownedGitHubApi;
    try {
      final bundleId = await options.resolveBundleIdentifier(
        paths.appRoot,
        config.ios,
        flavor: config.flavor,
      );
      SmfError.check(
        receipt.applicationId == bundleId,
        'The candidate receipt bundle identifier does not match the current iOS '
            'configuration.',
        'CANDIDATE_BUNDLE_MISMATCH',
      );
      final app = await client.findApp(bundleId);
      SmfError.check(
        receipt.storeApplicationId == app.id,
        'The candidate receipt App Store app does not match the configured '
            'bundle identifier.',
        'CANDIDATE_APP_MISMATCH',
      );
      final versionBuilds = await client.buildsForVersion(
        appId: app.id,
        version: state.version,
      );
      final build = versionBuilds.where((item) => item.id == receipt.artifactId).firstOrNull;
      SmfError.check(
        build?.attributes.processingState == BuildProcessingState.valid &&
            build?.attributes.version == receipt.buildNumber,
        'The recorded Apple build is not a valid build for the configured app '
            'and marketing version.',
        'CANDIDATE_INVALID',
      );

      String? appStoreVersionId;
      String? reviewSubmissionId;
      String? betaReviewSubmissionId;
      final ship = config.ios.appStore.ship;
      if (ship case AppleShipConfig(target: AppleShipTarget.externalTesting)) {
        final notes = await SmfState.storeReleaseNotes(paths.directory);
        for (final entry in notes.forRelease(platform: Platform.ios, version: state.version).entries) {
          await client.setBetaBuildLocalization(
            buildId: receipt.artifactId,
            locale: entry.key,
            whatsNew: entry.value,
          );
        }
        await client.addBuildToGroups(
          appId: app.id,
          buildId: receipt.artifactId,
          names: ship.groups,
          internal: false,
        );
        betaReviewSubmissionId = await client.submitBuildForBetaReview(
          receipt.artifactId,
        );
      } else if (ship != null) {
        final appStoreVersion = await client.findOrCreateAppStoreVersion(
          appId: app.id,
          version: state.version,
          releaseAutomatically: ship.target == AppleShipTarget.production,
        );
        appStoreVersionId = appStoreVersion.id;
        SmfError.check(
          !appStoreVersion.attributes.appVersionState.isRejected,
          'App Store version ${state.version} is '
              '${appStoreVersion.attributes.appVersionState.name}. Resolve the '
              'version in App Store Connect before retrying.',
          'APP_STORE_VERSION_REJECTED',
        );
        if (appStoreVersion.attributes.appVersionState.isEditable) {
          await client.attachBuildToVersion(
            appStoreVersionId: appStoreVersion.id,
            buildId: receipt.artifactId,
          );
          final notes = await SmfState.storeReleaseNotes(paths.directory);
          for (final entry in notes.forRelease(platform: Platform.ios, version: state.version).entries) {
            await client.setAppStoreReleaseNotes(
              appStoreVersionId: appStoreVersion.id,
              locale: entry.key,
              whatsNew: entry.value,
            );
          }
        }
        SmfError.check(
          await client.appStoreVersionBuildId(appStoreVersion.id) == receipt.artifactId,
          'The App Store version is not attached to the exact tested candidate '
              'build.',
          'APP_STORE_BUILD_MISMATCH',
        );
        reviewSubmissionId = await client.submitVersionForReview(
          appId: app.id,
          appStoreVersionId: appStoreVersion.id,
        );
      }

      final changelog = await SmfState.changelog(paths.directory);
      final release = changelog.iosReleases[state.version];
      if (release == null) {
        throw SmfError(
          'Missing changelog for iOS ${state.version}',
          'MISSING_CHANGELOG',
        );
      }
      final tag = ReleaseReference.tag(
        config.appId,
        Platform.ios,
        state.version,
      );
      final githubApi = options.githubApi ?? (ownedGitHubApi = GitHubRestApi(context: options.github));
      final githubRelease =
          await githubApi.releaseByTag(tag) ??
          await githubApi.createRelease(
            tag: tag,
            targetCommitish: await gitClient.currentSha(),
            name: '${config.appId} iOS v${state.version}',
            body: ReleaseChangelog.markdown(
              platform: Platform.ios,
              release: release,
            ),
          );
      return ApplePromotionResult(
        version: state.version,
        tag: tag,
        artifactId: receipt.artifactId,
        buildNumber: receipt.buildNumber,
        appStoreVersionId: appStoreVersionId,
        reviewSubmissionId: reviewSubmissionId,
        betaReviewSubmissionId: betaReviewSubmissionId,
        githubReleaseUrl: githubRelease.htmlUrl,
      );
    } finally {
      ownedGitHubApi?.close();
      if (ownsClient) client.close();
    }
  }
}
