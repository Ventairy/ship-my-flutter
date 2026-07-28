import 'package:path/path.dart' as p;
import 'package:smf_android/src/android/build.dart';
import 'package:smf_android/src/android/client.dart';
import 'package:smf_android/src/android/project.dart';
import 'package:smf_android/src/android/signing.dart';
import 'package:smf_android/src/android/tracks.dart';
import 'package:smf_android/src/models/android_signing_credentials.dart';
import 'package:smf_android/src/models/google_play_credentials.dart';
import 'package:smf_engine/smf_engine.dart';

/// Candidate-build operations injectable for deterministic tests.
final class AndroidCandidateDependencies {
  /// Creates Android candidate dependencies.
  const AndroidCandidateDependencies({
    this.resolvePackage = AndroidProject.resolvePackageName,
    this.runBeforeBuild = RepositoryHooks.beforeBuild,
    this.installSigning = AndroidSigningSession.install,
    this.buildAab = AndroidBuild.run,
    this.currentTime = _currentTime,
  });

  /// Android application-ID resolver.
  final Future<String> Function(
    String appRoot,
    AndroidConfig config, {
    String? flavor,
  })
  resolvePackage;

  /// Repository-owned candidate preparation.
  final Future<bool> Function({required String workingDirectory}) runBeforeBuild;

  /// Temporary upload-key installer.
  final Future<AndroidSigningSession> Function(
    AndroidSigningCredentials credentials,
  )
  installSigning;

  /// Signed AAB builder.
  final Future<String> Function({
    required String projectRoot,
    required String command,
    required String aabOutputPath,
    required String version,
    required String buildNumber,
    required AndroidSigningSession signing,
    required AndroidSigningCredentials credentials,
    String? flavor,
  })
  buildAab;

  /// Receipt clock.
  final DateTime Function() currentTime;

  static DateTime _currentTime() => DateTime.now().toUtc();
}

/// Inputs for creating an Android candidate.
final class AndroidCandidateOptions {
  /// Creates Android candidate options.
  const AndroidCandidateOptions({
    required this.workingDirectory,
    required this.googlePlayCredentials,
    required this.signingCredentials,
    this.smfPath,
    this.github,
    this.commitReceipt = true,
    this.client,
    this.dependencies = const AndroidCandidateDependencies(),
  });

  /// Directory from which SMF discovers the target app.
  final String workingDirectory;

  /// Optional selected `smf` directory.
  final String? smfPath;

  /// Google Play service-account credentials.
  final GooglePlayCredentials googlePlayCredentials;

  /// Google Play upload-key credentials.
  final AndroidSigningCredentials signingCredentials;

  /// Optional GitHub context used to push candidate evidence.
  final GitHubContext? github;

  /// Whether to commit and push the receipt.
  final bool commitReceipt;

  /// Optional Google Play client override.
  final GooglePlayApi? client;

  /// Candidate operation overrides.
  final AndroidCandidateDependencies dependencies;
}

/// Creates and records exact Google Play release candidates.
final class AndroidCandidate {
  const AndroidCandidate._();

