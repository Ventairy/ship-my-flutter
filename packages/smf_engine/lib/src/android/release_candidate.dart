import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:smf_engine/src/android/android_release_candidate_options.dart';
import 'package:smf_engine/src/android/build.dart';
import 'package:smf_engine/src/android/client.dart';
import 'package:smf_engine/src/android/tracks.dart';

/// Creates and records exact Google Play release candidates.
final class AndroidReleaseCandidate {
  const AndroidReleaseCandidate._();

  static Future<ReleaseCandidateIntentDto?> _matchingIntent(
    String intentPath, {
    required String fingerprint,
    required String packageName,
    required String version,
  }) async {
    if (!(await File(intentPath).exists())) return null;
    final intent = await ReleaseCandidateIntentDto.fromJsonFile(intentPath);
    if (intent.platform != ReleasePlatform.android ||
        intent.version != version ||
        intent.applicationId != packageName ||
        intent.storeApplicationId != packageName ||
        intent.sourceFingerprint != fingerprint) {
      return null;
    }
    return intent;
  }

  static Future<void> _recordReceipt({
    required String repositoryRoot,
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
        repositoryRoot: repositoryRoot,
        intentPath: intentPath,
        receiptPath: receiptPath,
        platform: ReleasePlatform.android,
        version: receipt.version,
        github: github,
      );
    } on Exception catch (error) {
      final description = isRefreshed ? 'refreshed release candidate receipt' : 'release candidate receipt';
      throw SmfError(
        'The Google Play release candidate is valid, but its $description could not be '
        'committed. Do not merge the release PR until this is repaired.',
        SmfErrorCode.releaseCandidateReceiptCommit,
        cause: error,
      );
    }
  }

  static Future<void> _recordIntent({
    required String repositoryRoot,
    required String intentPath,
    required ReleaseCandidateIntentDto intent,
    required bool shouldCommitIntent,
    required GitHubContext? github,
  }) async {
    await JsonFile(intentPath).write(intent.toJson());
    if (!shouldCommitIntent) return;
    try {
      await ReleaseCandidateGit.commitIntent(
        repositoryRoot: repositoryRoot,
        intentPath: intentPath,
        platform: ReleasePlatform.android,
        version: intent.version,
        github: github,
      );
    } on Exception catch (error) {
      throw SmfError(
        'The Android release candidate was built, but its upload intent could not be '
        'committed. Nothing was uploaded to Google Play.',
        SmfErrorCode.releaseCandidateIntentCommit,
        cause: error,
      );
    }
  }

  static GooglePlayRelease _testingRelease(
    String version,
    int versionCode,
    Map<String, String> notes,
  ) => GooglePlayRelease(
    status: GooglePlayReleaseStatus.completed,
    versionCodes: <int>[versionCode],
    name: version,
    releaseNotes: notes,
  );

  static Future<ReleaseCandidateReceiptDto?> _reusableReleaseCandidate({
    required String receiptPath,
    required String fingerprint,
    required String packageName,
    required List<String> testingTracks,
    required GooglePlayApi client,
  }) async {
    if (!(await File(receiptPath).exists())) return null;
    final receipt = await ReleaseCandidateReceiptDto.fromJsonFilePath(
      receiptPath,
    );
    if (receipt.platform != ReleasePlatform.android ||
        receipt.sourceFingerprint != fingerprint ||
        receipt.applicationId != packageName) {
      return null;
    }
    final versionCode = int.tryParse(receipt.artifactId);
    if (versionCode == null) return null;
    final edit = await client.createEdit(packageName);
    try {
      final bundles = await client.listBundles(
        packageName: packageName,
        editId: edit.id,
      );
      final bundle = bundles.where((item) => item.versionCode == versionCode).firstOrNull;
      if (bundle?.sha256 != receipt.artifactSha256) return null;
      for (final testingTrack in testingTracks) {
        final track = await client.getTrack(
          packageName: packageName,
          editId: edit.id,
          track: testingTrack,
        );
        if (!track.containsCompletedVersionCode(versionCode)) return null;
      }
      return receipt;
    } finally {
      await _discardEdit(client, packageName, edit.id);
    }
  }

  static Future<void> _discardEdit(
    GooglePlayApi client,
    String packageName,
    String editId,
  ) async {
    try {
      await client.deleteEdit(packageName: packageName, editId: editId);
    } on Object {
      // An abandoned Google Play edit expires automatically. Cleanup must not
      // hide the release candidate result or the original failure that caused rollback.
    }
  }

  /// Builds, signs, uploads, and records an exact internal-testing release candidate.
  /// Creates or reuses the exact release candidate described by [options].
  static Future<ReleaseCandidateReceiptDto> create(
    AndroidReleaseCandidateOptions options,
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
      await gitClient.currentBranch() == ReleaseReference.branch(config.appId),
      'Release candidate creation only runs on '
      '${ReleaseReference.branch(config.appId)}.',
      SmfErrorCode.releaseCandidateBranch,
    );
    SmfError.check(
      await gitClient.isClean(),
      'The release candidate checkout must be clean before repository hooks run.',
      SmfErrorCode.dirtyWorktree,
    );
    final state = manifest.platforms.android;
    SmfError.check(
      state.isReleasePending,
      'The Android manifest does not contain a pending release.',
      SmfErrorCode.noPendingRelease,
    );

    final hookStartingCommitHash = await gitClient.currentCommitHash();
    final hookRan = await options.dependencies.runBeforeBuild(
      workingDirectory: paths.directory,
    );
    if (hookRan) {
      await ReleaseCandidateGit.commitBeforeBuildChanges(
        repositoryRoot: repositoryRoot,
        platform: ReleasePlatform.android,
        version: state.version,
        startingCommitHash: hookStartingCommitHash,
        github: options.github,
      );
    }

    final packageName = await options.dependencies.resolvePackage(
      paths.appRoot,
      config.android,
      flavor: config.flavor,
    );
    final fingerprint = await SourceFingerprint.calculate(paths.directory);
    final receiptPath = paths.releaseCandidateReceiptPath(
      platform: ReleasePlatform.android,
      version: state.version,
    );
    final intentPath = paths.releaseCandidateIntentPath(
      platform: ReleasePlatform.android,
      version: state.version,
    );
    final shouldCloseClient = options.client == null;
    final client = options.client ?? await GooglePlayClient.open(options.googlePlayCredentials);
    try {
      final testingTracks = GooglePlayTrackNames.releaseCandidate(
        config.android.googlePlay.releaseCandidate,
      );
      final reusable = await _reusableReleaseCandidate(
        receiptPath: receiptPath,
        fingerprint: fingerprint,
        packageName: packageName,
        testingTracks: testingTracks,
        client: client,
      );
      if (reusable != null) {
        final refreshedReceipt = reusable.copyWith(
          testingDestinations: testingTracks,
        );
        await _recordReceipt(
          repositoryRoot: repositoryRoot,
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
        packageName: packageName,
        version: state.version,
      );
      final edit = await client.createEdit(packageName);
      var isEditCommitted = false;
      try {
        final existingBundles = await client.listBundles(
          packageName: packageName,
          editId: edit.id,
        );
        var uploadIntent = previousIntent;
        final intentVersionCode = previousIntent == null ? null : int.parse(previousIntent.buildNumber);
        var uploaded = intentVersionCode == null
            ? null
            : existingBundles
                  .where(
                    (bundle) => bundle.versionCode == intentVersionCode,
                  )
                  .firstOrNull;
        if (uploaded != null) {
          final matchingIntent = previousIntent;
          if (matchingIntent == null) {
            throw const SmfError(
              'Google Play matched a release candidate build without a recorded '
              'release candidate intent.',
              SmfErrorCode.releaseCandidateIntentMissing,
            );
          }
          SmfError.check(
            uploaded.sha256 == matchingIntent.artifactSha256,
            'Google Play contains versionCode $intentVersionCode, but its '
            'bundle checksum does not match the committed release candidate '
            'intent.',
            SmfErrorCode.releaseCandidateIntentArtifactMismatch,
          );
        }
        if (uploaded == null) {
          final existingVersionCodes = await client.listArtifactVersionCodes(
            packageName: packageName,
            editId: edit.id,
          );
          final nextVersionCode = previousIntent == null
              ? existingVersionCodes.fold<int>(
                      0,
                      (maximum, versionCode) => versionCode > maximum ? versionCode : maximum,
                    ) +
                    1
              : int.parse(previousIntent.buildNumber);
          SmfError.check(
            nextVersionCode <= 2100000000,
            'Google Play versionCode has reached its supported maximum.',
            SmfErrorCode.versionCodeExhausted,
          );
          final signing = await options.dependencies.installSigning(
            options.signingCredentials,
          );
          late final String aabPath;
          try {
            aabPath = await options.dependencies.buildAab(
              projectRoot: paths.appRoot,
              command: await AndroidBuild.resolveCommand(
                paths.appRoot,
                configuredCommand: config.android.buildCommand,
              ),
              aabOutputPath: config.android.aabOutputPath,
              version: state.version,
              buildNumber: nextVersionCode.toString(),
              signing: signing,
              credentials: options.signingCredentials,
              flavor: config.flavor,
            );
            SmfError.check(
              await gitClient.isClean(),
              'The Flutter build changed tracked or unignored repository '
              'files. Commit deterministic generated inputs before '
              'producing a release candidate.',
              SmfErrorCode.buildDirtyWorktree,
            );
            SmfError.check(
              await SourceFingerprint.calculate(paths.directory) == fingerprint,
              'A tracked build input changed while producing the AAB.',
              SmfErrorCode.buildInputChanged,
            );
          } finally {
            await signing.cleanup();
          }
          final localSha256 = await FileDigest.sha256(aabPath);
          uploadIntent = ReleaseCandidateIntentDto(
            schemaVersion: 1,
            platform: ReleasePlatform.android,
            version: state.version,
            buildNumber: nextVersionCode.toString(),
            applicationId: packageName,
            storeApplicationId: packageName,
            sourceCommitHash: sourceCommitHash,
            sourceFingerprint: fingerprint,
            artifactSha256: localSha256,
            preparedAt: options.dependencies.currentTime().toUtc(),
          );
          await _recordIntent(
            repositoryRoot: repositoryRoot,
            intentPath: intentPath,
            intent: uploadIntent,
            shouldCommitIntent: options.shouldCommitReceipt,
            github: options.github,
          );
          uploaded = await client.uploadBundle(
            packageName: packageName,
            editId: edit.id,
            aabPath: aabPath,
          );
          SmfError.check(
            uploaded.versionCode == nextVersionCode && uploaded.sha256 == localSha256,
            'Google Play bundle evidence does not match the signed local AAB.',
            SmfErrorCode.googlePlayBundleMismatch,
          );
        }
        final finalizedIntent = uploadIntent;
        if (finalizedIntent == null) {
          throw const SmfError(
            'Google Play release candidate creation completed without a recorded '
            'release candidate intent.',
            SmfErrorCode.releaseCandidateIntentMissing,
          );
        }
        final versionCode = uploaded.versionCode;
        final notes = await SmfState.storeReleaseNotes(paths.directory);
        for (final testingTrack in testingTracks) {
          await client.updateTrack(
            packageName: packageName,
            editId: edit.id,
            track: GooglePlayTrack(
              name: testingTrack,
              releases: <GooglePlayRelease>[
                _testingRelease(
                  state.version,
                  versionCode,
                  notes.forRelease(
                    platform: ReleasePlatform.android,
                    version: state.version,
                  ),
                ),
              ],
            ),
          );
        }
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

        final receipt = ReleaseCandidateReceiptDto(
          schemaVersion: 1,
          platform: ReleasePlatform.android,
          version: state.version,
          buildNumber: finalizedIntent.buildNumber,
          artifactId: finalizedIntent.buildNumber,
          applicationId: packageName,
          storeApplicationId: packageName,
          sourceCommitHash: finalizedIntent.sourceCommitHash,
          sourceFingerprint: finalizedIntent.sourceFingerprint,
          artifactSha256: finalizedIntent.artifactSha256,
          uploadedAt: finalizedIntent.preparedAt,
          testingDestinations: testingTracks,
          processingState: 'VALID',
        );
        await _recordReceipt(
          repositoryRoot: repositoryRoot,
          intentPath: intentPath,
          receiptPath: receiptPath,
          receipt: receipt,
          shouldCommitReceipt: options.shouldCommitReceipt,
          github: options.github,
          isRefreshed: false,
        );
        return receipt;
      } finally {
        if (!isEditCommitted) {
          await _discardEdit(client, packageName, edit.id);
        }
      }
    } finally {
      if (shouldCloseClient) client.close();
    }
  }
}
