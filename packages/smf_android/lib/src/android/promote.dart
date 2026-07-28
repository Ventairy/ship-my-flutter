import 'package:path/path.dart' as p;
import 'package:smf_android/src/android/client.dart';
import 'package:smf_android/src/android/project.dart';
import 'package:smf_android/src/android/tracks.dart';
import 'package:smf_android/src/models/google_play_credentials.dart';
import 'package:smf_engine/smf_engine.dart';

/// Stable machine-readable Android promotion evidence.
final class AndroidPromotionResult {
  /// Creates promotion evidence.
  AndroidPromotionResult({
    required this.version,
    required this.tag,
    required this.versionCode,
    required this.testingTrack,
    required this.githubReleaseUrl,
    List<String> testingTracks = const <String>[],
    List<String> shippedTracks = const <String>[],
    this.productionTrack,
  }) : testingTracks = List<String>.unmodifiable(testingTracks),
       shippedTracks = List<String>.unmodifiable(shippedTracks);

  /// Promoted marketing version.
  final String version;

  /// Git tag created for this Android release.
  final String tag;

  /// Exact Google Play version code.
  final int versionCode;

  /// Testing track that contained the candidate.
  final String testingTrack;

  /// Every testing track that contained the candidate.
  final List<String> testingTracks;

  /// Every track updated during the ship phase.
  final List<String> shippedTracks;

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
    'testingTracks': testingTracks,
    'shippedTracks': shippedTracks,
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
    this.resolvePackage = AndroidProject.resolvePackageName,
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
  final Future<String> Function(
    String appRoot,
    AndroidConfig config, {
    String? flavor,
  })
  resolvePackage;
}

/// Promotes exact tested Google Play candidates without rebuilding.
final class AndroidRelease {
  const AndroidRelease._();

  /// Verifies and promotes the exact candidate described by [options].
  static Future<AndroidPromotionResult> promote(
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
      config.android.enabled,
      'Android delivery is disabled in configuration.',
      'ANDROID_DISABLED',
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
    final state = manifest.android;
    SmfError.check(
      state.pendingRelease,
      'The Android manifest does not contain a pending release.',
      'NO_PENDING_RELEASE',
    );
    final receipt = await CandidateReceipt.read(
      paths.candidatePath(
        platform: Platform.android,
        version: state.version,
      ),
    );
    SmfError.check(
      receipt.version == state.version && receipt.platform == Platform.android,
      'The candidate receipt does not match the pending Android release.',
      'CANDIDATE_MISMATCH',
    );
    SmfError.check(
      await SourceFingerprint.calculate(paths.directory) == receipt.sourceFingerprint,
      'The merged source does not match the tested Google Play candidate. '
          'Produce a new candidate before promoting this version.',
      'UNTESTED_SOURCE',
    );
    final packageName = await options.resolvePackage(
      paths.appRoot,
      config.android,
      flavor: config.flavor,
    );
    SmfError.check(
      receipt.applicationId == packageName && receipt.storeApplicationId == packageName,
      'The candidate receipt package name does not match the configured Android '
          'application.',
      'CANDIDATE_PACKAGE_MISMATCH',
    );
    final versionCode = int.tryParse(receipt.artifactId);
    if (versionCode == null || receipt.buildNumber != receipt.artifactId || versionCode <= 0) {
      throw const SmfError(
        'The candidate receipt does not contain a valid Google Play versionCode.',
        'CANDIDATE_MISMATCH',
      );
    }

    final ownsClient = options.client == null;
    final client = options.client ?? await GooglePlayClient.open(options.googlePlayCredentials);
    final testingTracks = GooglePlayTrackNames.releaseCandidate(
      config.android.googlePlay.releaseCandidate,
    );
    final configuredShip = config.android.googlePlay.ship;
    final shipTracks = configuredShip == null ? const <String>[] : GooglePlayTrackNames.ship(configuredShip);
    final promotedTracks = <String>[];
    try {
      final edit = await client.createEdit(packageName);
      var committed = false;
      try {
        final bundles = await client.listBundles(
          packageName: packageName,
          editId: edit.id,
        );
        final bundle = bundles.where((item) => item.versionCode == versionCode).firstOrNull;
        SmfError.check(
          bundle?.sha256 == receipt.artifactSha256,
          'The recorded Android App Bundle is not available with the exact '
              'candidate SHA-256.',
          'CANDIDATE_INVALID',
        );
        for (final testingTrackName in testingTracks) {
          final testingTrack = await client.getTrack(
            packageName: packageName,
            editId: edit.id,
            track: testingTrackName,
          );
          SmfError.check(
            testingTrack.containsCompletedVersionCode(versionCode),
            'The exact candidate versionCode is not on configured Google Play '
                'testing track "$testingTrackName" as a completed release.',
            'CANDIDATE_NOT_TESTING',
          );
        }

        var changed = false;
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
              'Google Play track "$shipTrackName" contains the candidate in '
                  '${existingRelease.status.value} state, not as a completed '
                  'release.',
              'GOOGLE_PLAY_RELEASE_IN_PROGRESS',
            );
          } else {
            SmfError.check(
              destination.releases.every(
                (release) => release.status == GooglePlayReleaseStatus.completed,
              ),
              'Google Play track "$shipTrackName" has an unfinished release. '
                  'Finish or halt it in Play Console before SMF replaces it.',
              'GOOGLE_PLAY_RELEASE_IN_PROGRESS',
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
                      platform: Platform.android,
                      version: state.version,
                    ),
                  ),
                ],
              ),
            );
            changed = true;
          }
          promotedTracks.add(shipTrackName);
        }
        if (changed) {
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
        }
      } finally {
        if (!committed) {
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
      if (ownsClient) client.close();
    }

    final changelog = await SmfState.changelog(paths.directory);
    final release = changelog.androidReleases[state.version];
    if (release == null) {
      throw SmfError(
        'Missing changelog for Android ${state.version}',
        'MISSING_CHANGELOG',
      );
    }
    final tag = ReleaseReference.tag(
      config.appId,
      Platform.android,
      state.version,
    );
    GitHubRestApi? ownedGitHubApi;
    final githubApi = options.githubApi ?? (ownedGitHubApi = GitHubRestApi(context: options.github));
    try {
      final githubRelease =
          await githubApi.releaseByTag(tag) ??
          await githubApi.createRelease(
            tag: tag,
            targetCommitish: await gitClient.currentSha(),
            name: '${config.appId} Android v${state.version}',
            body: ReleaseChangelog.markdown(
              platform: Platform.android,
              release: release,
            ),
          );
      return AndroidPromotionResult(
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
