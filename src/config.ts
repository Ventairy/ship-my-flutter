import path from "node:path";
import semver from "semver";
import { z } from "zod";
import { ShipError } from "./errors.js";
import { readJson, readYaml } from "./json.js";
import { resolveShipPaths } from "./paths.js";
import type {
  ChangelogManifest,
  ShipConfig,
  ShipManifest,
  StoreReleaseNotes,
} from "./types.js";

const relativePath = z
  .string()
  .min(1)
  .refine((value) => !path.isAbsolute(value), "must be a relative path")
  .refine(
    (value) => !value.split(/[\\/]/u).includes(".."),
    "must stay inside the repository",
  );

const managedFlutterBuildArguments = [
  "--build-name",
  "--build-number",
  "--export-options-plist",
  "--release",
  "--debug",
  "--profile",
  "--flavor",
  "--pub",
  "--no-pub",
];

const buildArgument = z
  .string()
  .refine(
    (value) =>
      !managedFlutterBuildArguments.some(
        (managed) => value === managed || value.startsWith(`${managed}=`),
      ),
    "This flag is managed by ship-my-flutter and cannot be set in buildArgs",
  );

const stableVersion = z
  .string()
  .refine(
    (value) =>
      semver.valid(value) !== null &&
      semver.prerelease(value) === null &&
      (semver.parse(value)?.build.length ?? 0) === 0,
    "must be a stable major.minor.patch version",
  );

const gitSha = z.string().regex(/^(?:[a-f0-9]{40}|[a-f0-9]{64})$/u);

const configSchema = z.object({
  schemaVersion: z.literal(1),
  targetBranch: z.string().min(1).default("main"),
  releaseBranchPrefix: z.string().min(1).default("ship-my-flutter"),
  hooks: z
    .object({
      beforeReleasePr: relativePath.optional(),
    })
    .default({}),
  platforms: z.object({
    ios: z.object({
      enabled: z.boolean().default(true),
      projectPath: relativePath.default("."),
      bundleId: z.string().min(1).optional(),
      scheme: z.string().min(1).optional(),
      buildArgs: z.array(buildArgument).default([]),
      testflight: z
        .object({
          groups: z.array(z.string().min(1)).default([]),
          waitTimeoutMinutes: z.number().int().min(5).max(180).default(45),
        })
        .default({ groups: [], waitTimeoutMinutes: 45 }),
      appStore: z
        .object({
          mode: z
            .enum(["submit-for-review", "upload-only"])
            .default("upload-only"),
          releaseType: z
            .enum(["manual", "automatic", "scheduled"])
            .default("manual"),
          earliestReleaseDate: z.string().datetime().optional(),
        })
        .superRefine((value, context) => {
          if (
            value.releaseType === "scheduled" &&
            value.earliestReleaseDate === undefined
          ) {
            context.addIssue({
              code: "custom",
              path: ["earliestReleaseDate"],
              message: "is required when releaseType is scheduled",
            });
          }
          if (
            value.releaseType !== "scheduled" &&
            value.earliestReleaseDate !== undefined
          ) {
            context.addIssue({
              code: "custom",
              path: ["earliestReleaseDate"],
              message: "is only valid when releaseType is scheduled",
            });
          }
        })
        .default({
          mode: "upload-only",
          releaseType: "manual",
        }),
    }),
  }),
});

const platformManifestSchema = z.object({
  version: stableVersion,
  baselineSha: gitSha,
  pendingRelease: z.boolean(),
});

const manifestSchema = z.object({
  schemaVersion: z.literal(1),
  platforms: z.object({
    ios: platformManifestSchema,
  }),
});

const conventionalChangeSchema = z.object({
  sha: gitSha,
  type: z.string().min(1),
  scope: z.string().nullable(),
  description: z.string().min(1),
  body: z.string().nullable(),
  breaking: z.boolean(),
  bump: z.enum(["major", "minor", "patch"]).nullable(),
  platforms: z.array(z.literal("ios")),
  releaseAs: stableVersion.optional(),
});

const changelogReleaseSchema = z.object({
  version: stableVersion,
  preparedAt: z.string().datetime(),
  baseSha: gitSha,
  headSha: gitSha,
  changes: z.array(conventionalChangeSchema).min(1),
});

const changelogReleasesSchema = z
  .record(z.string(), changelogReleaseSchema)
  .superRefine((releases, context) => {
    for (const [version, release] of Object.entries(releases)) {
      if (version !== release.version) {
        context.addIssue({
          code: "custom",
          path: [version, "version"],
          message: `must match its release key ${version}`,
        });
      }
    }
  });

const changelogSchema = z.object({
  schemaVersion: z.literal(1),
  platforms: z.object({
    ios: z.object({
      releases: changelogReleasesSchema,
    }),
  }),
});

const notesSchema = z.record(
  z.enum(["ios"]),
  z.record(z.string(), z.record(z.string(), z.string().min(1).max(4000))),
);

function parse<T>(schema: z.ZodType<T>, value: unknown, source: string): T {
  const result = schema.safeParse(value);
  if (!result.success) {
    throw new ShipError(
      `${source} is invalid:\n${z.prettifyError(result.error)}`,
      "INVALID_CONFIG",
    );
  }
  return result.data;
}

export async function loadConfig(root = process.cwd()): Promise<ShipConfig> {
  const paths = resolveShipPaths(root);
  return parse(configSchema, await readYaml(paths.config), paths.config);
}

export async function loadManifest(
  root = process.cwd(),
): Promise<ShipManifest> {
  const paths = resolveShipPaths(root);
  return parse(manifestSchema, await readJson(paths.manifest), paths.manifest);
}

export async function loadChangelog(
  root = process.cwd(),
): Promise<ChangelogManifest> {
  const paths = resolveShipPaths(root);
  return parse(
    changelogSchema,
    await readJson(paths.changelog),
    paths.changelog,
  );
}

export async function loadStoreReleaseNotes(
  root = process.cwd(),
): Promise<StoreReleaseNotes> {
  const paths = resolveShipPaths(root);
  return parse(
    notesSchema,
    await readJson(paths.storeReleaseNotes),
    paths.storeReleaseNotes,
  );
}

export function validateConfig(value: unknown): ShipConfig {
  return parse(configSchema, value, "configuration");
}

export function validateManifest(value: unknown): ShipManifest {
  return parse(manifestSchema, value, "manifest");
}

export function validateChangelog(value: unknown): ChangelogManifest {
  return parse(changelogSchema, value, "changelog");
}

export function validateStoreReleaseNotes(value: unknown): StoreReleaseNotes {
  return parse(notesSchema, value, "store release notes");
}
