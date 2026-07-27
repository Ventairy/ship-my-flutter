import 'package:path/path.dart' as p;
import 'package:smf_android/src/android/build.dart';
import 'package:smf_android/src/android/client.dart';
import 'package:smf_android/src/android/project.dart';
import 'package:smf_android/src/android/signing.dart';
import 'package:smf_android/src/models/android_signing_credentials.dart';
import 'package:smf_android/src/models/google_play_credentials.dart';
import 'package:smf_engine/smf_engine.dart';

/// Runs project preparation before Android candidate fingerprinting.
typedef RunAndroidBuildHook =
    Future<bool?> Function(
      String workingDirectory,
      SmfConfig config,
      Platform platform,
      String version,
    );

/// Builds one signed Android App Bundle.
typedef BuildAndroidAab =
    Future<String> Function({
      required String projectRoot,
      required String command,
      required String aabOutputPath,
      required String version,
      required String buildNumber,
      required AndroidSigningSession signing,
      required AndroidSigningCredentials credentials,
      String? flavor,
    });

/// Candidate-build operations injectable for deterministic tests.
final class AndroidCandidateDependencies {
  /// Creates Android candidate dependencies.
  const AndroidCandidateDependencies({
    this.resolvePackage = resolvePackageName,
    this.runBeforeBuild = runBeforeBuildHook,
    this.installSigning = installAndroidSigning,
    this.buildAab = _buildAab,
    this.currentTime = _currentTime,
  });

  /// Android application-ID resolver.
  final ResolvePackageName resolvePackage;

  /// Repository-owned candidate preparation.
  final RunAndroidBuildHook runBeforeBuild;

  /// Temporary upload-key installer.
  final Future<AndroidSigningSession> Function(
    AndroidSigningCredentials credentials,
  )
  installSigning;

  /// Signed AAB builder.
  final BuildAndroidAab buildAab;

  /// Receipt clock.
  final DateTime Function() currentTime;

