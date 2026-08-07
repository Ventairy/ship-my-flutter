import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:smf_engine/src/ios/client.dart';
import 'package:smf_engine/src/ios/dtos/apple_ship_release_result_dto.dart';
import 'package:smf_engine/src/ios/promotion_options.dart';

export 'dtos/apple_ship_release_result_dto.dart';
export 'promotion_options.dart';

/// Promotes exact tested App Store Connect release candidates without rebuilding.
final class AppleRelease {
  const AppleRelease._();

  /// Verifies and promotes the exact release candidate described by [options].
  static Future<AppleShipReleaseResultDto> promote(
    ApplePromotionOptions options,
  ) async {
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
      config.ios.isEnabled,
      'iOS delivery is disabled in configuration.',
      SmfErrorCode.iosDisabled,
    );
    SmfError.check(
      await gitClient.currentBranch() == config.targetBranch,
      'Shipping only runs on ${config.targetBranch}.',
      SmfErrorCode.promotionBranch,
    );
    SmfError.check(
      await gitClient.isClean(),
      'The promotion checkout must be clean before its source is verified.',
      SmfErrorCode.dirtyWorktree,
    );
    final state = manifest.platforms.ios;
    SmfError.check(
      state.isReleasePending,
      'The iOS manifest does not contain a pending release.',
      SmfErrorCode.noPendingRelease,
    );
    final receipt = await ReleaseCandidateReceiptDto.fromJsonFilePath(
      paths.releaseCandidateReceiptPath(
        platform: ReleasePlatform.ios,
        version: state.version,
      ),
    );
    SmfError.check(
      receipt.version == state.version && receipt.platform == ReleasePlatform.ios,
      'The release candidate receipt does not match the pending iOS release.',
      SmfErrorCode.releaseCandidateMismatch,
    );
    SmfError.check(
      await SourceFingerprint.calculate(paths.directory) == receipt.sourceFingerprint,
      'The merged source does not match the tested TestFlight release candidate. '
      'Produce a new release candidate before promoting this version.',
      SmfErrorCode.untestedSource,
    );
    final sourceCommitHash = await gitClient.currentCommitHash();
    final tag = ReleaseReference.tag(
      config.appId,
      ReleasePlatform.ios,
      state.version,
    );
    await gitClient.verifyRemoteTagCommitIfPresent(
      tag: tag,
      expectedCommitHash: sourceCommitHash,
      token: options.github.token,
    );

    final shouldCloseClient = options.client == null;
    final client = options.client ?? AppStoreConnectClient(options.appleCredentials);
    GitHubRestApi? ownedGitHubApi;
    final githubApi = options.githubApi ?? (ownedGitHubApi = GitHubRestApi(context: options.github));
    try {
      final existingGitHubRelease = await githubApi.releaseByTag(tag);
      if (existingGitHubRelease != null) {
        SmfError.check(
          existingGitHubRelease.tagName == tag && existingGitHubRelease.targetCommitish == sourceCommitHash,
          'GitHub Release $tag does not target the verified release commit.',
          SmfErrorCode.remoteTagMismatch,
        );
      }
      final bundleId = await options.resolveBundleIdentifier(
        paths.appRoot,
        config.ios,
        flavor: config.flavor,
      );
      SmfError.check(
        receipt.applicationId == bundleId,
        'The release candidate receipt bundle identifier does not match the current iOS '
        'configuration.',
        SmfErrorCode.releaseCandidateBundleMismatch,
      );
      final app = await client.findApp(bundleId);
      SmfError.check(
        receipt.storeApplicationId == app.id,
        'The release candidate receipt App Store app does not match the configured '
        'bundle identifier.',
        SmfErrorCode.releaseCandidateAppMismatch,
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
        SmfErrorCode.releaseCandidateInvalid,
      );

      String? appStoreVersionId;
      String? reviewSubmissionId;
      String? betaReviewSubmissionId;
      final ship = config.ios.appStore.ship;
      if (ship case AppleShipConfig(target: AppleShipTarget.externalTesting)) {
        final notes = await SmfState.storeReleaseNotes(paths.directory);
        for (final entry in notes.forRelease(platform: ReleasePlatform.ios, version: state.version).entries) {
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
          isInternal: false,
        );
        betaReviewSubmissionId = await client.submitBuildForBetaReview(
          receipt.artifactId,
        );
      } else if (ship != null) {
        final appStoreVersion = await client.findOrCreateAppStoreVersion(
          appId: app.id,
          version: state.version,
          shouldReleaseAutomatically: ship.target == AppleShipTarget.production,
        );
        appStoreVersionId = appStoreVersion.id;
        SmfError.check(
          !appStoreVersion.attributes.appVersionState.isRejected,
          'App Store version ${state.version} is '
          '${appStoreVersion.attributes.appVersionState.name}. Resolve the '
          'version in App Store Connect before retrying.',
          SmfErrorCode.appStoreVersionRejected,
        );
        if (appStoreVersion.attributes.appVersionState.isEditable) {
          await client.attachBuildToVersion(
            appStoreVersionId: appStoreVersion.id,
            buildId: receipt.artifactId,
          );
          final notes = await SmfState.storeReleaseNotes(paths.directory);
          for (final entry in notes.forRelease(platform: ReleasePlatform.ios, version: state.version).entries) {
            await client.setAppStoreReleaseNotes(
              appStoreVersionId: appStoreVersion.id,
              locale: entry.key,
              whatsNew: entry.value,
            );
          }
        }
        SmfError.check(
          await client.appStoreVersionBuildId(appStoreVersion.id) == receipt.artifactId,
          'The App Store version is not attached to the exact tested release candidate '
          'build.',
          SmfErrorCode.appStoreBuildMismatch,
        );
        reviewSubmissionId = await client.submitVersionForReview(
          appId: app.id,
          appStoreVersionId: appStoreVersion.id,
        );
      }

      final changelog = await SmfState.changelog(paths.directory);
      final release = changelog.platforms.ios.releaseVersion(state.version);
      if (release == null) {
        throw SmfError(
          'Missing changelog for iOS ${state.version}',
          SmfErrorCode.missingChangelog,
        );
      }
      final githubRelease =
          existingGitHubRelease ??
          await githubApi.createRelease(
            tag: tag,
            targetCommitish: sourceCommitHash,
            name: '${config.appId} iOS v${state.version}',
            body: ReleaseChangelog.markdown(
              platform: ReleasePlatform.ios,
              release: release,
            ),
          );
      return AppleShipReleaseResultDto(
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
      if (shouldCloseClient) client.close();
    }
  }
}
