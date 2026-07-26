import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import { sourceFingerprint } from "../src/fingerprint.js";
import { git } from "../src/git.js";

const temporaryDirectories: string[] = [];

afterEach(async () => {
  await Promise.all(
    temporaryDirectories
      .splice(0)
      .map((directory) => fs.rm(directory, { recursive: true, force: true })),
  );
});

describe("candidate source fingerprint", () => {
  it("supports repositories before ship-my-flutter is initialized", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "smf-fingerprint-"));
    temporaryDirectories.push(root);
    await git(root, ["init", "-b", "main"]);
    await fs.writeFile(path.join(root, "lib.dart"), "void main() {}\n");
    await git(root, ["add", "."]);
    await expect(sourceFingerprint(root)).resolves.toMatch(/^[a-f0-9]{64}$/u);
  });

  it("ignores human-editable notes and candidate receipts", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "smf-fingerprint-"));
    temporaryDirectories.push(root);
    await git(root, ["init", "-b", "main"]);
    await fs.mkdir(path.join(root, ".ship-my-flutter", "candidates"), {
      recursive: true,
    });
    await fs.writeFile(path.join(root, "lib.dart"), "void main() {}\n");
    await fs.writeFile(
      path.join(root, ".ship-my-flutter", "store-release-notes.json"),
      "{}\n",
    );
    await fs.writeFile(
      path.join(root, ".ship-my-flutter", "config.json"),
      `${JSON.stringify({
        platforms: {
          ios: {
            projectPath: ".",
            bundleId: "dev.example.app",
            buildArgs: [],
            testflight: { groups: [] },
            appStore: { mode: "upload-only", releaseType: "manual" },
          },
        },
      })}\n`,
    );
    await fs.writeFile(
      path.join(root, ".ship-my-flutter", "candidates", "ios-1.0.0.json"),
      "{}\n",
    );
    await git(root, ["add", "."]);

    const before = await sourceFingerprint(root);
    await fs.writeFile(
      path.join(root, ".ship-my-flutter", "store-release-notes.json"),
      '{"ios":{}}\n',
    );
    await fs.writeFile(
      path.join(root, ".ship-my-flutter", "candidates", "ios-1.0.0.json"),
      '{"build":"1"}\n',
    );
    await fs.writeFile(
      path.join(root, ".ship-my-flutter", "config.json"),
      `${JSON.stringify({
        platforms: {
          ios: {
            projectPath: ".",
            bundleId: "dev.example.app",
            buildArgs: [],
            testflight: { groups: ["Internal"] },
            appStore: {
              mode: "submit-for-review",
              releaseType: "automatic",
            },
          },
        },
      })}\n`,
    );
    expect(await sourceFingerprint(root)).toBe(before);

    await fs.writeFile(
      path.join(root, ".ship-my-flutter", "config.json"),
      `${JSON.stringify({
        platforms: {
          ios: {
            projectPath: ".",
            bundleId: "dev.example.app",
            buildArgs: ["--dart-define=ENV=production"],
          },
        },
      })}\n`,
    );
    expect(await sourceFingerprint(root)).not.toBe(before);

    await fs.writeFile(path.join(root, "lib.dart"), "void main() => run();\n");
    expect(await sourceFingerprint(root)).not.toBe(before);
  });
});
