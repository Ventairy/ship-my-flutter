import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import { git } from "../src/git.js";
import { initialize } from "../src/init.js";
import { fileExists, readJson, readYaml } from "../src/json.js";
import type { ShipConfig, ShipManifest } from "../src/types.js";

const temporaryDirectories: string[] = [];

afterEach(async () => {
  await Promise.all(
    temporaryDirectories
      .splice(0)
      .map((directory) => fs.rm(directory, { recursive: true, force: true })),
  );
});

describe("initializer", () => {
  it("creates tracked state and the complete workflow", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "smf-init-"));
    temporaryDirectories.push(root);
    await fs.mkdir(path.join(root, "ios"));
    await fs.writeFile(
      path.join(root, "pubspec.yaml"),
      "name: example\nversion: 3.2.1+42\n",
    );
    await git(root, ["init", "-b", "main"]);
    await git(root, ["config", "user.name", "Test"]);
    await git(root, ["config", "user.email", "test@example.com"]);
    await git(root, ["add", "."]);
    await git(root, ["commit", "-m", "chore: bootstrap"]);
    const baselineSha = await git(root, ["rev-parse", "HEAD"]);

    await initialize({ root, bundleId: "dev.example.app" });

    const manifest = await readJson<ShipManifest>(
      path.join(root, ".ship-my-flutter", "manifest.json"),
    );
    expect(manifest.platforms.ios).toMatchObject({
      version: "3.2.1",
      baselineSha,
      pendingRelease: false,
    });
    const configPath = path.join(root, ".ship-my-flutter", "config.yaml");
    const config = await readYaml<ShipConfig>(configPath);
    expect(config.platforms.ios.appStore.mode).toBe("upload-only");
    expect(await fs.readFile(configPath, "utf8")).toContain(
      "# yaml-language-server: $schema=https://raw.githubusercontent.com/Ventairy/ship-my-flutter/main/schemas/config.schema.json",
    );
    expect(
      await fileExists(
        path.join(root, ".ship-my-flutter", "candidates", ".gitkeep"),
      ),
    ).toBe(true);
    const workflow = await fs.readFile(
      path.join(root, ".github", "workflows", "ship-my-flutter.yml"),
      "utf8",
    );
    expect(workflow).toContain("Ventairy/ship-my-flutter-action@v1");
    expect(workflow).toContain("runs-on: macos-26");
    expect(workflow.match(/persist-credentials: false/gu)).toHaveLength(3);
  });
});
