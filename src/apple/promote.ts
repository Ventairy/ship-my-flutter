import path from "node:path";
import { Octokit } from "@octokit/rest";
import { AppStoreConnectClient } from "./client.js";
import { resolveBundleId } from "./project.js";
import { loadCandidateReceipt } from "../candidate-receipt.js";
import {
  loadChangelog,
  loadConfig,
  loadManifest,
  loadStoreReleaseNotes,
} from "../config.js";
import { releaseNotesMarkdown } from "../changelog.js";
import { invariant } from "../errors.js";
import { sourceFingerprint } from "../fingerprint.js";
import { currentBranch, currentSha, isClean } from "../git.js";
import { candidatePath } from "../paths.js";
import { releaseTag } from "../release-plan.js";
import { validateRepository } from "../validate.js";
import type { AppleCredentials, GitHubContext } from "../types.js";

export interface PromotionResult {
  version: string;
  tag: string;
  buildId: string;
  appStoreVersionId?: string;
  reviewSubmissionId?: string;
  githubReleaseUrl: string;
}

export async function promoteIosRelease(options: {
  root: string;
  appleCredentials: AppleCredentials;
  github: GitHubContext;
  client?: AppStoreConnectClient;
}): Promise<PromotionResult> {
  const root = path.resolve(options.root);
  await validateRepository(root);
  const config = await loadConfig(root);
  const manifest = await loadManifest(root);
  invariant(
    config.platforms.ios.enabled,
    "iOS delivery is disabled in configuration.",
    "IOS_DISABLED",
  );
  invariant(
    (await currentBranch(root)) === config.targetBranch,
    `The promotion phase only runs on ${config.targetBranch}.`,
    "PROMOTION_BRANCH",
  );
  invariant(
    await isClean(root),
    "The promotion checkout must be clean before its source is verified.",
    "DIRTY_WORKTREE",
  );
  const state = manifest.platforms.ios;
  invariant(
    state.pendingRelease,
    "The iOS manifest does not contain a pending release.",
    "NO_PENDING_RELEASE",
  );
  const receipt = await loadCandidateReceipt(
    candidatePath(root, "ios", state.version),
  );
  invariant(
    receipt.version === state.version && receipt.platform === "ios",
    "The candidate receipt does not match the pending iOS release.",
    "CANDIDATE_MISMATCH",
  );
  const fingerprint = await sourceFingerprint(root);
  invariant(
    fingerprint === receipt.sourceFingerprint,
    "The merged source does not match the tested TestFlight candidate. Produce a new candidate before promoting this version.",
    "UNTESTED_SOURCE",
  );

  const client =
    options.client ?? new AppStoreConnectClient(options.appleCredentials);
  const bundleId = await resolveBundleId(root, config.platforms.ios);
  invariant(
    receipt.bundleId === bundleId,
    "The candidate receipt bundle identifier does not match the current iOS configuration.",
    "CANDIDATE_BUNDLE_MISMATCH",
  );
  const app = await client.findApp(bundleId);
  invariant(
    receipt.appId === app.id,
    "The candidate receipt App Store app does not match the configured bundle identifier.",
    "CANDIDATE_APP_MISMATCH",
  );
  const versionBuilds = await client.buildsForVersion(app.id, state.version);
  const build = versionBuilds.find((item) => item.id === receipt.buildId);
  invariant(
    build?.attributes.processingState === "VALID" &&
      build.attributes.version === receipt.buildNumber,
    "The recorded Apple build is not a valid build for the configured app and marketing version.",
    "CANDIDATE_INVALID",
  );

  let appStoreVersionId: string | undefined;
  let reviewSubmissionId: string | undefined;
  if (config.platforms.ios.appStore.mode === "submit-for-review") {
    const appStoreVersion = await client.findOrCreateAppStoreVersion(
      app.id,
      state.version,
      config.platforms.ios.appStore.releaseType,
      config.platforms.ios.appStore.earliestReleaseDate,
    );
    appStoreVersionId = appStoreVersion.id;
    if (appStoreVersion.attributes.appStoreState === "PREPARE_FOR_SUBMISSION") {
      await client.attachBuildToVersion(appStoreVersion.id, receipt.buildId);
      const notes = await loadStoreReleaseNotes(root);
      for (const [locale, whatsNew] of Object.entries(
        notes.ios[state.version] ?? {},
      )) {
        await client.setAppStoreReleaseNotes(
          appStoreVersion.id,
          locale,
          whatsNew,
        );
      }
    }
    invariant(
      (await client.appStoreVersionBuildId(appStoreVersion.id)) ===
        receipt.buildId,
      "The App Store version is not attached to the exact tested candidate build.",
      "APP_STORE_BUILD_MISMATCH",
    );
    reviewSubmissionId = await client.submitVersionForReview(
      app.id,
      appStoreVersion.id,
    );
  }

  const changelog = await loadChangelog(root);
  const release = changelog.platforms.ios.releases[state.version];
  invariant(release, `Missing changelog for iOS ${state.version}`);
  const tag = releaseTag("ios", state.version);
  const octokit = new Octokit({ auth: options.github.token });
  const existing = await octokit.repos
    .getReleaseByTag({
      owner: options.github.owner,
      repo: options.github.repo,
      tag,
    })
    .catch((error: unknown) => {
      if (
        typeof error === "object" &&
        error !== null &&
        "status" in error &&
        error.status === 404
      ) {
        return undefined;
      }
      throw error;
    });
  const githubRelease =
    existing?.data ??
    (
      await octokit.repos.createRelease({
        owner: options.github.owner,
        repo: options.github.repo,
        tag_name: tag,
        target_commitish: await currentSha(root),
        name: `iOS v${state.version}`,
        body: releaseNotesMarkdown("ios", release),
        draft: false,
        prerelease: false,
      })
    ).data;

  return {
    version: state.version,
    tag,
    buildId: receipt.buildId,
    ...(appStoreVersionId ? { appStoreVersionId } : {}),
    ...(reviewSubmissionId ? { reviewSubmissionId } : {}),
    githubReleaseUrl: githubRelease.html_url,
  };
}
