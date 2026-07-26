import { describe, expect, it } from "vitest";
import { highestBump, parseConventionalCommit } from "../src/conventional.js";

describe("platform-scoped Conventional Commits", () => {
  it.each([
    ["feat: shared feature", ["ios"], "minor"],
    ["feat(auth): shared scoped feature", ["ios"], "minor"],
    ["fix(ios): iPhone fix", ["ios"], "patch"],
    ["fix(android): Android-only fix", [], "patch"],
    ["fix(web): browser-only fix", [], "patch"],
    ["perf(ios,android): faster startup", ["ios"], "patch"],
    ["chore(ios): maintenance", ["ios"], null],
  ])("parses %s", (message, platforms, bump) => {
    const change = parseConventionalCommit("abcdef123456", message);
    expect(change.platforms).toEqual(platforms);
    expect(change.bump).toBe(bump);
  });

  it("treats a breaking footer as a major release", () => {
    const change = parseConventionalCommit(
      "abcdef123456",
      "refactor(ios): replace storage\n\nBREAKING CHANGE: old data is unsupported",
    );
    expect(change.breaking).toBe(true);
    expect(change.bump).toBe("major");
  });

  it("supports global and platform Release-As footers", () => {
    expect(
      parseConventionalCommit("a", "chore: release\n\nRelease-As: 2.0.0")
        .releaseAs,
    ).toBe("2.0.0");
    expect(
      parseConventionalCommit("b", "chore: release\n\nRelease-As-ios: 3.0.0")
        .releaseAs,
    ).toBe("3.0.0");
  });

  it("ignores prerelease and build-metadata Release-As values", () => {
    expect(
      parseConventionalCommit("a", "chore: release\n\nRelease-As: 2.0.0-beta.1")
        .releaseAs,
    ).toBeUndefined();
    expect(
      parseConventionalCommit("b", "chore: release\n\nRelease-As: 2.0.0+7")
        .releaseAs,
    ).toBeUndefined();
  });

  it("selects the highest required bump", () => {
    const changes = [
      parseConventionalCommit("a", "fix: one"),
      parseConventionalCommit("b", "feat: two"),
      parseConventionalCommit("c", "fix!: three"),
    ];
    expect(highestBump(changes)).toBe("major");
  });
});
