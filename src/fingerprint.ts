import crypto from "node:crypto";
import fs from "node:fs/promises";
import path from "node:path";
import { git } from "./git.js";

const excluded = new Set([
  ".ship-my-flutter/changelog.json",
  ".ship-my-flutter/config.json",
  ".ship-my-flutter/store-release-notes.json",
]);

function shouldInclude(file: string): boolean {
  if (excluded.has(file)) return false;
  if (file.startsWith(".ship-my-flutter/candidates/")) return false;
  return true;
}

export async function sourceFingerprint(root: string): Promise<string> {
  const output = await git(root, ["ls-files", "-z"]);
  const files = output.split("\0").filter(Boolean).filter(shouldInclude).sort();
  const hash = crypto.createHash("sha256");
  for (const file of files) {
    const filePath = path.join(root, file);
    const stats = await fs.lstat(filePath);
    hash.update(file);
    hash.update("\0");
    hash.update(
      stats.isSymbolicLink() ? "symlink" : String(stats.mode & 0o111),
    );
    hash.update("\0");
    hash.update(
      stats.isSymbolicLink()
        ? await fs.readlink(filePath)
        : await fs.readFile(filePath),
    );
    hash.update("\0");
  }
  const configPath = path.join(root, ".ship-my-flutter", "config.json");
  try {
    const config = JSON.parse(await fs.readFile(configPath, "utf8")) as {
      platforms?: {
        ios?: {
          projectPath?: unknown;
          bundleId?: unknown;
          scheme?: unknown;
          buildArgs?: unknown;
        };
      };
    };
    const ios = config.platforms?.ios;
    hash.update(".ship-my-flutter/config.build-inputs\0");
    hash.update(
      JSON.stringify({
        projectPath: ios?.projectPath,
        bundleId: ios?.bundleId,
        scheme: ios?.scheme,
        buildArgs: ios?.buildArgs,
      }),
    );
    hash.update("\0");
  } catch (error) {
    if (
      typeof error !== "object" ||
      error === null ||
      !("code" in error) ||
      error.code !== "ENOENT"
    ) {
      throw error;
    }
  }
  return hash.digest("hex");
}

export async function fileSha256(filePath: string): Promise<string> {
  return crypto
    .createHash("sha256")
    .update(await fs.readFile(filePath))
    .digest("hex");
}
