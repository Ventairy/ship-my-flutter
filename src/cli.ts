#!/usr/bin/env node
import fs from "node:fs";
import { Command } from "commander";
import {
  appleCredentialsFromEnvironment,
  signingCredentialsFromEnvironment,
} from "./apple/credentials.js";
import { createIosCandidate } from "./apple/candidate.js";
import { promoteIosRelease } from "./apple/promote.js";
import { loadManifest } from "./config.js";
import { ShipError } from "./errors.js";
import { initialize } from "./init.js";
import { planGitHubRelease } from "./orchestrator.js";
import { createReleasePlan } from "./release-plan.js";
import { validateRepository } from "./validate.js";
import type { GitHubContext } from "./types.js";

const packageVersion = (
  JSON.parse(
    fs.readFileSync(new URL("../package.json", import.meta.url), "utf8"),
  ) as { version: string }
).version;

const credentialEnvironmentNames = [
  "GITHUB_TOKEN",
  "SMF_APP_STORE_CONNECT_KEY_ID",
  "SMF_APP_STORE_CONNECT_ISSUER_ID",
  "SMF_APP_STORE_CONNECT_PRIVATE_KEY_BASE64",
  "SMF_IOS_CERTIFICATE_BASE64",
  "SMF_IOS_CERTIFICATE_PASSWORD",
  "SMF_IOS_PROVISIONING_PROFILES_BASE64",
] as const;

function clearCredentialEnvironment(): void {
  for (const name of credentialEnvironmentNames) {
    delete process.env[name];
  }
}

function githubFromEnvironment(repository?: string): GitHubContext {
  const resolvedToken = process.env.GITHUB_TOKEN;
  const resolvedRepository = repository ?? process.env.GITHUB_REPOSITORY;
  if (!resolvedToken) {
    throw new ShipError("A GitHub token is required.", "GITHUB_TOKEN_REQUIRED");
  }
  if (!resolvedRepository?.includes("/")) {
    throw new ShipError(
      "A GitHub repository in owner/name form is required.",
      "GITHUB_REPOSITORY_REQUIRED",
    );
  }
  const [owner, repo] = resolvedRepository.split("/", 2);
  return { owner: owner!, repo: repo!, token: resolvedToken };
}

function print(value: unknown): void {
  process.stdout.write(`${JSON.stringify(value, null, 2)}\n`);
}

const program = new Command()
  .name("ship-my-flutter")
  .description(
    "Platform-scoped release PRs, TestFlight candidates, and App Store delivery.",
  )
  .version(packageVersion);

program
  .command("init")
  .description("Create .ship-my-flutter configuration in a Flutter repository.")
  .option("--root <path>", "Flutter repository root", process.cwd())
  .option("--current-version <version>", "Current released iOS version")
  .option("--bundle-id <bundleId>", "iOS bundle identifier")
  .option("--force", "Replace existing generated configuration", false)
  .action(async (options) => {
    await initialize({
      root: options.root as string,
      ...(options.currentVersion
        ? { currentVersion: options.currentVersion as string }
        : {}),
      ...(options.bundleId ? { bundleId: options.bundleId as string } : {}),
      force: Boolean(options.force),
    });
    print({ initialized: true, root: options.root });
  });

program
  .command("validate")
  .description("Validate configuration and the Flutter iOS project.")
  .option("--root <path>", "Flutter repository root", process.cwd())
  .action(async (options) => {
    await validateRepository(options.root as string);
    print({ valid: true });
  });

program
  .command("plan")
  .description("Print the next local iOS release plan without changing files.")
  .option("--root <path>", "Flutter repository root", process.cwd())
  .action(async (options) => {
    const root = options.root as string;
    print(await createReleasePlan(root, await loadManifest(root), "ios"));
  });

program
  .command("action-plan")
  .description("Open or update a release PR, or report a merged release.")
  .option("--root <path>", "Flutter repository root", process.cwd())
  .option("--repository <owner/name>", "GitHub repository")
  .action(async (options) => {
    const github = githubFromEnvironment(
      options.repository as string | undefined,
    );
    clearCredentialEnvironment();
    print(
      await planGitHubRelease({
        root: options.root as string,
        github,
      }),
    );
  });

program
  .command("candidate")
  .description("Build, sign, upload, and record the pending iOS candidate.")
  .option("--root <path>", "Flutter repository root", process.cwd())
  .option("--no-commit-receipt", "Do not commit the candidate receipt")
  .action(async (options) => {
    const appleCredentials = appleCredentialsFromEnvironment();
    const signingCredentials = signingCredentialsFromEnvironment();
    clearCredentialEnvironment();
    print(
      await createIosCandidate({
        root: options.root as string,
        appleCredentials,
        signingCredentials,
        commitReceipt: Boolean(options.commitReceipt),
      }),
    );
  });

program
  .command("promote")
  .description(
    "Promote the exact recorded candidate after the release PR merges.",
  )
  .option("--root <path>", "Flutter repository root", process.cwd())
  .option("--repository <owner/name>", "GitHub repository")
  .action(async (options) => {
    const appleCredentials = appleCredentialsFromEnvironment();
    const github = githubFromEnvironment(
      options.repository as string | undefined,
    );
    clearCredentialEnvironment();
    print(
      await promoteIosRelease({
        root: options.root as string,
        appleCredentials,
        github,
      }),
    );
  });

program.parseAsync().catch((error: unknown) => {
  if (error instanceof ShipError) {
    console.error(`ship-my-flutter: ${error.message}`);
    process.exitCode = 1;
    return;
  }
  console.error(error);
  process.exitCode = 1;
});
