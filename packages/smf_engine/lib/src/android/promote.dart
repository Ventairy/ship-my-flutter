import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:smf_engine/src/android/android_promotion_options.dart';
import 'package:smf_engine/src/android/client.dart';
import 'package:smf_engine/src/android/dtos/android_ship_release_result_dto.dart';
import 'package:smf_engine/src/android/tracks.dart';

/// Promotes exact tested Google Play release candidates without rebuilding.
final class AndroidRelease {
  const AndroidRelease._();

  /// Verifies and promotes the exact release candidate described by [options].
  static Future<AndroidShipReleaseResultDto> promote(
    AndroidPromotionOptions options,
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
      config.android.isEnabled,
      'Android delivery is disabled in configuration.',
      SmfErrorCode.androidDisabled,
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
    final state = manifest.platforms.android;
    SmfError.check(
      state.isReleasePending,
      'The Android manifest does not contain a pending release.',
      SmfErrorCode.noPendingRelease,
    );
    final receipt = await ReleaseCandidateReceiptDto.fromJsonFilePath(
      paths.releaseCandidateReceiptPath(
        platform: ReleasePlatform.android,
        version: state.version,
      ),
    );
    SmfError.check(
      receipt.version == state.version && receipt.platform == ReleasePlatform.android,
      'The release candidate receipt does not match the pending Android release.',
      SmfErrorCode.releaseCandidateMismatch,
    );
    SmfError.check(
      await SourceFingerprint.calculate(paths.directory) == receipt.sourceFingerprint,
      'The merged source does not match the tested Google Play release candidate. '
      'Produce a new release candidate before promoting this version.',
      SmfErrorCode.untestedSource,
    );
    final packageName = await options.resolvePackage(
      paths.appRoot,
      config.android,
      flavor: config.flavor,
    );
    SmfError.check(
      receipt.applicationId == packageName && receipt.storeApplicationId == packageName,
      'The release candidate receipt package name does not match the configured Android '
      'application.',
      SmfErrorCode.releaseCandidatePackageMismatch,
    );
    final versionCode = int.tryParse(receipt.artifactId);
    if (versionCode == null || receipt.buildNumber != receipt.artifactId || versionCode <= 0) {
      throw const SmfError(
        'The release candidate receipt does not contain a valid Google Play versionCode.',
        SmfErrorCode.releaseCandidateMismatch,
      );
    }
    final sourceCommitHash = await gitClient.currentCommitHash();
    final tag = ReleaseReference.tag(
      config.appId,
      ReleasePlatform.android,
      state.version,
    );
    await gitClient.verifyRemoteTagCommitIfPresent(
      tag: tag,
      expectedCommitHash: sourceCommitHash,
      token: options.github.token,
    );
    final GitHubReleaseDto? existingGitHubRelease;
    if (options.githubApi case final githubApi?) {
      existingGitHubRelease = await githubApi.releaseByTag(tag);
    } else {
      final githubApi = GitHubRestApi(context: options.github);
      try {
        existingGitHubRelease = await githubApi.releaseByTag(tag);
      } finally {
        githubApi.close();
      }
    }
    if (existingGitHubRelease != null) {
      SmfError.check(
        existingGitHubRelease.tagName == tag && existingGitHubRelease.targetCommitish == sourceCommitHash,
        'GitHub Release $tag does not target the verified release commit.',
        SmfErrorCode.remoteTagMismatch,
      );
    }

    final shouldCloseClient = options.client == null;
    final client = options.client ?? await GooglePlayClient.open(options.googlePlayCredentials);
    final testingTracks = GooglePlayTrackNames.releaseCandidate(
      config.android.googlePlay.releaseCandidate,
    );
    final configuredShip = config.android.googlePlay.ship;
    final shipTracks = configuredShip == null ? const <String>[] : GooglePlayTrackNames.ship(configuredShip);
    final promotedTracks = <String>[];
    try {
      final edit = await client.createEdit(packageName);
      var isEditCommitted = false;
      try {
        final bundles = await client.listBundles(
          packageName: packageName,
          editId: edit.id,
        );
        final bundle = bundles.where((item) => item.versionCode == versionCode).firstOrNull;
        SmfError.check(
          bundle?.sha256 == receipt.artifactSha256,
          'The recorded Android App Bundle is not available with the exact '
          'release candidate SHA-256.',
          SmfErrorCode.releaseCandidateInvalid,
        );
        for (final testingTrackName in testingTracks) {
          final testingTrack = await client.getTrack(
            packageName: packageName,
            editId: edit.id,
            track: testingTrackName,
          );
          SmfError.check(
            testingTrack.containsCompletedVersionCode(versionCode),
            'The exact release candidate versionCode is not on configured Google Play '
            'testing track "$testingTrackName" as a completed release.',
            SmfErrorCode.releaseCandidateNotTesting,
          );
        }

        var hasTrackChanged = false;
        for (final shipTrackName in shipTracks) {
          final destination = await client.getTrack(
            packageName: packageName,
            editId: edit.id,
            track: shipTrackName,
          );
          final existingRelease = destination.releaseForVersionCode(versionCode);
          if (existingRelease != null) {
            SmfError.check(
              existingRelease.status == GooglePlayReleaseStatus.completed,
              'Google Play track "$shipTrackName" contains the release candidate in '
              '${existingRelease.status.value} state, not as a completed '
              'release.',
              SmfErrorCode.googlePlayReleaseInProgress,
            );
          } else {
            SmfError.check(
              destination.releases.every(
                (release) => release.status == GooglePlayReleaseStatus.completed,
              ),
              'Google Play track "$shipTrackName" has an unfinished release. '
              'Finish or halt it in Play Console before SMF replaces it.',
              SmfErrorCode.googlePlayReleaseInProgress,
            );
            final notes = await SmfState.storeReleaseNotes(paths.directory);
            await client.updateTrack(
              packageName: packageName,
              editId: edit.id,
              track: GooglePlayTrack(
                name: shipTrackName,
                releases: <GooglePlayRelease>[
                  GooglePlayRelease(
                    status: GooglePlayReleaseStatus.completed,
                    versionCodes: <int>[versionCode],
                    name: state.version,
                    releaseNotes: notes.forRelease(
                      platform: ReleasePlatform.android,
                      version: state.version,
                    ),
                  ),
                ],
              ),
            );
            hasTrackChanged = true;
          }
          promotedTracks.add(shipTrackName);
        }
        if (hasTrackChanged) {
          await client.validateEdit(
            packageName: packageName,
            editId: edit.id,
          );
          await client.commitEdit(
            packageName: packageName,
            editId: edit.id,
            areChangesNotSentForReview: false,
          );
          isEditCommitted = true;
        }
      } finally {
        if (!isEditCommitted) {
          try {
            await client.deleteEdit(
              packageName: packageName,
              editId: edit.id,
            );
          } on Object {
            // An abandoned Google Play edit expires automatically. Cleanup must
            // not hide the promotion result or its original failure.
          }
        }
      }
    } finally {
      if (shouldCloseClient) client.close();
    }

    final changelog = await SmfState.changelog(paths.directory);
    final release = changelog.platforms.android.releaseVersion(state.version);
    if (release == null) {
      throw SmfError(
        'Missing changelog for Android ${state.version}',
        SmfErrorCode.missingChangelog,
      );
    }
    GitHubRestApi? ownedGitHubApi;
    final githubApi = options.githubApi ?? (ownedGitHubApi = GitHubRestApi(context: options.github));
    try {
      final githubRelease =
          existingGitHubRelease ??
          await githubApi.createRelease(
            tag: tag,
            targetCommitish: sourceCommitHash,
            name: '${config.appId} Android v${state.version}',
            body: ReleaseChangelog.markdown(
              platform: ReleasePlatform.android,
              release: release,
            ),
          );
      return AndroidShipReleaseResultDto(
        version: state.version,
        tag: tag,
        versionCode: versionCode,
        testingTrack: testingTracks.first,
        testingTracks: testingTracks,
        shippedTracks: promotedTracks,
        productionTrack: promotedTracks.contains(GooglePlayTrackNames.production)
            ? GooglePlayTrackNames.production
            : null,
        githubReleaseUrl: githubRelease.htmlUrl,
      );
    } finally {
      ownedGitHubApi?.close();
    }
  }
}
