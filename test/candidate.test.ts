import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, it, vi } from "vitest";
import { createIosCandidate } from "../src/apple/candidate.js";
import type { AppStoreConnectClient } from "../src/apple/client.js";
import { sourceFingerprint } from "../src/fingerprint.js";
import { currentSha, git } from "../src/git.js";
import { initialize } from "../src/init.js";
import { writeJson } from "../src/json.js";
import { candidatePath } from "../src/paths.js";
import type {
  CandidateReceipt,
  ShipManifest,
  StoreReleaseNotes,
} from "../src/types.js";

const temporaryDirectories: string[] = [];

afterEach(async () => {
  await Promise.all(
    temporaryDirectories
      .splice(0)
      .map((directory) => fs.rm(directory, { recursive: true, force: true })),
  );
});

describe("TestFlight candidates", () => {
  it("refreshes localized notes when reusing the exact valid build", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "smf-candidate-"));
    temporaryDirectories.push(root);
    await fs.mkdir(path.join(root, "ios"));
    await fs.writeFile(
      path.join(root, "pubspec.yaml"),
      "name: example\nversion: 1.0.0+1\n",
    );
    await fs.writeFile(path.join(root, "pubspec.lock"), "# fixture lockfile\n");
    await git(root, ["init", "-b", "main"]);
    await git(root, ["config", "user.name", "Test"]);
    await git(root, ["config", "user.email", "test@example.com"]);
    await git(root, ["add", "."]);
    await git(root, ["commit", "-m", "chore: bootstrap"]);
    await initialize({ root, bundleId: "dev.example.app" });
    await git(root, ["add", "."]);
    await git(root, ["commit", "-m", "chore: configure releases"]);
    await git(root, ["checkout", "-b", "ship-my-flutter/ios"]);

    const baselineSha = await currentSha(root);
    const manifest: ShipManifest = {
      schemaVersion: 1,
      platforms: {
        ios: {
          version: "1.1.0",
          baselineSha,
          pendingRelease: true,
        },
      },
    };
    const notes: StoreReleaseNotes = {
      ios: { "1.1.0": { "en-US": "Try the refreshed notes." } },
    };
    await writeJson(
      path.join(root, ".ship-my-flutter", "manifest.json"),
      manifest,
    );
    await writeJson(
      path.join(root, ".ship-my-flutter", "store-release-notes.json"),
      notes,
    );
    await writeJson(path.join(root, ".ship-my-flutter", "changelog.json"), {
      schemaVersion: 1,
      platforms: {
        ios: {
          releases: {
            "1.1.0": {
              version: "1.1.0",
              preparedAt: "2026-07-26T00:00:00.000Z",
              baseSha: baselineSha,
              headSha: baselineSha,
              changes: [
                {
                  sha: baselineSha,
                  type: "feat",
                  scope: "ios",
                  description: "Fixture release",
                  body: null,
                  breaking: false,
                  bump: "minor",
                  platforms: ["ios"],
                },
              ],
            },
          },
        },
      },
    });

    const fingerprint = await sourceFingerprint(root);
    const receipt: CandidateReceipt = {
      schemaVersion: 1,
      platform: "ios",
      version: "1.1.0",
      buildNumber: "7",
      buildId: "build-7",
      appId: "app-1",
      bundleId: "dev.example.app",
      sourceSha: baselineSha,
      sourceFingerprint: fingerprint,
      ipaSha256: "a".repeat(64),
      uploadedAt: "2026-07-26T00:00:00.000Z",
      processingState: "VALID",
      testflightGroups: [],
    };
    await writeJson(candidatePath(root, "ios", "1.1.0"), receipt);
    await git(root, ["add", "."]);
    await git(root, ["commit", "-m", "chore(ios): prepare fixture release"]);

    const client = {
      findApp: vi.fn().mockResolvedValue({ id: "app-1" }),
      request: vi.fn().mockResolvedValue({
        data: {
          attributes: { processingState: "VALID", version: "7" },
        },
      }),
      setBetaBuildLocalization: vi.fn().mockResolvedValue(undefined),
      addBuildToGroups: vi.fn().mockResolvedValue(undefined),
    } as unknown as AppStoreConnectClient;

    await expect(
      createIosCandidate({
        root,
        appleCredentials: {
          keyId: "unused",
          issuerId: "unused",
          privateKey: "unused",
        },
        signingCredentials: {
          certificateBase64: "unused",
          certificatePassword: "unused",
          provisioningProfiles: "unused",
        },
        client,
      }),
    ).resolves.toEqual(receipt);
    expect(client.setBetaBuildLocalization).toHaveBeenCalledWith(
      "build-7",
      "en-US",
      "Try the refreshed notes.",
    );

    await git(root, ["checkout", "main"]);
    await expect(
      createIosCandidate({
        root,
        appleCredentials: {
          keyId: "unused",
          issuerId: "unused",
          privateKey: "unused",
        },
        signingCredentials: {
          certificateBase64: "unused",
          certificatePassword: "unused",
          provisioningProfiles: "unused",
        },
        client,
      }),
    ).rejects.toThrow(/only runs on ship-my-flutter\/ios/);
  });
});