  static Future<String> _buildAab({
    required String projectRoot,
    required String command,
    required String aabOutputPath,
    required String version,
    required String buildNumber,
    required AndroidSigningSession signing,
    required AndroidSigningCredentials credentials,
    String? flavor,
  }) => runAndroidBuildCommand(
    projectRoot: projectRoot,
    command: command,
    aabOutputPath: aabOutputPath,
    version: version,
    buildNumber: buildNumber,
    signing: signing,
    credentials: credentials,
    flavor: flavor,
  );

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

Future<void> _recordReceipt({
  required String repositoryRoot,
  required String receiptPath,
  required CandidateReceipt receipt,
  required bool commitReceipt,
  required GitHubContext? github,
  required bool refreshed,
}) async {
  await writeJson(receiptPath, receipt.toJson());
  if (!commitReceipt) return;
  try {
    await commitCandidateReceipt(
      repositoryRoot,
      receiptPath,
      Platform.android,
      receipt.version,
      github,
    );
  } on Exception catch (error) {
    final description = refreshed
        ? 'refreshed candidate receipt'
        : 'candidate receipt';
    throw SmfError(
      'The Google Play candidate is valid, but its $description could not be '
          'committed. Do not merge the release PR until this is repaired.',
      'CANDIDATE_RECEIPT_COMMIT',
      cause: error,
    );
  }
}

GooglePlayRelease _testingRelease(
  String version,
  int versionCode,
  Map<String, String> notes,
) => GooglePlayRelease(
  status: 'completed',
  versionCodes: <int>[versionCode],
  name: version,
  releaseNotes: notes,
);

Future<CandidateReceipt?> _reusableCandidate({
  required String receiptPath,
  required String fingerprint,
  required String packageName,
  required String testingTrack,
  required GooglePlayApi client,
}) async {
  if (!(await fileExists(receiptPath))) return null;
  final receipt = await loadCandidateReceipt(receiptPath);
  if (receipt.platform != Platform.android ||
      receipt.sourceFingerprint != fingerprint ||
      receipt.applicationId != packageName) {
    return null;
  }
  final versionCode = int.tryParse(receipt.artifactId);
  if (versionCode == null) return null;
  final edit = await client.createEdit(packageName);
  try {
    final bundles = await client.listBundles(packageName, edit.id);
    final bundle = bundles
        .where((item) => item.versionCode == versionCode)
        .firstOrNull;
    final track = await client.getTrack(packageName, edit.id, testingTrack);
    return bundle?.sha256 == receipt.artifactSha256 &&
            track.containsVersionCode(versionCode)
        ? receipt
        : null;
  } finally {
    await _discardEdit(client, packageName, edit.id);
  }
}

Future<void> _discardEdit(
  GooglePlayApi client,
  String packageName,
  String editId,
) async {
  try {
    await client.deleteEdit(packageName, editId);
  } on Object {
    // An abandoned Google Play edit expires automatically. Cleanup must not
    // hide the candidate result or the original failure that caused rollback.
  }
}

/// Builds, signs, uploads, and records an exact internal-testing candidate.
Future<CandidateReceipt> createAndroidCandidate(
  AndroidCandidateOptions options,
) async {
  final workingDirectory = p.normalize(p.absolute(options.workingDirectory));
  final paths = resolveSmfPaths(workingDirectory, smfPath: options.smfPath);
  final repositoryRoot = paths.repositoryRoot;
  await validateRepository(paths.directory);
  final (config, manifest) = await (
    loadConfig(paths.directory),
    loadManifest(paths.directory),
  ).wait;
  invariant(
    config.android.enabled,
    'Android delivery is disabled in configuration.',
    'ANDROID_DISABLED',
  );
  invariant(
    await currentBranch(repositoryRoot) == releaseBranchName,
    'Release-candidate creation only runs on $releaseBranchName.',
    'CANDIDATE_BRANCH',
  );
  invariant(
    await isClean(repositoryRoot),
    'The candidate checkout must be clean before repository hooks run.',
    'DIRTY_WORKTREE',
  );
  final state = manifest.android;
  invariant(
    state.pendingRelease,
    'The Android manifest does not contain a pending release.',
    'NO_PENDING_RELEASE',
  );

  final hookStartingSha = await currentSha(repositoryRoot);
  final commitHookChanges = await options.dependencies.runBeforeBuild(
    paths.directory,
    config,
    Platform.android,
    state.version,
  );
  if (commitHookChanges ?? false) {
    await commitBeforeBuildChanges(
      repositoryRoot,
      Platform.android,
      state.version,
      hookStartingSha,
      options.github,
    );
  } else {
    invariant(
      await isClean(repositoryRoot),
      'The before_build hook changed tracked or unignored files while commit '
          'is false. Commit or ignore those files in the hook.',
      'BUILD_HOOK_DIRTY_WORKTREE',
    );
  }

  final packageName = await options.dependencies.resolvePackage(
    paths.appRoot,
    config.android,
    flavor: config.flavor,
  );
  final fingerprint = await sourceFingerprint(paths.directory);
  final receiptPath = candidatePath(
    paths.directory,
    Platform.android,
    state.version,
  );
  final ownsClient = options.client == null;
  final client =
      options.client ??
      await GooglePlayClient.open(options.googlePlayCredentials);
  try {
    final reusable = await _reusableCandidate(
      receiptPath: receiptPath,
      fingerprint: fingerprint,
      packageName: packageName,
      testingTrack: config.android.googlePlay.testingTrack,
      client: client,
    );
    if (reusable != null) {
      final refreshed = reusable.copyWith(
        testingDestinations: <String>[
          config.android.googlePlay.testingTrack,
        ],
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
      final existingBundles = await client.listBundles(packageName, edit.id);
      final nextVersionCode =
          existingBundles.fold<int>(
            0,
            (maximum, bundle) =>
                bundle.versionCode > maximum ? bundle.versionCode : maximum,
          ) +
          1;
      invariant(
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
          command: await resolveAndroidBuildCommand(
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
        invariant(
          await isClean(repositoryRoot),
          'The Flutter build changed tracked or unignored repository files. '
              'Commit deterministic generated inputs before producing a '
              'candidate.',
          'BUILD_DIRTY_WORKTREE',
        );
        invariant(
          await sourceFingerprint(paths.directory) == fingerprint,
          'A tracked build input changed while producing the AAB.',
          'BUILD_INPUT_CHANGED',
        );
      } finally {
        await signing.cleanup();
      }
      final localSha256 = await fileSha256(aabPath);
      final uploaded = await client.uploadBundle(
        packageName,
        edit.id,
        aabPath,
      );
      invariant(
        uploaded.versionCode == nextVersionCode &&
            uploaded.sha256 == localSha256,
        'Google Play bundle evidence does not match the signed local AAB.',
        'GOOGLE_PLAY_BUNDLE_MISMATCH',
      );
      final notes = await loadStoreReleaseNotes(paths.directory);
      await client.updateTrack(
        packageName,
        edit.id,
        GooglePlayTrack(
          name: config.android.googlePlay.testingTrack,
          releases: <GooglePlayRelease>[
            _testingRelease(
              state.version,
              nextVersionCode,
              notes[Platform.android]?[state.version] ??
                  const <String, String>{},
            ),
          ],
        ),
      );
      await client.validateEdit(packageName, edit.id);
      await client.commitEdit(
        packageName,
        edit.id,
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
        sourceSha: await currentSha(repositoryRoot),
        sourceFingerprint: fingerprint,
        artifactSha256: localSha256,
        uploadedAt: options.dependencies.currentTime().toUtc(),
        testingDestinations: <String>[
          config.android.googlePlay.testingTrack,
        ],
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
