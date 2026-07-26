import { invariant } from "./errors.js";
import { run } from "./process.js";

const recordSeparator = "\u001e";
const fieldSeparator = "\u001f";

export interface GitCommit {
  sha: string;
  message: string;
}

export async function git(
  root: string,
  args: string[],
  options: {
    silent?: boolean;
    allowFailure?: boolean;
    env?: NodeJS.ProcessEnv;
  } = {},
): Promise<string> {
  const result = await run("git", args, {
    cwd: root,
    silent: options.silent ?? true,
    ...(options.env === undefined ? {} : { env: options.env }),
    ...(options.allowFailure === undefined
      ? {}
      : { allowFailure: options.allowFailure }),
  });
  return result.stdout.trim();
}

export async function authenticatedGit(
  root: string,
  args: string[],
  token: string,
  options: { silent?: boolean; allowFailure?: boolean } = {},
): Promise<string> {
  const authorization = Buffer.from(`x-access-token:${token}`).toString(
    "base64",
  );
  return git(root, args, {
    ...options,
    env: {
      GIT_CONFIG_COUNT: "1",
      GIT_CONFIG_KEY_0: "http.https://github.com/.extraheader",
      GIT_CONFIG_VALUE_0: `AUTHORIZATION: basic ${authorization}`,
    },
  });
}

export async function currentSha(root: string): Promise<string> {
  return git(root, ["rev-parse", "HEAD"]);
}

export async function currentBranch(root: string): Promise<string> {
  return git(root, ["branch", "--show-current"]);
}

export async function isClean(root: string): Promise<boolean> {
  return (await git(root, ["status", "--porcelain"])).length === 0;
}

export async function tagExists(root: string, tag: string): Promise<boolean> {
  const result = await run(
    "git",
    ["rev-parse", "--verify", "--quiet", `refs/tags/${tag}`],
    { cwd: root, silent: true, allowFailure: true },
  );
  return result.exitCode === 0;
}

export async function tagSha(root: string, tag: string): Promise<string> {
  return git(root, ["rev-list", "-n", "1", tag]);
}

export async function commitsBetween(
  root: string,
  baseSha: string,
  headSha = "HEAD",
): Promise<GitCommit[]> {
  const format = `%H${fieldSeparator}%B${recordSeparator}`;
  const output = await git(root, [
    "log",
    "--reverse",
    `--format=${format}`,
    `${baseSha}..${headSha}`,
  ]);
  if (!output) return [];

  return output
    .split(recordSeparator)
    .map((record) => record.trim())
    .filter(Boolean)
    .map((record) => {
      const separatorIndex = record.indexOf(fieldSeparator);
      invariant(separatorIndex > 0, "Could not parse git history", "GIT_PARSE");
      return {
        sha: record.slice(0, separatorIndex),
        message: record.slice(separatorIndex + 1).trim(),
      };
    });
}

export async function configureBotIdentity(root: string): Promise<void> {
  await git(root, ["config", "user.name", "ship-my-flutter[bot]"]);
  await git(root, [
    "config",
    "user.email",
    "ship-my-flutter[bot]@users.noreply.github.com",
  ]);
}
