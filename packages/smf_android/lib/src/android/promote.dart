import 'package:path/path.dart' as p;
import 'package:smf_android/src/android/client.dart';
import 'package:smf_android/src/android/project.dart';
import 'package:smf_android/src/models/google_play_credentials.dart';
import 'package:smf_engine/smf_engine.dart';

/// Stable machine-readable Android promotion evidence.
final class AndroidPromotionResult {
  /// Creates promotion evidence.
  const AndroidPromotionResult({
    required this.version,
    required this.tag,
    required this.versionCode,
    required this.testingTrack,
    required this.githubReleaseUrl,
    this.productionTrack,
  });

  /// Promoted marketing version.
  final String version;

  /// Git tag created for this Android release.
  final String tag;

  /// Exact Google Play version code.
  final int versionCode;

  /// Testing track that contained the candidate.
  final String testingTrack;

  /// Production track updated by this promotion, if any.
  final String? productionTrack;

  /// GitHub release URL.
  final String githubReleaseUrl;

  /// Encodes the CLI result.
  Map<String, Object?> toJson() => <String, Object?>{
    'platform': Platform.android.value,
    'version': version,
    'tag': tag,
    'artifactId': versionCode.toString(),
    'buildNumber': versionCode.toString(),
    'testingTrack': testingTrack,
    'productionTrack': ?productionTrack,
    'githubReleaseUrl': githubReleaseUrl,
  };
}

/// Inputs for promoting an exact Android candidate.
final class AndroidPromotionOptions {
  /// Creates Android promotion options.
  const AndroidPromotionOptions({
    required this.workingDirectory,
    required this.googlePlayCredentials,
    required this.github,
    this.smfPath,
    this.client,
    this.githubApi,
    this.resolvePackage = resolvePackageName,
  });

  /// Directory from which SMF discovers the target app.
  final String workingDirectory;

  /// Optional selected `smf` directory.
  final String? smfPath;

  /// Google Play service-account credentials.
  final GooglePlayCredentials googlePlayCredentials;

  /// GitHub repository and authentication context.
  final GitHubContext github;

  /// Optional Google Play client override.
  final GooglePlayApi? client;

  /// Optional GitHub API override.
  final GitHubApi? githubApi;

  /// Android application-ID resolver.
  final ResolvePackageName resolvePackage;
}

/// Verifies and promotes the exact internal-testing AAB without rebuilding.
Future<AndroidPromotionResult> promoteAndroidRelease(
  AndroidPromotionOptions options,
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
    await currentBranch(repositoryRoot) == config.targetBranch,
    'Shipping only runs on ${config.targetBranch}.',
    'PROMOTION_BRANCH',
  );
  invariant(
    await isClean(repositoryRoot),
    'The promotion checkout must be clean before its source is verified.',
    'DIRTY_WORKTREE',
  );
  final state = manifest.android;
  invariant(
    state.pendingRelease,
    'The Android manifest does not contain a pending release.',
    'NO_PENDING_RELEASE',
  );
  final receipt = await loadCandidateReceipt(
    candidatePath(paths.directory, Platform.android, state.version),
  );
  invariant(
    receipt.version == state.version && receipt.platform == Platform.android,
    'The candidate receipt does not match the pending Android release.',
    'CANDIDATE_MISMATCH',
  );
  invariant(
    await sourceFingerprint(paths.directory) == receipt.sourceFingerprint,
    'The merged source does not match the tested Google Play candidate. '
        'Produce a new candidate before promoting this version.',
    'UNTESTED_SOURCE',
  );
  final packageName = await options.resolvePackage(
    paths.appRoot,
    config.android,
    flavor: config.flavor,
  );
  invariant(
    receipt.applicationId == packageName &&
        receipt.storeApplicationId == packageName,
    'The candidate receipt package name does not match the configured Android '
        'application.',
    'CANDIDATE_PACKAGE_MISMATCH',
  );
  final versionCode = int.tryParse(receipt.artifactId);
  if (versionCode == null ||
      receipt.buildNumber != receipt.artifactId ||
      versionCode <= 0) {
    throw const SmfError(
      'The candidate receipt does not contain a valid Google Play versionCode.',
      'CANDIDATE_MISMATCH',
    );
  }

  final ownsClient = options.client == null;
  final client =
      options.client ??
      await GooglePlayClient.open(options.googlePlayCredentials);
  String? promotedTrack;
  try {
    final edit = await client.createEdit(packageName);
    var committed = false;
    try {
      final bundles = await client.listBundles(packageName, edit.id);
      final bundle = bundles
          .where((item) => item.versionCode == versionCode)
          .firstOrNull;
      invariant(
        bundle?.sha256 == receipt.artifactSha256,
        'The recorded Android App Bundle is not available with the exact '
            'candidate SHA-256.',
        'CANDIDATE_INVALID',
      );
      final testingTrack = await client.getTrack(
        packageName,
        edit.id,
        config.android.googlePlay.testingTrack,
      );
      invariant(
        testingTrack.containsVersionCode(versionCode),
        'The exact candidate versionCode is not on the configured Google Play '
            'testing track.',
        'CANDIDATE_NOT_TESTING',
      );

      if (config.android.googlePlay.mode != ReleaseMode.upload) {
        final production = await client.getTrack(
          packageName,
          edit.id,
          config.android.googlePlay.productionTrack,
        );
        if (!production.containsVersionCode(versionCode)) {
          invariant(
            production.releases.every(
              (release) => release.status == 'completed',
            ),
            'The Google Play production track has an unfinished release. '
                'Finish or halt it in Play Console before SMF replaces the '
                'track.',
            'GOOGLE_PLAY_RELEASE_IN_PROGRESS',
          );
          final notes = await loadStoreReleaseNotes(paths.directory);
          await client.updateTrack(
            packageName,
            edit.id,
            GooglePlayTrack(
              name: config.android.googlePlay.productionTrack,
              releases: <GooglePlayRelease>[
                GooglePlayRelease(
                  status: 'completed',
                  versionCodes: <int>[versionCode],
                  name: state.version,
                  releaseNotes:
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
        }
        promotedTrack = config.android.googlePlay.productionTrack;
      }
    } finally {
      if (!committed) {
        try {
          await client.deleteEdit(packageName, edit.id);
        } on Object {
          // An abandoned Google Play edit expires automatically. Cleanup must
          // not hide the promotion result or its original failure.
        }
      }
    }
  } finally {
    if (ownsClient) client.close();
  }

  final changelog = await loadChangelog(paths.directory);
  final release = changelog.androidReleases[state.version];
  if (release == null) {
    throw SmfError(
      'Missing changelog for Android ${state.version}',
      'MISSING_CHANGELOG',
    );
  }
  final tag = releaseTag(Platform.android, state.version);
  final githubApi = options.githubApi ?? GitHubRestApi(context: options.github);
  final githubRelease =
      await githubApi.releaseByTag(tag) ??
      await githubApi.createRelease(
        tag: tag,
        targetCommitish: await currentSha(repositoryRoot),
        name: 'Android v${state.version}',
        body: releaseNotesMarkdown(Platform.android, release),
      );
  return AndroidPromotionResult(
    version: state.version,
    tag: tag,
    versionCode: versionCode,
    testingTrack: config.android.googlePlay.testingTrack,
    productionTrack: promotedTrack,
    githubReleaseUrl: githubRelease.htmlUrl,
  );
}
