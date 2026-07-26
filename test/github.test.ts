import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import type { Octokit } from "@octokit/rest";
import { afterEach, describe, expect, it, vi } from "vitest";
import { loadConfig, loadManifest } from "../src/config.js";
import { git } from "../src/git.js";
import { createOrUpdateReleasePullRequest } from "../src/github.js";
import { initialize } from "../src/init.js";
import { createReleasePlan } from "../src/release-plan.js";

const temporaryDirectories: string[] = [];

afterEach(async () => {
  await Promise.all(
    temporaryDirectories
      .splice(0)
      .map((directory) => fs.rm(directory, { recursive: true, force: true })),
  );
});

describe("GitHub release pull requests", () => {
  it("creates and pushes a platform release branch", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "smf-github-"));
    const origin = await fs.mkdtemp(path.join(os.tmpdir(), "smf-origin-"));
    temporaryDirectories.push(root, origin);
    await git(origin, ["init", "--bare"]);
    await fs.mkdir(path.join(root, "ios"));
    await fs.writeFile(
      path.join(root, "pubspec.yaml"),
      "name: example\nversion: 1.0.0+1\n",
    );
    await fs.writeFile(path.join(root, "app.txt"), "baseline\n");
    await git(root, ["init", "-b", "main"]);
    await git(root, ["config", "user.name", "Test"]);
    await git(root, ["config", "user.email", "test@example.com"]);
    await git(root, ["add", "."]);
    await git(root, ["commit", "-m", "chore: bootstrap"]);
    await initialize({ root, bundleId: "dev.example.app" });
    await git(root, ["add", "."]);
    await git(root, ["commit", "-m", "chore: configure releases"]);
    await git(root, ["remote", "add", "origin", origin]);
    await git(root, ["push", "-u", "origin", "main"]);

    await fs.writeFile(path.join(root, "app.txt"), "feature\n");
    await git(root, ["add", "."]);
    await git(root, ["commit", "-m", "feat(ios): add offline mode"]);
    await git(root, ["push", "origin", "main"]);

    const plan = await createReleasePlan(root, await loadManifest(root), "ios");
    expect(plan).not.toBeNull();

    const pullsCreate = vi.fn().mockResolvedValue({ data: { number: 42 } });
    const pullsUpdate = vi.fn().mockResolvedValue({});
    const octokit = {
      issues: {
        getLabel: vi
          .fn()
          .mockRejectedValueOnce(
            Object.assign(new Error("missing"), { status: 404 }),
          )
          .mockResolvedValueOnce({}),
        createLabel: vi.fn().mockResolvedValue({}),
        addLabels: vi.fn().mockResolvedValue({}),
      },
      pulls: {
        list: vi
          .fn()
          .mockResolvedValueOnce({ data: [] })
          .mockResolvedValueOnce({ data: [{ number: 42 }] }),
        create: pullsCreate,
        update: pullsUpdate,
      },
    } as unknown as Octokit;

    await expect(
      createOrUpdateReleasePullRequest(
        root,
        await loadConfig(root),
        plan!,
        { owner: "example", repo: "app", token: "unused" },
        octokit,
      ),
    ).resolves.toEqual({
      branch: "ship-my-flutter/ios",
      pullRequestNumber: 42,
    });
    expect(pullsCreate).toHaveBeenCalledWith(
      expect.objectContaining({
        head: "ship-my-flutter/ios",
        base: "main",
        title: "chore(ios): release 1.1.0",
      }),
    );
    expect(
      await git(origin, [
        "show",
        "ship-my-flutter/ios:.ship-my-flutter/manifest.json",
      ]),
    ).toContain('"pendingRelease": true');
    expect(await git(root, ["branch", "--show-current"])).toBe("main");

    await fs.writeFile(path.join(root, "app.txt"), "feature and fix\n");
    await git(root, ["add", "."]);
    await git(root, ["commit", "-m", "fix(ios): correct offline state"]);
    await git(root, ["push", "origin", "main"]);
    const refreshedPlan = await createReleasePlan(
      root,
      await loadManifest(root),
      "ios",
    );
    await git(root, ["config", "--unset-all", "user.name"]);
    await git(root, ["config", "--unset-all", "user.email"]);
    await createOrUpdateReleasePullRequest(
      root,
      await loadConfig(root),
      refreshedPlan!,
      { owner: "example", repo: "app", token: "unused" },
      octokit,
    );
    expect(pullsUpdate).toHaveBeenCalledWith(
      expect.objectContaining({
        pull_number: 42,
        title: "chore(ios): release 1.1.0",
      }),
    );
    expect(await git(root, ["config", "user.name"])).toBe(
      "ship-my-flutter[bot]",
    );
  });
});
