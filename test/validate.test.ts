import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import { git } from "../src/git.js";
import { initialize } from "../src/init.js";
import { validateRepository } from "../src/validate.js";

const temporaryDirectories: string[] = [];

afterEach(async () => {
  await Promise.all(
    temporaryDirectories
      .splice(0)
      .map((directory) => fs.rm(directory, { recursive: true, force: true })),
  );
});

describe("repository validation", () => {
  it("requires the release lockfile to exist in Git", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "smf-validate-"));
    temporaryDirectories.push(root);
    await fs.mkdir(path.join(root, "ios"));
    await fs.writeFile(
      path.join(root, "pubspec.yaml"),
      "name: example\nversion: 1.0.0+1\n",
    );
    await git(root, ["init", "-b", "main"]);
    await git(root, ["config", "user.name", "Test"]);
    await git(root, ["config", "user.email", "test@example.com"]);
    await git(root, ["add", "."]);
    await git(root, ["commit", "-m", "chore: bootstrap"]);
    await initialize({ root, bundleId: "dev.example.app" });
    await git(root, ["add", "."]);
    await git(root, ["commit", "-m", "chore: configure releases"]);

    await expect(validateRepository(root)).rejects.toThrow(
      /No committed pubspec\.lock/,
    );
    await fs.writeFile(path.join(root, "pubspec.lock"), "# fixture\n");
    await expect(validateRepository(root)).rejects.toThrow(
      /pubspec\.lock must be committed/,
    );
    await git(root, ["add", "pubspec.lock"]);
    await git(root, ["commit", "-m", "chore: lock dependencies"]);
    await expect(validateRepository(root)).resolves.toBeUndefined();
  });
});
