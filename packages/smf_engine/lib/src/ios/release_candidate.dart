import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:smf_engine/src/ios/client.dart';
import 'package:smf_engine/src/ios/release_candidate_options.dart';
import 'package:smf_engine/src/ios/upload.dart';

export 'release_candidate_dependencies.dart';
export 'release_candidate_options.dart';

/// Creates and records exact App Store Connect release candidates.
final class AppleReleaseCandidate {
  const AppleReleaseCandidate._();

  static Future<ReleaseCandidateIntentDto?> _matchingIntent(
    String intentPath, {
    required String fingerprint,
    required String version,
    required String bundleId,
    required String appId,
  }) async {
    if (!(await File(intentPath).exists())) return null;
    final intent = await ReleaseCandidateIntentDto.fromJsonFile(intentPath);
    if (intent.platform != ReleasePlatform.ios ||
        intent.version != version ||
        intent.applicationId != bundleId ||
        intent.storeApplicationId != appId ||
        intent.sourceFingerprint != fingerprint) {
      return null;
    }
    return intent;
  }

  static Future<ReleaseCandidateReceiptDto?> _reusableReleaseCandidate(
    String receiptPath, {
    required String fingerprint,
    required String version,
    required String bundleId,
    required String appId,
    required AppStoreConnectApi client,
  }) async {
    if (!(await File(receiptPath).exists())) return null;
    final receipt = await ReleaseCandidateReceiptDto.fromJsonFilePath(
      receiptPath,
    );
    if (receipt.platform != ReleasePlatform.ios ||
        receipt.version != version ||
        receipt.applicationId != bundleId ||
        receipt.storeApplicationId != appId ||
        receipt.sourceFingerprint != fingerprint) {
      return null;
    }
    final build = (await client.buildsForVersion(
      appId: appId,
      version: version,
    )).where((item) => item.id == receipt.artifactId).firstOrNull;
    if (build?.attributes.processingState != BuildProcessingState.valid ||
        build?.attributes.version != receipt.buildNumber) {
      return null;
    }
    return receipt;
  }

  static Future<void> _applyTestflightMetadata({
    required String root,
    required String version,
    required String appId,
    required String buildId,
    required AppleReleaseCandidateConfig config,
    required AppStoreConnectApi client,
  }) async {
    final notes = await SmfState.storeReleaseNotes(root);
    final localizations = notes.forRelease(
      platform: ReleasePlatform.ios,
      version: version,
    );
    for (final entry in localizations.entries) {
      await client.setBetaBuildLocalization(
        buildId: buildId,
        locale: entry.key,
        whatsNew: entry.value,
      );
    }
    final isExternal = config.target == AppleReleaseCandidateTarget.externalTesting;
    await client.addBuildToGroups(
      appId: appId,
      buildId: buildId,
      names: config.groups,
      isInternal: !isExternal,
    );
    if (isExternal) {
      await client.submitBuildForBetaReview(buildId);
    }
  }

  static Future<void> _recordReleaseCandidateReceipt({
    required String root,
    required String intentPath,
    required String receiptPath,
    required ReleaseCandidateReceiptDto receipt,
    required bool shouldCommitReceipt,
    required GitHubContext? github,
    required bool isRefreshed,
  }) async {
    await JsonFile(receiptPath).write(receipt.toJson());
    final intent = File(intentPath);
    if (await intent.exists()) await intent.delete();
    if (!shouldCommitReceipt) return;
    try {
      await ReleaseCandidateGit.finalizeReceipt(
        repositoryRoot: root,
        intentPath: intentPath,
        receiptPath: receiptPath,
        platform: ReleasePlatform.ios,
        version: receipt.version,
        github: github,
      );
    } on Exception catch (error) {
      final description = isRefreshed ? 'refreshed release candidate receipt' : 'release candidate receipt';
      throw SmfError(
        'The TestFlight build is valid, but its $description could not be '
        'committed. Do not merge the release PR until this is repaired.',
        SmfErrorCode.releaseCandidateReceiptCommit,
        cause: error,
      );
    }
  }

  static Future<void> _recordIntent({
    required String root,
    required String intentPath,
    required ReleaseCandidateIntentDto intent,
    required bool shouldCommitIntent,
    required GitHubContext? github,
  }) async {
    await JsonFile(intentPath).write(intent.toJson());
    if (!shouldCommitIntent) return;
    try {
      await ReleaseCandidateGit.commitIntent(
        repositoryRoot: root,
        intentPath: intentPath,
        platform: ReleasePlatform.ios,
        version: intent.version,
        github: github,
      );
    } on Exception catch (error) {
      throw SmfError(
        'The iOS release candidate was built, but its upload intent could not be '
        'committed. Nothing was uploaded to App Store Connect.',
        SmfErrorCode.releaseCandidateIntentCommit,
        cause: error,
      );
    }
  }

