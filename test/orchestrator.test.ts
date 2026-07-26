import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import { git } from "../src/git.js";
import { initialize } from "../src/init.js";
import { readJson, writeJson } from "../src/json.js";
import { planGitHubRelease } from "../src/orchestrator.js";
import type { ShipConfig, ShipManifest } from "../src/types.js";

const temporaryDirectories: string[] = [];

async function repository(): Promise<string> {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "smf-orchestrator-"));
  temporaryDirectories.push(root);
  await fs.mkdir(path.join(root, "ios"));
  await fs.writeFile(
    path.join(root, "pubspec.yaml"),
    "name: example\nversion: 1.0.0+1\n",
  );
  await fs.writeFile(path.join(root, "pubspec.lock"), "# fixture lockfile\n");
  await git(root, ["init", "-b", "main"]);
  await git(root, ["config", "user.name", "Test"]);
  await git(root, ["config", "user.email", "test@example.com"]);
  await git(root, ["add", "."]);
  await git(root, ["commit", "-m", "chore: bootstrap"]);
  await initialize({ root, bundleId: "dev.example.app" });
  await git(root, ["add", "."]);
  await git(root, ["commit", "-m", "chore: configure releases"]);
  return root;
}

afterEach(async () => {
  await Promise.all(
    temporaryDirectories
      .splice(0)
      .map((directory) => fs.rm(directory, { recursive: true, force: true })),
  );
});

describe("workflow routing", () => {
  it("routes only the configured pending release branch to candidate", async () => {
    const root = await repository();
    await git(root, ["checkout", "-b", "ship-my-flutter/ios"]);
    const manifestPath = path.join(root, ".ship-my-flutter", "manifest.json");
    const manifest = await readJson<ShipManifest>(manifestPath);
    manifest.platforms.ios = {
      ...manifest.platforms.ios,
      version: "1.1.0",
      pendingRelease: true,
    };
    await writeJson(manifestPath, manifest);
    await writeJson(path.join(root, ".ship-my-flutter", "changelog.json"), {
      schemaVersion: 1,
      platforms: {
        ios: {
          releases: {
            "1.1.0": {
              version: "1.1.0",
              preparedAt: "2026-07-26T00:00:00.000Z",
              baseSha: manifest.platforms.ios.baselineSha,
              headSha: manifest.platforms.ios.baselineSha,
              changes: [
                {
                  sha: manifest.platforms.ios.baselineSha,
                  type: "feat",
                  scope: "ios",
                  description: "Fixture release",
                  body: null,
                  breaking: false,
                  bump: "minor",
                  platforms: ["ios"],
                },
              ],
            },
          },
        },
      },
    });
    await git(root, ["add", "."]);
    await git(root, ["commit", "-m", "chore(ios): release 1.1.0"]);

    await expect(
      planGitHubRelease({
        root,
        github: { owner: "example", repo: "app", token: "unused" },
      }),
    ).resolves.toEqual({
      phase: "candidate",
      platform: "ios",
      version: "1.1.0",
      branch: "ship-my-flutter/ios",
    });

    await git(root, ["tag", "ios-v1.1.0"]);
    await expect(
      planGitHubRelease({
        root,
        github: { owner: "example", repo: "app", token: "unused" },
      }),
    ).resolves.toEqual({ phase: "noop" });
  });

  it("does nothing on unrelated branches", async () => {
    const root = await repository();
    await git(root, ["checkout", "-b", "docs"]);
    await expect(
      planGitHubRelease({
        root,
        github: { owner: "example", repo: "app", token: "unused" },
      }),
    ).resolves.toEqual({ phase: "noop" });
  });

  it("does nothing when iOS delivery is disabled", async () => {
    const root = await repository();
    const configPath = path.join(root, ".ship-my-flutter", "config.json");
    const config = await readJson<ShipConfig>(configPath);
    config.platforms.ios.enabled = false;
    await writeJson(configPath, config);
    await expect(
      planGitHubRelease({
        root,
        github: { owner: "example", repo: "app", token: "unused" },
      }),
    ).resolves.toEqual({ phase: "noop" });
  });
});
