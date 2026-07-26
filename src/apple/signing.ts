import crypto from "node:crypto";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import * as plist from "plist";
import { ShipError, invariant } from "../errors.js";
import { fileExists } from "../json.js";
import { run } from "../process.js";
import type { SigningCredentials } from "../types.js";

interface MobileProvision {
  UUID: string;
  Name: string;
  TeamIdentifier: string[];
  Entitlements: {
    "application-identifier": string;
  };
}

export interface InstalledProfile {
  bundleId: string;
  uuid: string;
  name: string;
  teamId: string;
  installedPath: string;
}

export interface SigningSession {
  keychainPath: string;
  keychainPassword: string;
  profiles: InstalledProfile[];
  exportOptionsPath: string;
  cleanup(): Promise<void>;
}

function parseProfileInput(
  value: string,
  bundleId: string,
): Record<string, string> {
  const trimmed = value.trim();
  if (trimmed.startsWith("{")) {
    const parsed = JSON.parse(trimmed) as Record<string, unknown>;
    for (const [key, profile] of Object.entries(parsed)) {
      invariant(
        typeof profile === "string" && profile.length > 0,
        `Provisioning profile for ${key} must be a Base64 string.`,
        "INVALID_PROFILE",
      );
    }
    return parsed as Record<string, string>;
  }
  return { [bundleId]: trimmed };
}

async function decodeProfile(filePath: string): Promise<MobileProvision> {
  const decoded = await run("security", ["cms", "-D", "-i", filePath], {
    silent: true,
  });
  return plist.parse(decoded.stdout) as unknown as MobileProvision;
}

async function removeIfExists(filePath: string): Promise<void> {
  try {
    await fs.rm(filePath, { force: true });
  } catch {
    // Cleanup is best effort and never hides the delivery result.
  }
}

export async function installSigningAssets(
  credentials: SigningCredentials,
  bundleId: string,
): Promise<SigningSession> {
  if (process.platform !== "darwin") {
    throw new ShipError(
      "iOS signing requires a macOS runner.",
      "MACOS_REQUIRED",
    );
  }
  const temporaryDirectory = await fs.mkdtemp(
    path.join(os.tmpdir(), "ship-my-flutter-signing-"),
  );
  const keychainPath = path.join(temporaryDirectory, "signing.keychain-db");
  const keychainPassword = crypto.randomBytes(32).toString("hex");
  const certificatePath = path.join(temporaryDirectory, "distribution.p12");
  const profilesDirectory = path.join(
    os.homedir(),
    "Library",
    "MobileDevice",
    "Provisioning Profiles",
  );
  const installedPaths: string[] = [];
  let previousKeychains: string[] | undefined;
  let keychainCreated = false;

  const cleanup = async (): Promise<void> => {
    for (const installedPath of installedPaths) {
      await removeIfExists(installedPath);
    }
    if (previousKeychains) {
      await run(
        "security",
        ["list-keychains", "-d", "user", "-s", ...previousKeychains],
        {
          silent: true,
          allowFailure: true,
        },
      );
    }
    if (keychainCreated) {
      await run("security", ["delete-keychain", keychainPath], {
        silent: true,
        allowFailure: true,
      });
    }
    await fs.rm(temporaryDirectory, { recursive: true, force: true });
  };

  try {
    await fs.writeFile(
      certificatePath,
      Buffer.from(credentials.certificateBase64, "base64"),
      { mode: 0o600 },
    );
    keychainCreated = true;
    await run("security", [
      "create-keychain",
      "-p",
      keychainPassword,
      keychainPath,
    ]);
    await run("security", [
      "set-keychain-settings",
      "-lut",
      "21600",
      keychainPath,
    ]);
    await run("security", [
      "unlock-keychain",
      "-p",
      keychainPassword,
      keychainPath,
    ]);
    await run("security", [
      "import",
      certificatePath,
      "-P",
      credentials.certificatePassword,
      "-A",
      "-t",
      "cert",
      "-f",
      "pkcs12",
      "-k",
      keychainPath,
    ]);
    await run("security", [
      "set-key-partition-list",
      "-S",
      "apple-tool:,apple:,codesign:",
      "-s",
      "-k",
      keychainPassword,
      keychainPath,
    ]);
    const existingKeychains = await run(
      "security",
      ["list-keychains", "-d", "user"],
      {
        silent: true,
      },
    );
    previousKeychains = existingKeychains.stdout
      .split("\n")
      .map((line) => line.trim().replace(/^"|"$/gu, ""))
      .filter(Boolean);
    await run("security", [
      "list-keychains",
      "-d",
      "user",
      "-s",
      keychainPath,
      ...previousKeychains,
    ]);

    const profileInput = parseProfileInput(
      credentials.provisioningProfiles,
      bundleId,
    );
    await fs.mkdir(profilesDirectory, { recursive: true });
    const profiles: InstalledProfile[] = [];
    for (const [declaredBundleId, base64] of Object.entries(profileInput)) {
      const sourcePath = path.join(
        temporaryDirectory,
        `${crypto.randomUUID()}.mobileprovision`,
      );
      await fs.writeFile(sourcePath, Buffer.from(base64, "base64"), {
        mode: 0o600,
      });
      const profile = await decodeProfile(sourcePath);
      const applicationIdentifier =
        profile.Entitlements["application-identifier"];
      const actualBundleId = applicationIdentifier.replace(
        `${profile.TeamIdentifier[0]}.`,
        "",
      );
      invariant(
        actualBundleId === declaredBundleId,
        `Provisioning profile "${profile.Name}" is for ${actualBundleId}, not ${declaredBundleId}.`,
        "PROFILE_BUNDLE_ID_MISMATCH",
      );
      const installedPath = path.join(
        profilesDirectory,
        `${profile.UUID}.mobileprovision`,
      );
      if (await fileExists(installedPath)) {
        invariant(
          (await fs.readFile(installedPath)).equals(
            await fs.readFile(sourcePath),
          ),
          `A different provisioning profile already exists at ${installedPath}.`,
          "PROFILE_COLLISION",
        );
      } else {
        await fs.copyFile(sourcePath, installedPath);
        installedPaths.push(installedPath);
      }
      profiles.push({
        bundleId: declaredBundleId,
        uuid: profile.UUID,
        name: profile.Name,
        teamId: profile.TeamIdentifier[0]!,
        installedPath,
      });
    }
    invariant(profiles.length > 0, "No provisioning profiles supplied.");
    const teamIds = new Set(profiles.map((profile) => profile.teamId));
    invariant(
      teamIds.size === 1,
      "All provisioning profiles must belong to the same Apple team.",
      "PROFILE_TEAM_MISMATCH",
    );

    const exportOptionsPath = path.join(
      temporaryDirectory,
      "ExportOptions.plist",
    );
    const exportOptions = plist.build({
      method: "app-store-connect",
      destination: "export",
      signingStyle: "manual",
      signingCertificate: "Apple Distribution",
      teamID: profiles[0]!.teamId,
      provisioningProfiles: Object.fromEntries(
        profiles.map((profile) => [profile.bundleId, profile.name]),
      ),
      uploadSymbols: true,
      compileBitcode: false,
    });
    await fs.writeFile(exportOptionsPath, exportOptions, "utf8");

    return {
      keychainPath,
      keychainPassword,
      profiles,
      exportOptionsPath,
      cleanup,
    };
  } catch (error) {
    await cleanup();
    throw error;
  }
}
