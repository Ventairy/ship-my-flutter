import fs from "node:fs/promises";
import path from "node:path";
import semver from "semver";
import YAML from "yaml";
import { invariant, ShipError } from "./errors.js";
import { currentSha } from "./git.js";
import { fileExists, writeJson } from "./json.js";
import { emptyChangelog } from "./manifest-files.js";
import { resolveShipPaths } from "./paths.js";
import type { ShipConfig, ShipManifest, StoreReleaseNotes } from "./types.js";

export interface InitOptions {
  root: string;
  currentVersion?: string;
  bundleId?: string;
  force?: boolean;
}

async function detectFlutterVersion(root: string): Promise<string | undefined> {
  const pubspecPath = path.join(root, "pubspec.yaml");
  if (!(await fileExists(pubspecPath))) return undefined;
  const pubspec = YAML.parse(await fs.readFile(pubspecPath, "utf8")) as {
    version?: string;
  };
  const value = pubspec.version?.split("+")[0];
  return value && semver.valid(value) ? value : undefined;
}

export async function initialize(options: InitOptions): Promise<void> {
  const root = path.resolve(options.root);
  const paths = resolveShipPaths(root);
  if ((await fileExists(paths.config)) && !options.force) {
    throw new ShipError(
      `${paths.config} already exists. Pass --force to replace the generated files.`,
      "ALREADY_INITIALIZED",
    );
  }

  const version =
    options.currentVersion ?? (await detectFlutterVersion(root)) ?? "0.0.0";
  invariant(
    semver.valid(version) &&
      semver.prerelease(version) === null &&
      (semver.parse(version)?.build.length ?? 0) === 0,
    `${version} must be a stable major.minor.patch version`,
    "SEMVER",
  );
  const baselineSha = await currentSha(root);

  const config: ShipConfig = {
    schemaVersion: 1,
    targetBranch: "main",
    releaseBranchPrefix: "ship-my-flutter",
    hooks: {},
    platforms: {
      ios: {
        enabled: true,
        projectPath: ".",
        ...(options.bundleId ? { bundleId: options.bundleId } : {}),
        buildArgs: [],
        testflight: {
          groups: [],
          waitTimeoutMinutes: 45,
        },
        appStore: {
          mode: "submit-for-review",
          releaseType: "manual",
        },
      },
    },
  };
  const manifest: ShipManifest = {
    schemaVersion: 1,
    platforms: {
      ios: {
        version,
        baselineSha,
        pendingRelease: false,
      },
    },
  };
  const notes: StoreReleaseNotes = { ios: {} };
  const workflowPath = path.join(
    root,
    ".github",
    "workflows",
    "ship-my-flutter.yml",
  );
  const workflowTemplate = new URL(
    "../templates/ship-my-flutter.yml",
    import.meta.url,
  );

  await fs.mkdir(paths.candidates, { recursive: true });
  const writes: Array<Promise<void>> = [
    writeJson(paths.config, config),
    writeJson(paths.manifest, manifest),
    writeJson(paths.changelog, emptyChangelog()),
    writeJson(paths.storeReleaseNotes, notes),
    fs.writeFile(path.join(paths.candidates, ".gitkeep"), "", "utf8"),
  ];
  if (options.force || !(await fileExists(workflowPath))) {
    await fs.mkdir(path.dirname(workflowPath), { recursive: true });
    writes.push(
      fs
        .readFile(workflowTemplate, "utf8")
        .then((template) => fs.writeFile(workflowPath, template, "utf8")),
    );
  }
  await Promise.all(writes);
}
