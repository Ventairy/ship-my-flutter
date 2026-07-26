import { describe, expect, it } from "vitest";
import { ShipError } from "../src/errors.js";
import {
  validateChangelog,
  validateConfig,
  validateManifest,
  validateStoreReleaseNotes,
} from "../src/config.js";

function validConfig(): unknown {
  return {
    schemaVersion: 1,
    targetBranch: "main",
    releaseBranchPrefix: "ship-my-flutter",
    hooks: {},
    platforms: {
      ios: {
        enabled: true,
        projectPath: ".",
        buildArgs: [],
        testflight: { groups: [], waitTimeoutMinutes: 45 },
        appStore: { mode: "submit-for-review", releaseType: "manual" },
      },
    },
  };
}

describe("configuration", () => {
  it("accepts the minimal generated configuration", () => {
    expect(validateConfig(validConfig()).platforms.ios.enabled).toBe(true);
  });

  it("rejects paths that escape the repository", () => {
    const config = validConfig() as {
      platforms: { ios: { projectPath: string } };
    };
    config.platforms.ios.projectPath = "../another-app";
    expect(() => validateConfig(config)).toThrow(ShipError);
  });

  it("rejects unsupported App Store modes", () => {
    const config = validConfig() as {
      platforms: { ios: { appStore: { mode: string } } };
    };
    config.platforms.ios.appStore.mode = "publish-now";
    expect(() => validateConfig(config)).toThrow(/submit-for-review/);
  });

  it("requires a date only for scheduled App Store releases", () => {
    const missingDate = validConfig() as {
      platforms: {
        ios: {
          appStore: {
            releaseType: string;
            earliestReleaseDate?: string;
          };
        };
      };
    };
    missingDate.platforms.ios.appStore.releaseType = "scheduled";
    expect(() => validateConfig(missingDate)).toThrow(
      /required when releaseType is scheduled/,
    );

    const unexpectedDate = validConfig() as typeof missingDate;
    unexpectedDate.platforms.ios.appStore.earliestReleaseDate =
      "2026-08-01T12:00:00.000Z";
    expect(() => validateConfig(unexpectedDate)).toThrow(
      /only valid when releaseType is scheduled/,
    );
  });

  it("does not allow custom arguments to override release identity", () => {
    const config = validConfig() as {
      platforms: { ios: { buildArgs: string[] } };
    };
    config.platforms.ios.buildArgs = ["--build-number=99"];
    expect(() => validateConfig(config)).toThrow(/managed by ship-my-flutter/);
    config.platforms.ios.buildArgs = ["--pub"];
    expect(() => validateConfig(config)).toThrow(/managed by ship-my-flutter/);
  });

  it("rejects iOS prerelease versions", () => {
    expect(() =>
      validateManifest({
        schemaVersion: 1,
        platforms: {
          ios: {
            version: "2.0.0-beta.1",
            baselineSha: "abcdef1",
            pendingRelease: false,
          },
        },
      }),
    ).toThrow(/stable major\.minor\.patch/);
  });

  it("validates changelog identity and nonempty localized notes", () => {
    expect(() =>
      validateChangelog({
        schemaVersion: 1,
        platforms: {
          ios: {
            releases: {
              "1.2.3": {
                version: "1.2.4",
                preparedAt: "2026-07-26T00:00:00.000Z",
                baseSha: "a".repeat(40),
                headSha: "b".repeat(40),
                changes: [
                  {
                    sha: "c".repeat(40),
                    type: "fix",
                    scope: "ios",
                    description: "Fix launch",
                    body: null,
                    breaking: false,
                    bump: "patch",
                    platforms: ["ios"],
                  },
                ],
              },
            },
          },
        },
      }),
    ).toThrow(/must match its release key/);
    expect(() =>
      validateStoreReleaseNotes({ ios: { "1.2.3": { "en-US": "" } } }),
    ).toThrow(/Too small/);
  });
});
