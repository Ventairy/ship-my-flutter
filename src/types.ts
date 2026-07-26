export const supportedPlatforms = ["ios"] as const;

export type Platform = (typeof supportedPlatforms)[number];
export type Bump = "major" | "minor" | "patch";
export type ReleaseMode = "submit-for-review" | "upload-only";
export type StoreReleaseType = "manual" | "automatic" | "scheduled";

export interface IosConfig {
  enabled: boolean;
  projectPath: string;
  bundleId?: string;
  scheme?: string;
  buildArgs: string[];
  testflight: {
    groups: string[];
    waitTimeoutMinutes: number;
  };
  appStore: {
    mode: ReleaseMode;
    releaseType: StoreReleaseType;
    earliestReleaseDate?: string;
  };
}

export interface ShipConfig {
  schemaVersion: 1;
  targetBranch: string;
  releaseBranchPrefix: string;
  hooks: {
    beforeReleasePr?: string;
  };
  platforms: {
    ios: IosConfig;
  };
}

export interface PlatformManifest {
  version: string;
  baselineSha: string;
  pendingRelease: boolean;
}

export interface ShipManifest {
  schemaVersion: 1;
  platforms: {
    ios: PlatformManifest;
  };
}

export interface ConventionalChange {
  sha: string;
  type: string;
  scope: string | null;
  description: string;
  body: string | null;
  breaking: boolean;
  bump: Bump | null;
  platforms: Platform[];
  releaseAs?: string;
}

export interface ChangelogRelease {
  version: string;
  preparedAt: string;
  baseSha: string;
  headSha: string;
  changes: ConventionalChange[];
}

export interface PlatformChangelog {
  releases: Record<string, ChangelogRelease>;
}

export interface ChangelogManifest {
  schemaVersion: 1;
  platforms: {
    ios: PlatformChangelog;
  };
}

export type StoreReleaseNotes = Record<
  Platform,
  Record<string, Record<string, string>>
>;

export interface ReleasePlan {
  platform: Platform;
  currentVersion: string;
  nextVersion: string;
  bump: Bump;
  baseSha: string;
  headSha: string;
  changes: ConventionalChange[];
}

export interface CandidateReceipt {
  schemaVersion: 1;
  platform: "ios";
  version: string;
  buildNumber: string;
  buildId: string;
  appId: string;
  bundleId: string;
  sourceSha: string;
  sourceFingerprint: string;
  ipaSha256: string;
  uploadedAt: string;
  processingState: "VALID";
  testflightGroups: string[];
}

export interface GitHubContext {
  owner: string;
  repo: string;
  token: string;
}

export interface AppleCredentials {
  keyId: string;
  issuerId: string;
  privateKey: string;
}

export interface SigningCredentials {
  certificateBase64: string;
  certificatePassword: string;
  provisioningProfiles: string;
}

export interface CommandResult {
  phase: "noop" | "candidate" | "promote";
  platform?: Platform;
  version?: string;
  branch?: string;
  pullRequestNumber?: number;
}