  /// Creates or reuses the exact release candidate described by [options].
  static Future<ReleaseCandidateReceiptDto> create(AppleReleaseCandidateOptions options) async {
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
    final branch = await gitClient.currentBranch();
    final releaseBranch = ReleaseReference.branch(config.appId);
    SmfError.check(
      branch == releaseBranch,
      'Release candidate creation only runs on $releaseBranch.',
      SmfErrorCode.releaseCandidateBranch,
    );
    SmfError.check(
      await gitClient.isClean(),
      'The release candidate checkout must be clean before repository hooks run.',
      SmfErrorCode.dirtyWorktree,
    );
    final state = manifest.platforms.ios;
    SmfError.check(
      state.isReleasePending,
      'The iOS manifest does not contain a pending release.',
      SmfErrorCode.noPendingRelease,
    );
    final hookStartingCommitHash = await gitClient.currentCommitHash();
    final hookRan = await options.dependencies.runBeforeBuild(
      workingDirectory: paths.directory,
    );
    if (hookRan) {
      await ReleaseCandidateGit.commitBeforeBuildChanges(
        repositoryRoot: repositoryRoot,
        platform: ReleasePlatform.ios,
        version: state.version,
        startingCommitHash: hookStartingCommitHash,
        github: options.github,
      );
    }
    final projectRoot = paths.appRoot;
    final bundleId = await options.dependencies.resolveBundleIdentifier(
      projectRoot,
      config.ios,
      flavor: config.flavor,
    );
    final shouldCloseClient = options.client == null;
    final client = options.client ?? AppStoreConnectClient(options.appleCredentials);
    try {
      final app = await client.findApp(bundleId);
      final fingerprint = await SourceFingerprint.calculate(paths.directory);
      final receiptPath = paths.releaseCandidateReceiptPath(
        platform: ReleasePlatform.ios,
        version: state.version,
      );
      final intentPath = paths.releaseCandidateIntentPath(
        platform: ReleasePlatform.ios,
        version: state.version,
      );
      final reusable = await _reusableReleaseCandidate(
        receiptPath,
        fingerprint: fingerprint,
        version: state.version,
        bundleId: bundleId,
        appId: app.id,
        client: client,
      );
      if (reusable != null) {
        await _applyTestflightMetadata(
          root: paths.directory,
          version: state.version,
          appId: app.id,
          buildId: reusable.artifactId,
          config: config.ios.appStore.releaseCandidate,
          client: client,
        );
        final refreshedReceipt = reusable.copyWith(
          testingDestinations: config.ios.appStore.releaseCandidate.groups,
        );
        await _recordReleaseCandidateReceipt(
          root: repositoryRoot,
          intentPath: intentPath,
          receiptPath: receiptPath,
          receipt: refreshedReceipt,
          shouldCommitReceipt: options.shouldCommitReceipt,
          github: options.github,
          isRefreshed: true,
        );
        return refreshedReceipt;
      }

      final sourceCommitHash = await gitClient.currentCommitHash();
      final previousIntent = await _matchingIntent(
        intentPath,
        fingerprint: fingerprint,
        version: state.version,
        bundleId: bundleId,
        appId: app.id,
      );
      if (previousIntent != null) {
        final existingBuilds = await client.buildsForVersion(
          appId: app.id,
          version: state.version,
        );
        final existing = existingBuilds
            .where(
              (build) => build.attributes.version == previousIntent.buildNumber,
            )
            .firstOrNull;
        if (existing != null) {
          final build = existing.attributes.processingState == BuildProcessingState.valid
              ? existing
              : await client.waitForBuild(
                  appId: app.id,
                  version: state.version,
                  buildNumber: previousIntent.buildNumber,
                  timeoutMinutes: config.ios.appStore.releaseCandidate.waitTimeoutMinutes,
                );
          await _applyTestflightMetadata(
            root: paths.directory,
            version: state.version,
            appId: app.id,
            buildId: build.id,
            config: config.ios.appStore.releaseCandidate,
            client: client,
          );
          final recovered = ReleaseCandidateReceiptDto(
            schemaVersion: 1,
            platform: ReleasePlatform.ios,
            version: previousIntent.version,
            buildNumber: previousIntent.buildNumber,
            artifactId: build.id,
            applicationId: previousIntent.applicationId,
            storeApplicationId: previousIntent.storeApplicationId,
            sourceCommitHash: previousIntent.sourceCommitHash,
            sourceFingerprint: previousIntent.sourceFingerprint,
            artifactSha256: previousIntent.artifactSha256,
            uploadedAt: previousIntent.preparedAt,
            testingDestinations: config.ios.appStore.releaseCandidate.groups,
            processingState: 'VALID',
          );
          await _recordReleaseCandidateReceipt(
            root: repositoryRoot,
            intentPath: intentPath,
            receiptPath: receiptPath,
            receipt: recovered,
            shouldCommitReceipt: options.shouldCommitReceipt,
            github: options.github,
            isRefreshed: false,
          );
          return recovered;
        }
      }

      final buildNumber =
          previousIntent?.buildNumber ??
          await client.nextBuildNumber(
            appId: app.id,
            version: state.version,
          );
      final signingBundleIds = await options.dependencies.resolveSigningBundleIdentifiers(
        projectRoot,
        mainBundleId: bundleId,
        flavor: config.flavor,
      );
      final signingAssets = await options.dependencies.resolveProvisioning(
        credentials: options.signingCredentials,
        bundleIds: signingBundleIds,
        client: client,
      );
      final signing = await options.dependencies.installSigning(
        signingAssets,
        bundleId,
      );
      late final String ipaPath;
      late final ReleaseCandidateIntentDto uploadIntent;
      try {
        ipaPath = await options.dependencies.buildIpa(
          projectRoot: projectRoot,
          command: await AppleBuild.resolveCommand(
            projectRoot,
            configuredCommand: config.ios.buildCommand,
          ),
          ipaOutputPath: config.ios.ipaOutputPath,
          version: state.version,
          buildNumber: buildNumber,
          exportOptionsPath: signing.exportOptionsPath,
          flavor: config.flavor,
        );
        SmfError.check(
          await gitClient.isClean(),
          'The Flutter build changed tracked or unignored repository files. '
          'Commit deterministic generated inputs before producing a '
          'release candidate.',
          SmfErrorCode.buildDirtyWorktree,
        );
        SmfError.check(
          await SourceFingerprint.calculate(paths.directory) == fingerprint,
          'A tracked build input changed while producing the IPA.',
          SmfErrorCode.buildInputChanged,
        );
        uploadIntent = ReleaseCandidateIntentDto(
          schemaVersion: 1,
          platform: ReleasePlatform.ios,
          version: state.version,
          buildNumber: buildNumber,
          applicationId: bundleId,
          storeApplicationId: app.id,
          sourceCommitHash: sourceCommitHash,
          sourceFingerprint: fingerprint,
          artifactSha256: await FileDigest.sha256(ipaPath),
          preparedAt: options.dependencies.currentTime().toUtc(),
        );
        await _recordIntent(
          root: repositoryRoot,
          intentPath: intentPath,
          intent: uploadIntent,
          shouldCommitIntent: options.shouldCommitReceipt,
          github: options.github,
        );
        await options.dependencies.upload(
          ipaPath: ipaPath,
          credentials: options.appleCredentials,
        );
      } finally {
        await signing.cleanup();
      }

      final build = await client.waitForBuild(
        appId: app.id,
        version: state.version,
        buildNumber: buildNumber,
        timeoutMinutes: config.ios.appStore.releaseCandidate.waitTimeoutMinutes,
      );
      await _applyTestflightMetadata(
        root: paths.directory,
        version: state.version,
        appId: app.id,
        buildId: build.id,
        config: config.ios.appStore.releaseCandidate,
        client: client,
      );
      final receipt = ReleaseCandidateReceiptDto(
        schemaVersion: 1,
        platform: ReleasePlatform.ios,
        version: state.version,
        buildNumber: buildNumber,
        artifactId: build.id,
        applicationId: bundleId,
        storeApplicationId: app.id,
        sourceCommitHash: sourceCommitHash,
        sourceFingerprint: fingerprint,
        artifactSha256: uploadIntent.artifactSha256,
        uploadedAt: uploadIntent.preparedAt,
        testingDestinations: config.ios.appStore.releaseCandidate.groups,
        processingState: 'VALID',
      );
      await _recordReleaseCandidateReceipt(
        root: repositoryRoot,
        intentPath: intentPath,
        receiptPath: receiptPath,
        receipt: receipt,
        shouldCommitReceipt: options.shouldCommitReceipt,
        github: options.github,
        isRefreshed: false,
      );
      return receipt;
    } finally {
      if (shouldCloseClient) client.close();
    }
  }
}
