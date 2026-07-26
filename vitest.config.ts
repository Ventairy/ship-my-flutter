import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    coverage: {
      provider: "v8",
      reporter: ["text", "json-summary"],
      // These macOS/Xcode boundaries are covered by fixture and live-release
      // validation rather than by platform-mocking unit tests.
      exclude: [
        "src/apple/project.ts",
        "src/apple/signing.ts",
        "src/apple/upload.ts",
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 75,
        statements: 80,
      },
    },
  },
});
