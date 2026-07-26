import semver from "semver";
import { parseConventionalCommit, highestBump } from "./conventional.js";
import { invariant } from "./errors.js";
import { commitsBetween, currentSha, tagExists, tagSha } from "./git.js";
import type { Platform, ReleasePlan, ShipManifest } from "./types.js";

export function releaseTag(platform: Platform, version: string): string {
  return `${platform}-v${version}`;
}

export async function releaseNeedsPromotion(
  root: string,
  manifest: ShipManifest,
  platform: Platform,
): Promise<boolean> {
  const state = manifest.platforms[platform];
  if (!state.pendingRelease) return false;
  return !(await tagExists(root, releaseTag(platform, state.version)));
}

export async function createReleasePlan(
  root: string,
  manifest: ShipManifest,
  platform: Platform,
): Promise<ReleasePlan | null> {
  const state = manifest.platforms[platform];
  const currentTag = releaseTag(platform, state.version);
  const baseSha = (await tagExists(root, currentTag))
    ? await tagSha(root, currentTag)
    : state.baselineSha;
  const headSha = await currentSha(root);
  const commits = await commitsBetween(root, baseSha, headSha);
  const applicable = commits
    .map((commit) => parseConventionalCommit(commit.sha, commit.message))
    .filter((change) => change.platforms.includes(platform));
  const changes = applicable.filter(
    (change) => change.bump !== null || change.releaseAs !== undefined,
  );

  if (changes.length === 0) return null;

  const releaseAs = changes
    .map((change) => change.releaseAs)
    .filter((value): value is string => value !== undefined)
    .at(-1);
  const bump = highestBump(changes) ?? "patch";
  const nextVersion = releaseAs ?? semver.inc(state.version, bump);
  invariant(nextVersion, `Could not bump ${state.version}`, "SEMVER_BUMP");
  invariant(
    semver.gt(nextVersion, state.version),
    `Requested version ${nextVersion} must be greater than ${state.version}`,
    "SEMVER_ORDER",
  );

  return {
    platform,
    currentVersion: state.version,
    nextVersion,
    bump,
    baseSha,
    headSha,
    changes,
  };
}
