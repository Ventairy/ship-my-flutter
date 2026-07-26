import { describe, expect, it } from "vitest";
import { validateCandidateReceipt } from "../src/candidate-receipt.js";

function receipt(): Record<string, unknown> {
  return {
    schemaVersion: 1,
    platform: "ios",
    version: "1.2.3",
    buildNumber: "7",
    buildId: "build-7",
    appId: "app-1",
    bundleId: "dev.example.app",
    sourceSha: "a".repeat(40),
    sourceFingerprint: "b".repeat(64),
    ipaSha256: "c".repeat(64),
    uploadedAt: "2026-07-26T00:00:00.000Z",
    processingState: "VALID",
    testflightGroups: ["Internal"],
  };
}

describe("candidate receipts", () => {
  it("accepts the complete immutable receipt contract", () => {
    expect(validateCandidateReceipt(receipt())).toMatchObject({
      version: "1.2.3",
      buildId: "build-7",
    });
  });

  it("rejects malformed identity and digest fields", () => {
    expect(() =>
      validateCandidateReceipt({
        ...receipt(),
        buildNumber: "latest",
        sourceFingerprint: "short",
      }),
    ).toThrow(/candidate receipt is invalid/);
  });
});
