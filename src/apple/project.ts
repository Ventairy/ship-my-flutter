import fs from "node:fs/promises";
import path from "node:path";
import { ShipError } from "../errors.js";
import { run } from "../process.js";
import type { IosConfig } from "../types.js";

export async function resolveBundleId(
  repositoryRoot: string,
  config: IosConfig,
): Promise<string> {
  if (config.bundleId) return config.bundleId;
  if (process.platform !== "darwin") {
    throw new ShipError(
      "platforms.ios.bundleId is required when configuration is validated outside macOS.",
      "BUNDLE_ID_REQUIRED",
    );
  }

  const projectRoot = path.resolve(repositoryRoot, config.projectPath);
  const iosDirectory = path.join(projectRoot, "ios");
  const entries = await fs.readdir(iosDirectory);
  const workspace = entries.find((entry) => entry.endsWith(".xcworkspace"));
  const project = entries.find((entry) => entry.endsWith(".xcodeproj"));
  const scheme = config.scheme ?? "Runner";
  const args = workspace
    ? [
        "-workspace",
        path.join(iosDirectory, workspace),
        "-scheme",
        scheme,
        "-configuration",
        "Release",
        "-showBuildSettings",
      ]
    : project
      ? [
          "-project",
          path.join(iosDirectory, project),
          "-scheme",
          scheme,
          "-configuration",
          "Release",
          "-showBuildSettings",
        ]
      : [];
  if (args.length === 0) {
    throw new ShipError(
      `No Xcode workspace or project found in ${iosDirectory}.`,
      "XCODE_PROJECT_NOT_FOUND",
    );
  }
  const result = await run("xcodebuild", args, {
    cwd: projectRoot,
    silent: true,
  });
  const matches = [
    ...result.stdout.matchAll(/PRODUCT_BUNDLE_IDENTIFIER = (.+)$/gmu),
  ];
  const bundleId = matches.at(-1)?.[1]?.trim();
  if (!bundleId || bundleId.includes("$(")) {
    throw new ShipError(
      "Could not detect PRODUCT_BUNDLE_IDENTIFIER. Set platforms.ios.bundleId in .ship-my-flutter/config.yaml.",
      "BUNDLE_ID_REQUIRED",
    );
  }
  return bundleId;
}
