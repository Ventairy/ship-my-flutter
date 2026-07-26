import path from "node:path";
import { invariant } from "./errors.js";
import { run } from "./process.js";
import { resolveShipPaths } from "./paths.js";
import type { ReleasePlan, ShipConfig } from "./types.js";

export async function runBeforeReleasePrHook(
  root: string,
  config: ShipConfig,
  plan: ReleasePlan,
): Promise<void> {
  const hook = config.hooks.beforeReleasePr;
  if (!hook) return;

  const commandPath = path.resolve(root, hook);
  invariant(
    commandPath.startsWith(`${path.resolve(root)}${path.sep}`),
    "beforeReleasePr must stay inside the repository",
    "UNSAFE_HOOK",
  );
  const paths = resolveShipPaths(root);
  await run(commandPath, [], {
    cwd: root,
    env: {
      SHIP_MY_FLUTTER_PLATFORM: plan.platform,
      SHIP_MY_FLUTTER_CURRENT_VERSION: plan.currentVersion,
      SHIP_MY_FLUTTER_VERSION: plan.nextVersion,
      SHIP_MY_FLUTTER_CHANGELOG_PATH: paths.changelog,
      SHIP_MY_FLUTTER_STORE_RELEASE_NOTES_PATH: paths.storeReleaseNotes,
    },
  });
}
