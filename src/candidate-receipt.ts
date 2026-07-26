import { z } from "zod";
import { ShipError } from "./errors.js";
import { readJson } from "./json.js";
import type { CandidateReceipt } from "./types.js";

const receiptSchema = z.object({
  schemaVersion: z.literal(1),
  platform: z.literal("ios"),
  version: z.string().regex(/^\d+\.\d+\.\d+$/u),
  buildNumber: z.string().regex(/^\d+$/u),
  buildId: z.string().min(1),
  appId: z.string().min(1),
  bundleId: z.string().min(1),
  sourceSha: z.string().regex(/^(?:[a-f0-9]{40}|[a-f0-9]{64})$/u),
  sourceFingerprint: z.string().regex(/^[a-f0-9]{64}$/u),
  ipaSha256: z.string().regex(/^[a-f0-9]{64}$/u),
  uploadedAt: z.string().datetime(),
  processingState: z.literal("VALID"),
  testflightGroups: z.array(z.string().min(1)),
});

export function validateCandidateReceipt(
  value: unknown,
  source = "candidate receipt",
): CandidateReceipt {
  const result = receiptSchema.safeParse(value);
  if (!result.success) {
    throw new ShipError(
      `${source} is invalid:\n${z.prettifyError(result.error)}`,
      "INVALID_CANDIDATE_RECEIPT",
    );
  }
  return result.data;
}

export async function loadCandidateReceipt(
  filePath: string,
): Promise<CandidateReceipt> {
  return validateCandidateReceipt(await readJson<unknown>(filePath), filePath);
}
