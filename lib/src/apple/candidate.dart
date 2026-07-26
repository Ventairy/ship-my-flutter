import 'package:path/path.dart' as p;

import '../candidate_receipt.dart';
import '../config.dart';
import '../error.dart';
import '../fingerprint.dart';
import '../git.dart';
import '../model.dart';
import '../paths.dart';
import '../serialization.dart';
import '../validate.dart';
import 'client.dart';
import 'project.dart';
import 'signing.dart';
import 'upload.dart';

typedef InstallSigningAssets =
    Future<SigningSession> Function(
      SigningCredentials credentials,
      String bundleId,
    );
typedef PrepareFlutterDependencies = Future<void> Function(String projectRoot);
typedef BuildFlutterIpa =
    Future<String> Function({
      required String projectRoot,
      required String version,
      required String buildNumber,
      required String exportOptionsPath,
      String? scheme,
      required List<String> buildArgs,
    });
typedef UploadIpa =
    Future<void> Function(String ipaPath, AppleCredentials credentials);

final class CandidateDependencies {
  const CandidateDependencies({
    this.installSigning = installSigningAssets,
    this.prepareDependencies = prepareFlutterDependencies,
    this.buildIpa = buildFlutterIpa,
    this.upload = uploadIpa,
    this.resolveBundleIdentifier = resolveBundleId,
  });

  final InstallSigningAssets installSigning;
  final PrepareFlutterDependencies prepareDependencies;
  final BuildFlutterIpa buildIpa;
  final UploadIpa upload;
  final ResolveBundleId resolveBundleIdentifier;
}

final class CandidateOptions {
  const CandidateOptions({
    required this.root,
    required this.appleCredentials,
    required this.signingCredentials,
    this.github,
    this.commitReceipt = true,
    this.client,
    this.dependencies = const CandidateDependencies(),
  });

  final String root;
  final AppleCredentials appleCredentials;
  final SigningCredentials signingCredentials;
  final GitHubContext? github;
  final bool commitReceipt;
  final AppStoreConnectApi? client;
  final CandidateDependencies dependencies;
}

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

Future<CandidateReceipt> createIosCandidate(CandidateOptions options) async {
  final root = p.normalize(p.absolute(options.root));
  await validateRepository(root);
  final (config, manifest) = await (loadConfig(root), loadManifest(root)).wait;
  invariant(
    config.ios.enabled,
    'iOS delivery is disabled in configuration.',
    'IOS_DISABLED',
  );
  final branch = await currentBranch(root);
  invariant(
    branch == '${config.releaseBranchPrefix}/ios',
    'The candidate phase only runs on ${config.releaseBranchPrefix}/ios.',
    'CANDIDATE_BRANCH',
  );
  invariant(
    await isClean(root),
    'The candidate checkout must be clean before its source is fingerprinted.',
    'DIRTY_WORKTREE',
  );
  final state = manifest.ios;
  invariant(
    state.pendingRelease,
    'The iOS manifest does not contain a pending release.',
    'NO_PENDING_RELEASE',
  );
  final projectRoot = p.normalize(p.absolute(root, config.ios.projectPath));
  final bundleId = await options.dependencies.resolveBundleIdentifier(
    root,
    config.ios,
  );
  final client =
      options.client ?? AppStoreConnectClient(options.appleCredentials);
  final app = await client.findApp(bundleId);
  final fingerprint = await sourceFingerprint(root);
  final receiptPath = candidatePath(root, Platform.ios, state.version);
  final reusable = await _reusableCandidate(receiptPath, fingerprint, client);
  if (reusable != null) {
    final notes = await loadStoreReleaseNotes(root);
    for (final entry
        in (notes[Platform.ios]?[state.version] ?? const <String, String>{})
            .entries) {
      await client.setBetaBuildLocalization(
        reusable.buildId,
        entry.key,
        entry.value,
      );
    }
    await client.addBuildToGroups(
      app.id,
      reusable.buildId,
      config.ios.testflight.groups,
    );
    final refreshed = CandidateReceipt(
      version: reusable.version,
      buildNumber: reusable.buildNumber,
      buildId: reusable.buildId,
      appId: reusable.appId,
      bundleId: reusable.bundleId,
      sourceSha: reusable.sourceSha,
      sourceFingerprint: reusable.sourceFingerprint,
      ipaSha256: reusable.ipaSha256,
      uploadedAt: reusable.uploadedAt,
      testflightGroups: config.ios.testflight.groups,
    );
    await writeJson(receiptPath, refreshed.toJson());
    if (options.commitReceipt) {
      try {
        await _commitCandidateReceipt(
          root,
          receiptPath,
          state.version,
          options.github,
        );
      } on Object catch (error) {
        throw ShipError(
          'The TestFlight build is valid, but its refreshed candidate receipt '
              'could not be committed. Do not merge the release PR until this is '
              'repaired.',
          'CANDIDATE_RECEIPT_COMMIT',
          cause: error,
        );
      }
    }
    return refreshed;
  }

  await options.dependencies.prepareDependencies(projectRoot);
  invariant(
    await isClean(root),
    'Dependency resolution changed tracked or unignored repository files. '
        'Commit a current lockfile before producing a candidate.',
    'DEPENDENCIES_DIRTY_WORKTREE',
  );
  invariant(
    await sourceFingerprint(root) == fingerprint,
    'A tracked build input changed while validating dependencies.',
    'DEPENDENCY_INPUT_CHANGED',
  );

  final buildNumber = await client.nextBuildNumber(app.id, state.version);
  final sourceSha = await currentSha(root);
  final signing = await options.dependencies.installSigning(
    options.signingCredentials,
    bundleId,
  );
  late final String ipaPath;
  try {
    ipaPath = await options.dependencies.buildIpa(
      projectRoot: projectRoot,
      version: state.version,
      buildNumber: buildNumber,
      exportOptionsPath: signing.exportOptionsPath,
      scheme: config.ios.scheme,
      buildArgs: config.ios.buildArgs,
    );
    invariant(
      await isClean(root),
      'The Flutter build changed tracked or unignored repository files. '
          'Commit deterministic generated inputs before producing a candidate.',
      'BUILD_DIRTY_WORKTREE',
    );
    invariant(
      await sourceFingerprint(root) == fingerprint,
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
  final notes = await loadStoreReleaseNotes(root);
  for (final entry
      in (notes[Platform.ios]?[state.version] ?? const <String, String>{})
          .entries) {
    await client.setBetaBuildLocalization(build.id, entry.key, entry.value);
  }
  await client.addBuildToGroups(app.id, build.id, config.ios.testflight.groups);
  final receipt = CandidateReceipt(
    version: state.version,
    buildNumber: buildNumber,
    buildId: build.id,
    appId: app.id,
    bundleId: bundleId,
    sourceSha: sourceSha,
    sourceFingerprint: fingerprint,
    ipaSha256: await fileSha256(ipaPath),
    uploadedAt: DateTime.now().toUtc(),
    testflightGroups: config.ios.testflight.groups,
  );
  await writeJson(receiptPath, receipt.toJson());
  if (options.commitReceipt) {
    try {
      await _commitCandidateReceipt(
        root,
        receiptPath,
        state.version,
        options.github,
      );
    } on Object catch (error) {
      throw ShipError(
        'The TestFlight build is valid, but its candidate receipt could not be '
            'committed. Do not merge the release PR until this is repaired.',
        'CANDIDATE_RECEIPT_COMMIT',
        cause: error,
      );
    }
  }
  return receipt;
}
