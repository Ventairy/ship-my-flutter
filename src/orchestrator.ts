import { loadConfig, loadManifest } from "./config.js";
import { currentBranch } from "./git.js";
import { createOrUpdateReleasePullRequest } from "./github.js";
import { createReleasePlan, releaseNeedsPromotion } from "./release-plan.js";
import { validateRepository } from "./validate.js";
import type { CommandResult, GitHubContext } from "./types.js";

export async function planGitHubRelease(options: {
  root: string;
  github: GitHubContext;
}): Promise<CommandResult> {
  const config = await loadConfig(options.root);
  const manifest = await loadManifest(options.root);
  if (!config.platforms.ios.enabled) return { phase: "noop" };
  const branch = await currentBranch(options.root);
  const releaseBranch = `${config.releaseBranchPrefix}/ios`;
  if (branch !== releaseBranch && branch !== config.targetBranch) {
    return { phase: "noop" };
  }
  await validateRepository(options.root);
  if (branch === releaseBranch) {
    const state = manifest.platforms.ios;
    return state.pendingRelease &&
      (await releaseNeedsPromotion(options.root, manifest, "ios"))
      ? {
          phase: "candidate",
          platform: "ios",
          version: state.version,
          branch: releaseBranch,
        }
      : { phase: "noop" };
  }

  if (await releaseNeedsPromotion(options.root, manifest, "ios")) {
    return {
      phase: "promote",
      platform: "ios",
      version: manifest.platforms.ios.version,
    };
  }

  const plan = await createReleasePlan(options.root, manifest, "ios");
  if (!plan) return { phase: "noop" };
  const pull = await createOrUpdateReleasePullRequest(
    options.root,
    config,
    plan,
    options.github,
  );
  return {
    phase: "candidate",
    platform: "ios",
    version: plan.nextVersion,
    branch: pull.branch,
    pullRequestNumber: pull.pullRequestNumber,
  };
}
