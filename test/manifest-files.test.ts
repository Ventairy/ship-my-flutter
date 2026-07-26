import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import { loadChangelog } from "../src/config.js";
import { git } from "../src/git.js";
import { applyReleasePlan } from "../src/manifest-files.js";
import { writeJson } from "../src/json.js";
import type { ReleasePlan } from "../src/types.js";

const temporaryDirectories: string[] = [];

afterEach(async () => {
  await Promise.all(
    temporaryDirectories
      .splice(0)
      .map((directory) => fs.rm(directory, { recursive: true, force: true })),
  );
});

describe("release manifests", () => {
  it("replaces an abandoned pending changelog version", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "smf-manifest-"));
    temporaryDirectories.push(root);
    const state = path.join(root, ".ship-my-flutter");
    await fs.mkdir(state, { recursive: true });
    await writeJson(path.join(state, "manifest.json"), {
      schemaVersion: 1,
      platforms: {
        ios: {
          version: "1.1.0",
          baselineSha: "a".repeat(40),
          pendingRelease: true,
        },
      },
    });
    await writeJson(path.join(state, "changelog.json"), {
      schemaVersion: 1,
      platforms: {
        ios: {
          releases: {
            "1.1.0": {
              version: "1.1.0",
              preparedAt: "2026-07-25T00:00:00.000Z",
              baseSha: "a".repeat(40),
              headSha: "b".repeat(40),
              changes: [
                {
                  sha: "b".repeat(40),
                  type: "feat",
                  scope: "ios",
                  description: "Old plan",
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
    await fs.mkdir(path.join(state, "candidates"));
    await fs.writeFile(
      path.join(state, "candidates", "ios-1.1.0.json"),
      "{}\n",
    );
    const plan: ReleasePlan = {
      platform: "ios",
      currentVersion: "1.0.0",
      nextVersion: "2.0.0",
      bump: "major",
      baseSha: "a".repeat(40),
      headSha: "c".repeat(40),
      changes: [
        {
          sha: "c".repeat(40),
          type: "feat",
          scope: "ios",
          description: "Breaking plan",
          body: null,
          breaking: true,
          bump: "major",
          platforms: ["ios"],
        },
      ],
    };

    await applyReleasePlan(root, plan, "2026-07-26T00:00:00.000Z");

    const changelog = await loadChangelog(root);
    expect(Object.keys(changelog.platforms.ios.releases)).toEqual(["2.0.0"]);
    await expect(
      fs.access(path.join(state, "candidates", "ios-1.1.0.json")),
    ).rejects.toThrow();
  });

  it("preserves a tagged release when preparing the next version", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "smf-manifest-"));
    temporaryDirectories.push(root);
    const state = path.join(root, ".ship-my-flutter");
    await fs.mkdir(path.join(state, "candidates"), { recursive: true });
    await writeJson(path.join(state, "manifest.json"), {
      schemaVersion: 1,
      platforms: {
        ios: {
          version: "1.1.0",
          baselineSha: "a".repeat(40),
          pendingRelease: true,
        },
      },
    });
    await writeJson(path.join(state, "changelog.json"), {
      schemaVersion: 1,
      platforms: {
        ios: {
          releases: {
            "1.1.0": {
              version: "1.1.0",
              preparedAt: "2026-07-25T00:00:00.000Z",
              baseSha: "a".repeat(40),
              headSha: "b".repeat(40),
              changes: [
                {
                  sha: "b".repeat(40),
                  type: "feat",
                  scope: "ios",
                  description: "Released plan",
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
    const receiptPath = path.join(state, "candidates", "ios-1.1.0.json");
    await fs.writeFile(receiptPath, "{}\n");
    await git(root, ["init", "-b", "main"]);
    await git(root, ["config", "user.name", "Test"]);
    await git(root, ["config", "user.email", "test@example.com"]);
    await git(root, ["add", "."]);
    await git(root, ["commit", "-m", "chore(ios): release 1.1.0"]);
    await git(root, ["tag", "ios-v1.1.0"]);

    const plan: ReleasePlan = {
      platform: "ios",
      currentVersion: "1.1.0",
      nextVersion: "1.2.0",
      bump: "minor",
      baseSha: await git(root, ["rev-parse", "HEAD"]),
      headSha: "c".repeat(40),
      changes: [
        {
          sha: "c".repeat(40),
          type: "feat",
          scope: "ios",
          description: "Next plan",
          body: null,
          breaking: false,
          bump: "minor",
          platforms: ["ios"],
        },
      ],
    };

    await applyReleasePlan(root, plan, "2026-07-26T00:00:00.000Z");

    const changelog = await loadChangelog(root);
    expect(Object.keys(changelog.platforms.ios.releases)).toEqual([
      "1.1.0",
      "1.2.0",
    ]);
    await expect(fs.access(receiptPath)).resolves.toBeUndefined();
  });
});
