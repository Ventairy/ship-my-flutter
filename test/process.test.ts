import { describe, expect, it } from "vitest";
import { run } from "../src/process.js";

describe("child-process security", () => {
  it("does not expose credential environment variables to subprocesses", async () => {
    const previous = {
      github: process.env.GITHUB_TOKEN,
      certificate: process.env.SMF_IOS_CERTIFICATE_PASSWORD,
    };
    process.env.GITHUB_TOKEN = "github-secret";
    process.env.SMF_IOS_CERTIFICATE_PASSWORD = "certificate-secret";
    try {
      const result = await run(
        process.execPath,
        [
          "-e",
          "process.stdout.write(JSON.stringify({github:process.env.GITHUB_TOKEN,certificate:process.env.SMF_IOS_CERTIFICATE_PASSWORD}))",
        ],
        { silent: true },
      );
      expect(JSON.parse(result.stdout)).toEqual({});
    } finally {
      if (previous.github === undefined) delete process.env.GITHUB_TOKEN;
      else process.env.GITHUB_TOKEN = previous.github;
      if (previous.certificate === undefined) {
        delete process.env.SMF_IOS_CERTIFICATE_PASSWORD;
      } else {
        process.env.SMF_IOS_CERTIFICATE_PASSWORD = previous.certificate;
      }
    }
  });

  it("omits command arguments from failure messages", async () => {
    await expect(
      run(process.execPath, ["-e", "process.exit(1)", "certificate-password"], {
        silent: true,
      }),
    ).rejects.not.toThrow(/certificate-password/);
  });
});
