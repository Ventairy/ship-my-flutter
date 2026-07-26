import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import { runBeforeReleasePrHook } from "../src/hooks.js";
import type { ReleasePlan, ShipConfig } from "../src/types.js";

const temporaryDirectories: string[] = [];

afterEach(async () => {
  await Promise.all(
    temporaryDirectories
      .splice(0)
      .map((directory) => fs.rm(directory, { recursive: true, force: true })),
  );
});

describe("release PR hooks", () => {
  it("runs a repository-owned executable with release context", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "smf-hook-"));
    temporaryDirectories.push(root);
    const hookPath = path.join(root, "release-hook.sh");
    await fs.writeFile(
      hookPath,
      [
        "#!/bin/sh",
        'test "$SHIP_MY_FLUTTER_PLATFORM" = "ios"',
        'test "$SHIP_MY_FLUTTER_CURRENT_VERSION" = "1.0.0"',
        'test "$SHIP_MY_FLUTTER_VERSION" = "1.1.0"',
        "",
      ].join("\n"),
      { mode: 0o700 },
    );
    const config = {
      hooks: { beforeReleasePr: "release-hook.sh" },
    } as ShipConfig;
    const plan = {
      platform: "ios",
      currentVersion: "1.0.0",
      nextVersion: "1.1.0",
    } as ReleasePlan;

    await expect(
      runBeforeReleasePrHook(root, config, plan),
    ).resolves.toBeUndefined();
  });
});
