import path from "node:path";
import { AppStoreConnectClient } from "./client.js";
import { resolveBundleId } from "./project.js";
import {
  buildFlutterIpa,
  prepareFlutterDependencies,
  uploadIpa,
} from "./upload.js";
import { installSigningAssets } from "./signing.js";
import { loadCandidateReceipt } from "../candidate-receipt.js";
import { loadConfig, loadManifest, loadStoreReleaseNotes } from "../config.js";
import { ShipError, invariant } from "../errors.js";
import { fileSha256, sourceFingerprint } from "../fingerprint.js";
import {
  authenticatedGit,
  configureBotIdentity,
  currentBranch,
  currentSha,
  git,
  isClean,
} from "../git.js";
import { fileExists, writeJson } from "../json.js";
import { candidatePath } from "../paths.js";
import { validateRepository } from "../validate.js";
import type {
  AppleCredentials,
  CandidateReceipt,
  GitHubContext,
  SigningCredentials,
} from "../types.js";

export interface CandidateOptions {
  root: string;
  appleCredentials: AppleCredentials;
  signingCredentials: SigningCredentials;
  github?: GitHubContext;
  commitReceipt?: boolean;
  client?: AppStoreConnectClient;
}

async function reusableCandidate(
  receiptPath: string,
  fingerprint: string,
  client: AppStoreConnectClient,
): Promise<CandidateReceipt | undefined> {
  if (!(await fileExists(receiptPath))) return undefined;
  const receipt = await loadCandidateReceipt(receiptPath);
  if (receipt.sourceFingerprint !== fingerprint) return undefined;
  const build = await client.request<{
    data: { attributes: { processingState: string; version: string } };
  }>("GET", `/v1/builds/${receipt.buildId}`);
  if (
    build.data.attributes.processingState === "VALID" &&
    build.data.attributes.version === receipt.buildNumber
  ) {
    return receipt;
  }
  return undefined;
}

async function commitCandidateReceipt(
  root: string,
  receiptPath: string,
  version: string,
  github?: GitHubContext,
): Promise<void> {
  await configureBotIdentity(root);
  await git(root, ["add", receiptPath]);
  if (!(await git(root, ["diff", "--cached", "--name-only"]))) return;
  await git(root, [
    "commit",
    "-m",
    `chore(ios): record TestFlight candidate ${version}`,
  ]);
  const branch = await currentBranch(root);
  invariant(branch, "Candidate checkout must be on a branch.", "DETACHED_HEAD");
  if (github) {
    await authenticatedGit(root, ["push", "origin", branch], github.token);
  } else {
    await git(root, ["push", "origin", branch]);
  }
}

