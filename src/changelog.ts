import type {
  ChangelogRelease,
  ConventionalChange,
  Platform,
} from "./types.js";

const sectionNames: Record<string, string> = {
  feat: "Features",
  fix: "Bug Fixes",
  perf: "Performance",
  deps: "Dependencies",
};

export function formatChange(change: ConventionalChange): string {
  const scope = change.scope ? `**${change.scope}:** ` : "";
  const breaking = change.breaking ? "**BREAKING:** " : "";
  return `- ${breaking}${scope}${change.description} (${change.sha.slice(0, 7)})`;
}

export function releaseNotesMarkdown(
  platform: Platform,
  release: ChangelogRelease,
): string {
  const grouped = new Map<string, ConventionalChange[]>();
  for (const change of release.changes) {
    const section = sectionNames[change.type] ?? "Other Changes";
    grouped.set(section, [...(grouped.get(section) ?? []), change]);
  }

  const sections = [...grouped.entries()]
    .map(
      ([name, changes]) =>
        `## ${name}\n\n${changes.map(formatChange).join("\n")}`,
    )
    .join("\n\n");
  const platformName = platform === "ios" ? "iOS" : platform;
  return `# ${platformName} ${release.version}\n\n${sections}\n`;
}

export function releasePullRequestBody(
  platform: Platform,
  release: ChangelogRelease,
): string {
  const notes = releaseNotesMarkdown(platform, release);
  return [
    "<!-- ship-my-flutter:release-pr -->",
    notes.trim(),
    "",
    "## Delivery",
    "",
    "- [ ] The TestFlight candidate receipt is committed",
    "- [ ] The candidate has been tested",
    "- [ ] Store release notes have been reviewed",
    "",
    "Merging this PR promotes the exact committed TestFlight candidate. If build inputs change after the candidate is uploaded, ship-my-flutter refuses promotion until a new candidate is produced.",
  ].join("\n");
}
