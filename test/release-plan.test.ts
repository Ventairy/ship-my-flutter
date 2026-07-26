import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import { git } from "../src/git.js";
import {
  createReleasePlan,
  releaseNeedsPromotion,
  releaseTag,
} from "../src/release-plan.js";
import type { ShipManifest } from "../src/types.js";

const temporaryDirectories: string[] = [];

async function repository(): Promise<{
  root: string;
  baselineSha: string;
}> {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "smf-plan-"));
  temporaryDirectories.push(root);
  await git(root, ["init", "-b", "main"]);
  await git(root, ["config", "user.name", "Test"]);
  await git(root, ["config", "user.email", "test@example.com"]);
  await fs.writeFile(path.join(root, "app.txt"), "baseline\n");
  await git(root, ["add", "."]);
  await git(root, ["commit", "-m", "chore: bootstrap"]);
  return { root, baselineSha: await git(root, ["rev-parse", "HEAD"]) };
}

async function commit(
  root: string,
  message: string,
  content: string,
): Promise<void> {
  await fs.writeFile(path.join(root, "app.txt"), content);
  await git(root, ["add", "."]);
  await git(root, ["commit", "-m", message]);
}

afterEach(async () => {
  await Promise.all(
    temporaryDirectories
      .splice(0)
      .map((directory) => fs.rm(directory, { recursive: true, force: true })),
  );
});

describe("release planning", () => {
  it("bumps iOS independently and excludes Android-only changes", async () => {
    const { root, baselineSha } = await repository();
    await commit(root, "feat(ios): add widgets", "ios\n");
    await commit(root, "fix(android): repair back button", "android\n");
    const manifest: ShipManifest = {
      schemaVersion: 1,
      platforms: {
        ios: { version: "1.2.3", baselineSha, pendingRelease: false },
      },
    };

    const plan = await createReleasePlan(root, manifest, "ios");

    expect(plan?.nextVersion).toBe("1.3.0");
    expect(plan?.changes.map((change) => change.description)).toEqual([
      "add widgets",
    ]);
  });

  it("uses the platform tag as the next release baseline", async () => {
    const { root, baselineSha } = await repository();
    await commit(root, "feat: already released", "released\n");
    await git(root, ["tag", releaseTag("ios", "2.0.0")]);
    await commit(root, "fix: new patch", "patch\n");
    const manifest: ShipManifest = {
      schemaVersion: 1,
      platforms: {
        ios: { version: "2.0.0", baselineSha, pendingRelease: true },
      },
    };

    const plan = await createReleasePlan(root, manifest, "ios");

    expect(plan?.nextVersion).toBe("2.0.1");
    expect(plan?.changes).toHaveLength(1);
    expect(await releaseNeedsPromotion(root, manifest, "ios")).toBe(false);
  });

  it("recognizes a merged pending release without a tag", async () => {
    const { root, baselineSha } = await repository();
    const manifest: ShipManifest = {
      schemaVersion: 1,
      platforms: {
        ios: { version: "1.0.0", baselineSha, pendingRelease: true },
      },
    };
    expect(await releaseNeedsPromotion(root, manifest, "ios")).toBe(true);
  });

  it("returns no plan for non-releasable commits", async () => {
    const { root, baselineSha } = await repository();
    await commit(root, "chore: update tooling", "tooling\n");
    const manifest: ShipManifest = {
      schemaVersion: 1,
      platforms: {
        ios: { version: "1.0.0", baselineSha, pendingRelease: false },
      },
    };
    await expect(createReleasePlan(root, manifest, "ios")).resolves.toBeNull();
  });

  it("honors an explicit Release-As version", async () => {
    const { root, baselineSha } = await repository();
    await commit(
      root,
      "chore(ios): prepare migration\n\nRelease-As-ios: 4.0.0",
      "migration\n",
    );
    const manifest: ShipManifest = {
      schemaVersion: 1,
      platforms: {
        ios: { version: "1.0.0", baselineSha, pendingRelease: false },
      },
    };
    const plan = await createReleasePlan(root, manifest, "ios");
    expect(plan?.nextVersion).toBe("4.0.0");
  });
});