export async function createIosCandidate(
  options: CandidateOptions,
): Promise<CandidateReceipt> {
  const root = path.resolve(options.root);
  await validateRepository(root);
  const config = await loadConfig(root);
  const manifest = await loadManifest(root);
  invariant(
    config.platforms.ios.enabled,
    "iOS delivery is disabled in configuration.",
    "IOS_DISABLED",
  );
  const branch = await currentBranch(root);
  invariant(
    branch === `${config.releaseBranchPrefix}/ios`,
    `The candidate phase only runs on ${config.releaseBranchPrefix}/ios.`,
    "CANDIDATE_BRANCH",
  );
  invariant(
    await isClean(root),
    "The candidate checkout must be clean before its source is fingerprinted.",
    "DIRTY_WORKTREE",
  );
  const state = manifest.platforms.ios;
  invariant(
    state.pendingRelease,
    "The iOS manifest does not contain a pending release.",
    "NO_PENDING_RELEASE",
  );
  const projectRoot = path.resolve(root, config.platforms.ios.projectPath);
  const bundleId = await resolveBundleId(root, config.platforms.ios);
  const client =
    options.client ?? new AppStoreConnectClient(options.appleCredentials);
  const app = await client.findApp(bundleId);
  const fingerprint = await sourceFingerprint(root);
  const receiptPath = candidatePath(root, "ios", state.version);
  const reusable = await reusableCandidate(receiptPath, fingerprint, client);
  if (reusable) {
    const notes = await loadStoreReleaseNotes(root);
    for (const [locale, whatsNew] of Object.entries(
      notes.ios[state.version] ?? {},
    )) {
      await client.setBetaBuildLocalization(reusable.buildId, locale, whatsNew);
    }
    await client.addBuildToGroups(
      app.id,
      reusable.buildId,
      config.platforms.ios.testflight.groups,
    );
    const refreshed: CandidateReceipt = {
      ...reusable,
      testflightGroups: config.platforms.ios.testflight.groups,
    };
    await writeJson(receiptPath, refreshed);
    if (options.commitReceipt ?? true) {
      try {
        await commitCandidateReceipt(
          root,
          receiptPath,
          state.version,
          options.github,
        );
      } catch (error) {
        throw new ShipError(
          "The TestFlight build is valid, but its refreshed candidate receipt could not be committed. Do not merge the release PR until this is repaired.",
          "CANDIDATE_RECEIPT_COMMIT",
          { cause: error },
        );
      }
    }
    return refreshed;
  }

  await prepareFlutterDependencies(projectRoot);
  invariant(
    await isClean(root),
    "Dependency resolution changed tracked or unignored repository files. Commit a current lockfile before producing a candidate.",
    "DEPENDENCIES_DIRTY_WORKTREE",
  );
  invariant(
    (await sourceFingerprint(root)) === fingerprint,
    "A tracked build input changed while validating dependencies.",
    "DEPENDENCY_INPUT_CHANGED",
  );

  const buildNumber = await client.nextBuildNumber(app.id, state.version);
  const sourceSha = await currentSha(root);
  const signing = await installSigningAssets(
    options.signingCredentials,
    bundleId,
  );
  let ipaPath: string;
  try {
    ipaPath = await buildFlutterIpa({
      projectRoot,
      version: state.version,
      buildNumber,
      exportOptionsPath: signing.exportOptionsPath,
      ...(config.platforms.ios.scheme
        ? { scheme: config.platforms.ios.scheme }
        : {}),
      buildArgs: config.platforms.ios.buildArgs,
    });
    invariant(
      await isClean(root),
      "The Flutter build changed tracked or unignored repository files. Commit deterministic generated inputs before producing a candidate.",
      "BUILD_DIRTY_WORKTREE",
    );
    invariant(
      (await sourceFingerprint(root)) === fingerprint,
      "A tracked build input changed while producing the IPA.",
      "BUILD_INPUT_CHANGED",
    );
    await uploadIpa(ipaPath, options.appleCredentials);
  } finally {
    await signing.cleanup();
  }

  const build = await client.waitForBuild(
    app.id,
    state.version,
    buildNumber,
    config.platforms.ios.testflight.waitTimeoutMinutes,
  );
  const notes = await loadStoreReleaseNotes(root);
  for (const [locale, whatsNew] of Object.entries(
    notes.ios[state.version] ?? {},
  )) {
    await client.setBetaBuildLocalization(build.id, locale, whatsNew);
  }
  await client.addBuildToGroups(
    app.id,
    build.id,
    config.platforms.ios.testflight.groups,
  );

  const receipt: CandidateReceipt = {
    schemaVersion: 1,
    platform: "ios",
    version: state.version,
    buildNumber,
    buildId: build.id,
    appId: app.id,
    bundleId,
    sourceSha,
    sourceFingerprint: fingerprint,
    ipaSha256: await fileSha256(ipaPath),
    uploadedAt: new Date().toISOString(),
    processingState: "VALID",
    testflightGroups: config.platforms.ios.testflight.groups,
  };
  await writeJson(receiptPath, receipt);
  if (options.commitReceipt ?? true) {
    try {
      await commitCandidateReceipt(
        root,
        receiptPath,
        state.version,
        options.github,
      );
    } catch (error) {
      throw new ShipError(
        "The TestFlight build is valid, but its candidate receipt could not be committed. Do not merge the release PR until this is repaired.",
        "CANDIDATE_RECEIPT_COMMIT",
        { cause: error },
      );
    }
  }
  return receipt;
}
