import { CommitParser } from "conventional-commits-parser";
import semver from "semver";
import type { Bump, ConventionalChange, Platform } from "./types.js";

const platformScopes = new Set([
  "ios",
  "android",
  "macos",
  "windows",
  "linux",
  "web",
]);
const parser = new CommitParser();

function platformForScope(scope: string | null): Platform[] {
  if (!scope) return ["ios"];
  const scopes = scope
    .toLowerCase()
    .split(/[,/\\|]/u)
    .map((value) => value.trim())
    .filter(Boolean);
  const explicitPlatforms = scopes.filter((value) => platformScopes.has(value));
  if (explicitPlatforms.length === 0) return ["ios"];
  return explicitPlatforms.includes("ios") ? ["ios"] : [];
}

function bumpFor(type: string | null, breaking: boolean): Bump | null {
  if (breaking) return "major";
  switch (type?.toLowerCase()) {
    case "feat":
      return "minor";
    case "fix":
    case "perf":
    case "deps":
      return "patch";
    default:
      return null;
  }
}

function footerValue(message: string, platform: Platform): string | undefined {
  const platformMatch = message.match(
    new RegExp(`^Release-As-${platform}:\\s*(\\S+)\\s*$`, "imu"),
  );
  const globalMatch = message.match(/^Release-As:\s*(\S+)\s*$/imu);
  const value = platformMatch?.[1] ?? globalMatch?.[1];
  return value &&
    semver.valid(value) &&
    semver.prerelease(value) === null &&
    (semver.parse(value)?.build.length ?? 0) === 0
    ? value
    : undefined;
}

export function parseConventionalCommit(
  sha: string,
  message: string,
): ConventionalChange {
  const parsed = parser.parse(message);
  const conventionalHeader = message
    .split("\n", 1)[0]
    ?.match(/^([a-z][a-z0-9-]*)(?:\(([^)]+)\))?(!)?:\s*(.+)$/iu);
  const breaking =
    conventionalHeader?.[3] === "!" ||
    parsed.notes.some((note) =>
      /^(?:BREAKING CHANGE|BREAKING-CHANGE)$/iu.test(note.title),
    );
  const scope = conventionalHeader?.[2] ?? parsed.scope ?? null;
  const type = conventionalHeader?.[1] ?? parsed.type ?? "other";
  const platforms = platformForScope(scope);
  const releaseAs = footerValue(message, "ios");

  return {
    sha,
    type,
    scope,
    description:
      conventionalHeader?.[4] ??
      parsed.subject ??
      parsed.header ??
      message.split("\n")[0] ??
      "",
    body: parsed.body ?? null,
    breaking,
    bump: bumpFor(type, breaking),
    platforms,
    ...(releaseAs ? { releaseAs } : {}),
  };
}

export function highestBump(changes: ConventionalChange[]): Bump | null {
  const rank: Record<Bump, number> = { patch: 1, minor: 2, major: 3 };
  let result: Bump | null = null;
  for (const change of changes) {
    if (change.bump && (!result || rank[change.bump] > rank[result])) {
      result = change.bump;
    }
  }
  return result;
}
