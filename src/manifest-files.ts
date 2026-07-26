import fs from "node:fs/promises";
import { loadChangelog, loadManifest } from "./config.js";
import { writeJson } from "./json.js";
import { candidatePath, resolveShipPaths } from "./paths.js";
import { releaseTag } from "./release-plan.js";
import { tagExists } from "./git.js";
import type { ChangelogManifest, ReleasePlan, ShipManifest } from "./types.js";

export async function applyReleasePlan(
  root: string,
  plan: ReleasePlan,
  preparedAt = new Date().toISOString(),
): Promise<void> {
  const paths = resolveShipPaths(root);
  const manifest = await loadManifest(root);
  const changelog = await loadChangelog(root);
  const releases = {
    ...changelog.platforms[plan.platform].releases,
  };
  const previousState = manifest.platforms[plan.platform];
  if (
    previousState.pendingRelease &&
    previousState.version !== plan.nextVersion &&
    !(await tagExists(root, releaseTag(plan.platform, previousState.version)))
  ) {
    delete releases[previousState.version];
    await fs.rm(candidatePath(root, plan.platform, previousState.version), {
      force: true,
    });
  }
  releases[plan.nextVersion] = {
    version: plan.nextVersion,
    preparedAt,
    baseSha: plan.baseSha,
    headSha: plan.headSha,
    changes: plan.changes,
  };

  const nextManifest: ShipManifest = {
    ...manifest,
    platforms: {
      ...manifest.platforms,
      [plan.platform]: {
        ...manifest.platforms[plan.platform],
        version: plan.nextVersion,
        pendingRelease: true,
      },
    },
  };

  const nextChangelog: ChangelogManifest = {
    ...changelog,
    platforms: {
      ...changelog.platforms,
      [plan.platform]: {
        releases,
      },
    },
  };

  await Promise.all([
    writeJson(paths.manifest, nextManifest),
    writeJson(paths.changelog, nextChangelog),
  ]);
}

export function emptyChangelog(): ChangelogManifest {
  return {
    schemaVersion: 1,
    platforms: {
      ios: {
        releases: {},
      },
    },
  };
}
