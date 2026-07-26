import path from "node:path";

export const shipDirectoryName = ".ship-my-flutter";

export interface ShipPaths {
  root: string;
  directory: string;
  config: string;
  manifest: string;
  changelog: string;
  storeReleaseNotes: string;
  candidates: string;
}

export function resolveShipPaths(root = process.cwd()): ShipPaths {
  const directory = path.join(root, shipDirectoryName);
  return {
    root,
    directory,
    config: path.join(directory, "config.yaml"),
    manifest: path.join(directory, "manifest.json"),
    changelog: path.join(directory, "changelog.json"),
    storeReleaseNotes: path.join(directory, "store-release-notes.json"),
    candidates: path.join(directory, "candidates"),
  };
}

export function candidatePath(
  root: string,
  platform: "ios",
  version: string,
): string {
  return path.join(
    resolveShipPaths(root).candidates,
    `${platform}-${version}.json`,
  );
}