  static Future<void> _recordReceipt({
    required String repositoryRoot,
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
        repositoryRoot: repositoryRoot,
        receiptPath: receiptPath,
        platform: Platform.android,
        version: receipt.version,
        github: github,
      );
    } on Exception catch (error) {
      final description = refreshed ? 'refreshed candidate receipt' : 'candidate receipt';
      throw SmfError(
        'The Google Play candidate is valid, but its $description could not be '
            'committed. Do not merge the release PR until this is repaired.',
        'CANDIDATE_RECEIPT_COMMIT',
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

  static Future<CandidateReceipt?> _reusableCandidate({
    required String receiptPath,
    required String fingerprint,
    required String packageName,
    required List<String> testingTracks,
    required GooglePlayApi client,
  }) async {
    if (!(await SmfFileSystem.exists(receiptPath))) return null;
    final receipt = await CandidateReceipt.read(receiptPath);
    if (receipt.platform != Platform.android ||
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
      // hide the candidate result or the original failure that caused rollback.
    }
  }

  /// Builds, signs, uploads, and records an exact internal-testing candidate.
  /// Creates or reuses the exact candidate described by [options].
  static Future<CandidateReceipt> create(
    AndroidCandidateOptions options,
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
      config.android.enabled,
      'Android delivery is disabled in configuration.',
      'ANDROID_DISABLED',
    );
    SmfError.check(
      await gitClient.currentBranch() == ReleaseReference.branch(config.appId),
      'Release-candidate creation only runs on '
          '${ReleaseReference.branch(config.appId)}.',
      'CANDIDATE_BRANCH',
    );
    SmfError.check(
      await gitClient.isClean(),
      'The candidate checkout must be clean before repository hooks run.',
      'DIRTY_WORKTREE',
    );
    final state = manifest.android;
    SmfError.check(
      state.pendingRelease,
      'The Android manifest does not contain a pending release.',
      'NO_PENDING_RELEASE',
    );

    final hookStartingSha = await gitClient.currentSha();
    final hookRan = await options.dependencies.runBeforeBuild(
      workingDirectory: paths.directory,
    );
    if (hookRan) {
      await CandidateGit.commitBeforeBuildChanges(
        repositoryRoot: repositoryRoot,
        platform: Platform.android,
        version: state.version,
        startingSha: hookStartingSha,
        github: options.github,
      );
    }

    final packageName = await options.dependencies.resolvePackage(
      paths.appRoot,
      config.android,
      flavor: config.flavor,
    );
    final fingerprint = await SourceFingerprint.calculate(paths.directory);
    final receiptPath = paths.candidatePath(
      platform: Platform.android,
      version: state.version,
    );
    final ownsClient = options.client == null;
    final client = options.client ?? await GooglePlayClient.open(options.googlePlayCredentials);
    try {
      final testingTracks = GooglePlayTrackNames.releaseCandidate(
        config.android.googlePlay.releaseCandidate,
      );
      final reusable = await _reusableCandidate(
        receiptPath: receiptPath,
        fingerprint: fingerprint,
        packageName: packageName,
        testingTracks: testingTracks,
        client: client,
      );
      if (reusable != null) {
        final refreshed = reusable.copyWith(
          testingDestinations: testingTracks,
        );
        await _recordReceipt(
          repositoryRoot: repositoryRoot,
          receiptPath: receiptPath,
          receipt: refreshed,
          commitReceipt: options.commitReceipt,
          github: options.github,
          refreshed: true,
        );
        return refreshed;
      }

      final edit = await client.createEdit(packageName);
      var committed = false;
      try {
        final existingVersionCodes = await client.listArtifactVersionCodes(
          packageName: packageName,
          editId: edit.id,
        );
        final nextVersionCode =
            existingVersionCodes.fold<int>(
              0,
              (maximum, versionCode) => versionCode > maximum ? versionCode : maximum,
            ) +
            1;
        SmfError.check(
          nextVersionCode <= 2100000000,
          'Google Play versionCode has reached its supported maximum.',
          'VERSION_CODE_EXHAUSTED',
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
            'The Flutter build changed tracked or unignored repository files. '
                'Commit deterministic generated inputs before producing a '
                'candidate.',
            'BUILD_DIRTY_WORKTREE',
          );
          SmfError.check(
            await SourceFingerprint.calculate(paths.directory) == fingerprint,
            'A tracked build input changed while producing the AAB.',
            'BUILD_INPUT_CHANGED',
          );
        } finally {
          await signing.cleanup();
        }
        final localSha256 = await FileDigest.sha256(aabPath);
        final uploaded = await client.uploadBundle(
          packageName: packageName,
          editId: edit.id,
          aabPath: aabPath,
        );
        SmfError.check(
          uploaded.versionCode == nextVersionCode && uploaded.sha256 == localSha256,
          'Google Play bundle evidence does not match the signed local AAB.',
          'GOOGLE_PLAY_BUNDLE_MISMATCH',
        );
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
                  nextVersionCode,
                  notes.forRelease(
                    platform: Platform.android,
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
          changesNotSentForReview: false,
        );
        committed = true;

        final receipt = CandidateReceipt(
          platform: Platform.android,
          version: state.version,
          buildNumber: nextVersionCode.toString(),
          artifactId: nextVersionCode.toString(),
          applicationId: packageName,
          storeApplicationId: packageName,
          sourceSha: await gitClient.currentSha(),
          sourceFingerprint: fingerprint,
          artifactSha256: localSha256,
          uploadedAt: options.dependencies.currentTime().toUtc(),
          testingDestinations: testingTracks,
        );
        await _recordReceipt(
          repositoryRoot: repositoryRoot,
          receiptPath: receiptPath,
          receipt: receipt,
          commitReceipt: options.commitReceipt,
          github: options.github,
          refreshed: false,
        );
        return receipt;
      } finally {
        if (!committed) {
          await _discardEdit(client, packageName, edit.id);
        }
      }
    } finally {
      if (ownsClient) client.close();
    }
  }
}
