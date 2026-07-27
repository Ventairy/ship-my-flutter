import 'package:path/path.dart' as p;

import '../candidate_receipt.dart';
import '../config.dart';
import '../error.dart';
import '../fingerprint.dart';
import '../git.dart';
import '../model.dart';
import '../paths.dart';
import '../release_branch.dart';
import '../serialization.dart';
import '../validate.dart';
import 'candidate_options.dart';
import 'client.dart';
import 'upload.dart';

export 'candidate_dependencies.dart';
export 'candidate_options.dart';

Future<CandidateReceipt?> _reusableCandidate(
  String receiptPath,
  String fingerprint,
  AppStoreConnectApi client,
) async {
  if (!(await fileExists(receiptPath))) return null;
  final receipt = await loadCandidateReceipt(receiptPath);
  if (receipt.sourceFingerprint != fingerprint) return null;
  final build = await client.getBuild(receipt.buildId);
  return build.attributes.processingState == 'VALID' &&
          build.attributes.version == receipt.buildNumber
      ? receipt
      : null;
}

Future<void> _commitCandidateReceipt(
  String root,
  String receiptPath,
  String version,
  GitHubContext? github,
) async {
  await configureBotIdentity(root);
  await git(root, <String>['add', receiptPath]);
  final staged = await git(root, const <String>[
    'diff',
    '--cached',
    '--name-only',
  ]);
  if (staged.isEmpty) return;
  await git(root, <String>[
    'commit',
    '-m',
    'chore(ios): record TestFlight candidate $version',
  ]);
  final branch = await currentBranch(root);
  invariant(
    branch.isNotEmpty,
    'Candidate checkout must be on a branch.',
    'DETACHED_HEAD',
  );
  if (github == null) {
    await git(root, <String>['push', 'origin', branch]);
  } else {
    await authenticatedGit(root, <String>[
      'push',
      'origin',
      branch,
    ], github.token);
  }
}

Future<void> _commitBeforeBuildChanges(
  String root,
  String version,
  String startingSha,
  GitHubContext? github,
) async {
  await configureBotIdentity(root);
  await git(root, const <String>['add', '.']);
  final staged = await git(root, const <String>[
    'diff',
    '--cached',
    '--name-only',
  ]);
  if (staged.isNotEmpty) {
    await git(root, <String>[
      'commit',
      '-m',
      'chore(ios): apply before_build hook for $version',
    ]);
  }
  if (await currentSha(root) == startingSha) return;
  final branch = await currentBranch(root);
  invariant(
    branch.isNotEmpty,
    'Candidate checkout must be on a branch.',
    'DETACHED_HEAD',
  );
  if (github == null) {
    await git(root, <String>['push', 'origin', branch]);
  } else {
    await authenticatedGit(root, <String>[
      'push',
      'origin',
      branch,
    ], github.token);
  }
}

Future<void> _applyTestflightMetadata({
  required String root,
  required String version,
  required String appId,
  required String buildId,
  required TestflightConfig config,
  required AppStoreConnectApi client,
}) async {
  final notes = await loadStoreReleaseNotes(root);
  final localizations =
      notes[Platform.ios]?[version] ?? const <String, String>{};
  for (final entry in localizations.entries) {
    await client.setBetaBuildLocalization(buildId, entry.key, entry.value);
  }
  await client.addBuildToGroups(appId, buildId, config.groups);
}

Future<void> _recordCandidateReceipt({
  required String root,
  required String receiptPath,
  required CandidateReceipt receipt,
  required bool commitReceipt,
  required GitHubContext? github,
  required bool refreshed,
}) async {
  await writeJson(receiptPath, receipt.toJson());
  if (!commitReceipt) return;
  try {
    await _commitCandidateReceipt(root, receiptPath, receipt.version, github);
  } on Exception catch (error) {
    final description = refreshed
        ? 'refreshed candidate receipt'
        : 'candidate receipt';
    throw SmfError(
      'The TestFlight build is valid, but its $description could not be '
          'committed. Do not merge the release PR until this is repaired.',
      'CANDIDATE_RECEIPT_COMMIT',
      cause: error,
    );
  }
}

