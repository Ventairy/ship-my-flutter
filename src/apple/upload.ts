import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { fileExists } from "../json.js";
import { ShipError, invariant } from "../errors.js";
import { run } from "../process.js";
import type { AppleCredentials } from "../types.js";

async function findIpa(projectRoot: string): Promise<string> {
  const directory = path.join(projectRoot, "build", "ios", "ipa");
  let entries: string[];
  try {
    entries = await fs.readdir(directory);
  } catch (error) {
    throw new ShipError(
      `Flutter did not produce an IPA in ${directory}.`,
      "IPA_NOT_FOUND",
      { cause: error },
    );
  }
  const ipas = entries
    .filter((entry) => entry.endsWith(".ipa"))
    .map((entry) => path.join(directory, entry));
  invariant(
    ipas.length === 1,
    `Expected exactly one IPA in ${directory}, found ${ipas.length}.`,
    "IPA_COUNT",
  );
  return ipas[0]!;
}

export async function buildFlutterIpa(options: {
  projectRoot: string;
  version: string;
  buildNumber: string;
  exportOptionsPath: string;
  scheme?: string;
  buildArgs: string[];
}): Promise<string> {
  const args = [
    "build",
    "ipa",
    "--no-pub",
    "--release",
    "--build-name",
    options.version,
    "--build-number",
    options.buildNumber,
    "--export-options-plist",
    options.exportOptionsPath,
    ...(options.scheme ? ["--flavor", options.scheme] : []),
    ...options.buildArgs,
  ];
  await run("flutter", args, { cwd: options.projectRoot });
  return findIpa(options.projectRoot);
}

export async function prepareFlutterDependencies(
  projectRoot: string,
): Promise<void> {
  await run("flutter", ["pub", "get", "--enforce-lockfile"], {
    cwd: projectRoot,
  });
}

export async function uploadIpa(
  ipaPath: string,
  credentials: AppleCredentials,
): Promise<void> {
  const privateKeysDirectory = path.join(
    os.homedir(),
    ".appstoreconnect",
    "private_keys",
  );
  const keyPath = path.join(
    privateKeysDirectory,
    `AuthKey_${credentials.keyId}.p8`,
  );
  const existed = await fileExists(keyPath);
  if (existed) {
    const existing = (await fs.readFile(keyPath, "utf8")).trim();
    invariant(
      existing === credentials.privateKey.trim(),
      `${keyPath} already exists with different contents.`,
      "PRIVATE_KEY_COLLISION",
    );
  } else {
    await fs.mkdir(privateKeysDirectory, { recursive: true });
    await fs.writeFile(keyPath, credentials.privateKey, { mode: 0o600 });
  }

  try {
    await run("xcrun", [
      "altool",
      "--upload-app",
      "--type",
      "ios",
      "-f",
      ipaPath,
      "--apiKey",
      credentials.keyId,
      "--apiIssuer",
      credentials.issuerId,
    ]);
  } finally {
    if (!existed) await fs.rm(keyPath, { force: true });
  }
}
