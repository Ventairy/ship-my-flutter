import 'package:path/path.dart' as p;
import 'package:smf_apple/src/apple/candidate_options.dart';
import 'package:smf_apple/src/apple/client.dart';
import 'package:smf_apple/src/apple/upload.dart';
import 'package:smf_engine/smf_engine.dart';

export 'candidate_dependencies.dart';
export 'candidate_options.dart';

/// Creates and records exact App Store Connect release candidates.
final class AppleCandidate {
  const AppleCandidate._();

  static Future<CandidateReceipt?> _reusableCandidate(
    String receiptPath, {
    required String fingerprint,
    required String version,
    required String bundleId,
    required String appId,
    required AppStoreConnectApi client,
  }) async {
    if (!(await SmfFileSystem.exists(receiptPath))) return null;
    final receipt = await CandidateReceipt.read(receiptPath);
    if (receipt.platform != Platform.ios ||
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
      platform: Platform.ios,
      version: version,
    );
    for (final entry in localizations.entries) {
      await client.setBetaBuildLocalization(
        buildId: buildId,
        locale: entry.key,
        whatsNew: entry.value,
      );
    }
    final external = config.target == AppleReleaseCandidateTarget.externalTesting;
    await client.addBuildToGroups(
      appId: appId,
      buildId: buildId,
      names: config.groups,
      internal: !external,
    );
    if (external) {
      await client.submitBuildForBetaReview(buildId);
    }
  }

  static Future<void> _recordCandidateReceipt({
    required String root,
    required String receiptPath,
    required CandidateReceipt receipt,
    required bool commitReceipt,
    required GitHubContext? github,
    required bool refreshed,
  }) async {
    await SmfFileSystem.writeJson(receiptPath, receipt.toJson());
    if (!commitReceipt) return;
    try {
      await CandidateGit.commitReceipt(
        repositoryRoot: root,
        receiptPath: receiptPath,
        platform: Platform.ios,
        version: receipt.version,
        github: github,
      );
    } on Exception catch (error) {
      final description = refreshed ? 'refreshed candidate receipt' : 'candidate receipt';
      throw SmfError(
        'The TestFlight build is valid, but its $description could not be '
            'committed. Do not merge the release PR until this is repaired.',
        'CANDIDATE_RECEIPT_COMMIT',
        cause: error,
      );
    }
  }

  /// Creates or reuses the exact candidate described by [options].
  static Future<CandidateReceipt> create(AppleCandidateOptions options) async {
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
    final branch = await gitClient.currentBranch();
    final releaseBranch = ReleaseReference.branch(config.appId);
    SmfError.check(
      branch == releaseBranch,
      'Release-candidate creation only runs on $releaseBranch.',
      'CANDIDATE_BRANCH',
    );
    SmfError.check(
      await gitClient.isClean(),
      'The candidate checkout must be clean before repository hooks run.',
      'DIRTY_WORKTREE',
    );
    final state = manifest.ios;
    SmfError.check(
      state.pendingRelease,
      'The iOS manifest does not contain a pending release.',
      'NO_PENDING_RELEASE',
    );
    final hookStartingSha = await gitClient.currentSha();
    final hookRan = await options.dependencies.runBeforeBuild(
      workingDirectory: paths.directory,
    );
    if (hookRan) {
      await CandidateGit.commitBeforeBuildChanges(
        repositoryRoot: repositoryRoot,
        platform: Platform.ios,
        version: state.version,
        startingSha: hookStartingSha,
        github: options.github,
      );
    }
    final projectRoot = paths.appRoot;
    final bundleId = await options.dependencies.resolveBundleIdentifier(
      projectRoot,
      config.ios,
      flavor: config.flavor,
    );
    final ownsClient = options.client == null;
    final client = options.client ?? AppStoreConnectClient(options.appleCredentials);
    try {
      final app = await client.findApp(bundleId);
      final fingerprint = await SourceFingerprint.calculate(paths.directory);
      final receiptPath = paths.candidatePath(
        platform: Platform.ios,
        version: state.version,
      );
      final reusable = await _reusableCandidate(
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
        final refreshed = reusable.copyWith(
          testingDestinations: config.ios.appStore.releaseCandidate.groups,
        );
        await _recordCandidateReceipt(
          root: repositoryRoot,
          receiptPath: receiptPath,
          receipt: refreshed,
          commitReceipt: options.commitReceipt,
          github: options.github,
          refreshed: true,
        );
        return refreshed;
      }

      final buildNumber = await client.nextBuildNumber(
        appId: app.id,
        version: state.version,
      );
      final sourceSha = await gitClient.currentSha();
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
              'candidate.',
          'BUILD_DIRTY_WORKTREE',
        );
        SmfError.check(
          await SourceFingerprint.calculate(paths.directory) == fingerprint,
          'A tracked build input changed while producing the IPA.',
          'BUILD_INPUT_CHANGED',
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
      final receipt = CandidateReceipt(
        platform: Platform.ios,
        version: state.version,
        buildNumber: buildNumber,
        artifactId: build.id,
        applicationId: bundleId,
        storeApplicationId: app.id,
        sourceSha: sourceSha,
        sourceFingerprint: fingerprint,
        artifactSha256: await FileDigest.sha256(ipaPath),
        uploadedAt: options.dependencies.currentTime().toUtc(),
        testingDestinations: config.ios.appStore.releaseCandidate.groups,
      );
      await _recordCandidateReceipt(
        root: repositoryRoot,
        receiptPath: receiptPath,
        receipt: receipt,
        commitReceipt: options.commitReceipt,
        github: options.github,
        refreshed: false,
      );
      return receipt;
    } finally {
      if (ownsClient) client.close();
    }
  }
}