Future<CandidateReceipt> createIosCandidate(CandidateOptions options) async {
  final workingDirectory = p.normalize(p.absolute(options.workingDirectory));
  final paths = resolveSmfPaths(workingDirectory, smfPath: options.smfPath);
  final repositoryRoot = paths.repositoryRoot;
  await validateRepository(paths.directory);
  final (config, manifest) = await (
    loadConfig(paths.directory),
    loadManifest(paths.directory),
  ).wait;
  invariant(
    config.ios.enabled,
    'iOS delivery is disabled in configuration.',
    'IOS_DISABLED',
  );
  final branch = await currentBranch(repositoryRoot);
  final releaseBranch = releaseBranchName(Platform.ios);
  invariant(
    branch == releaseBranch,
    'Release-candidate creation only runs on $releaseBranch.',
    'CANDIDATE_BRANCH',
  );
  invariant(
    await isClean(repositoryRoot),
    'The candidate checkout must be clean before repository hooks run.',
    'DIRTY_WORKTREE',
  );
  final state = manifest.ios;
  invariant(
    state.pendingRelease,
    'The iOS manifest does not contain a pending release.',
    'NO_PENDING_RELEASE',
  );
  final hookStartingSha = await currentSha(repositoryRoot);
  final commitHookChanges = await options.dependencies.runBeforeBuild(
    paths.directory,
    config,
    state.version,
  );
  if (commitHookChanges == true) {
    await _commitBeforeBuildChanges(
      repositoryRoot,
      state.version,
      hookStartingSha,
      options.github,
    );
  } else {
    invariant(
      await isClean(repositoryRoot),
      'The before_build hook changed tracked or unignored files while '
          'commit is false. Commit or ignore those files in the hook.',
      'BUILD_HOOK_DIRTY_WORKTREE',
    );
  }
  final projectRoot = paths.appRoot;
  final bundleId = await options.dependencies.resolveBundleIdentifier(
    projectRoot,
    config.ios,
    flavor: config.flavor,
  );
  final client =
      options.client ?? AppStoreConnectClient(options.appleCredentials);
  final app = await client.findApp(bundleId);
  final fingerprint = await sourceFingerprint(paths.directory);
  final receiptPath = candidatePath(
    paths.directory,
    Platform.ios,
    state.version,
  );
  final reusable = await _reusableCandidate(receiptPath, fingerprint, client);
  if (reusable != null) {
    await _applyTestflightMetadata(
      root: paths.directory,
      version: state.version,
      appId: app.id,
      buildId: reusable.buildId,
      config: config.ios.testflight,
      client: client,
    );
    final refreshed = reusable.copyWith(
      testflightGroups: config.ios.testflight.groups,
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

  final buildNumber = await client.nextBuildNumber(app.id, state.version);
  final sourceSha = await currentSha(repositoryRoot);
  final signing = await options.dependencies.installSigning(
    options.signingCredentials,
    bundleId,
  );
  late final String ipaPath;
  try {
    ipaPath = await options.dependencies.buildIpa(
      projectRoot: projectRoot,
      command: await resolveIosBuildCommand(
        projectRoot,
        configuredCommand: config.ios.buildCommand,
      ),
      ipaOutputPath: config.ios.ipaOutputPath,
      version: state.version,
      buildNumber: buildNumber,
      exportOptionsPath: signing.exportOptionsPath,
      flavor: config.flavor,
    );
    invariant(
      await isClean(repositoryRoot),
      'The Flutter build changed tracked or unignored repository files. '
          'Commit deterministic generated inputs before producing a candidate.',
      'BUILD_DIRTY_WORKTREE',
    );
    invariant(
      await sourceFingerprint(paths.directory) == fingerprint,
      'A tracked build input changed while producing the IPA.',
      'BUILD_INPUT_CHANGED',
    );
    await options.dependencies.upload(ipaPath, options.appleCredentials);
  } finally {
    await signing.cleanup();
  }

  final build = await client.waitForBuild(
    app.id,
    state.version,
    buildNumber,
    config.ios.testflight.waitTimeoutMinutes,
  );
  await _applyTestflightMetadata(
    root: paths.directory,
    version: state.version,
    appId: app.id,
    buildId: build.id,
    config: config.ios.testflight,
    client: client,
  );
  final receipt = CandidateReceipt(
    version: state.version,
    buildNumber: buildNumber,
    buildId: build.id,
    appId: app.id,
    bundleId: bundleId,
    sourceSha: sourceSha,
    sourceFingerprint: fingerprint,
    ipaSha256: await fileSha256(ipaPath),
    uploadedAt: options.dependencies.currentTime().toUtc(),
    testflightGroups: config.ios.testflight.groups,
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
}
