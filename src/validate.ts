import fs from "node:fs/promises";
import path from "node:path";
import {
  loadChangelog,
  loadConfig,
  loadManifest,
  loadStoreReleaseNotes,
} from "./config.js";
import { invariant } from "./errors.js";
import { git } from "./git.js";
import { fileExists } from "./json.js";
import { resolveShipPaths } from "./paths.js";

async function findWorkspaceLockfile(
  repositoryRoot: string,
  projectRoot: string,
): Promise<string | undefined> {
  let directory = projectRoot;
  while (
    directory === repositoryRoot ||
    directory.startsWith(`${repositoryRoot}${path.sep}`)
  ) {
    const lockfile = path.join(directory, "pubspec.lock");
    if (await fileExists(lockfile)) return lockfile;
    if (directory === repositoryRoot) break;
    directory = path.dirname(directory);
  }
  return undefined;
}

export async function validateRepository(root: string): Promise<void> {
  const paths = resolveShipPaths(root);
  const [config, manifest, changelog, notes] = await Promise.all([
    loadConfig(root),
    loadManifest(root),
    loadChangelog(root),
    loadStoreReleaseNotes(root),
  ]);
  for (const statePath of [
    paths.config,
    paths.manifest,
    paths.changelog,
    paths.storeReleaseNotes,
    paths.candidates,
  ]) {
    invariant(
      await fileExists(statePath),
      `${path.relative(root, statePath)} is missing.`,
      "STATE_PATH_MISSING",
    );
    invariant(
      !(await fs.lstat(statePath)).isSymbolicLink(),
      `${path.relative(root, statePath)} must not be a symbolic link.`,
      "STATE_PATH_SYMLINK",
    );
  }
  if (config.platforms.ios.enabled) {
    const repositoryRoot = path.resolve(root);
    const projectRoot = path.resolve(
      repositoryRoot,
      config.platforms.ios.projectPath,
    );
    const [repositoryRealPath, projectRealPath] = await Promise.all([
      fs.realpath(repositoryRoot),
      fs.realpath(projectRoot),
    ]);
    invariant(
      projectRealPath === repositoryRealPath ||
        projectRealPath.startsWith(`${repositoryRealPath}${path.sep}`),
      "The Flutter projectPath resolves outside the repository.",
      "PROJECT_PATH_ESCAPE",
    );
    invariant(
      await fileExists(path.join(projectRoot, "pubspec.yaml")),
      `No pubspec.yaml exists under ${config.platforms.ios.projectPath}.`,
      "PUBSPEC_NOT_FOUND",
    );
    const lockfile = await findWorkspaceLockfile(
      path.resolve(root),
      projectRoot,
    );
    invariant(
      lockfile,
      "No committed pubspec.lock exists at the Flutter project or workspace root.",
      "LOCKFILE_NOT_FOUND",
    );
    invariant(
      await git(
        root,
        ["ls-files", "--error-unmatch", path.relative(root, lockfile)],
        { allowFailure: true },
      ),
      `${path.relative(root, lockfile)} must be committed before release builds.`,
      "LOCKFILE_UNTRACKED",
    );
    const iosPath = path.join(projectRoot, "ios");
    invariant(
      await fileExists(iosPath),
      `No ios directory exists under ${config.platforms.ios.projectPath}.`,
      "IOS_PROJECT_NOT_FOUND",
    );
    const iosRealPath = await fs.realpath(iosPath);
    invariant(
      iosRealPath.startsWith(`${projectRealPath}${path.sep}`),
      "The ios directory resolves outside the Flutter project.",
      "IOS_PATH_ESCAPE",
    );
  }
  invariant(
    manifest.platforms.ios.version.length > 0,
    "The iOS manifest version is empty.",
  );
  if (manifest.platforms.ios.pendingRelease) {
    invariant(
      changelog.platforms.ios.releases[manifest.platforms.ios.version],
      `The pending iOS version ${manifest.platforms.ios.version} has no changelog entry.`,
      "PENDING_CHANGELOG_MISSING",
    );
  }
  invariant(changelog.schemaVersion === 1, "Unsupported changelog schema.");
  invariant(notes.ios !== undefined, "Store notes must contain an ios object.");
}
