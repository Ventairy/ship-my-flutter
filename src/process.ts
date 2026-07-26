import { spawn } from "node:child_process";
import { ShipError } from "./errors.js";

export interface RunOptions {
  cwd?: string;
  env?: NodeJS.ProcessEnv;
  input?: string;
  silent?: boolean;
  allowFailure?: boolean;
}

export interface RunResult {
  stdout: string;
  stderr: string;
  exitCode: number;
}

const sensitiveEnvironmentNames = [
  "GITHUB_TOKEN",
  "INPUT_GITHUB_TOKEN",
  "SMF_APP_STORE_CONNECT_KEY_ID",
  "SMF_APP_STORE_CONNECT_ISSUER_ID",
  "SMF_APP_STORE_CONNECT_PRIVATE_KEY_BASE64",
  "SMF_IOS_CERTIFICATE_BASE64",
  "SMF_IOS_CERTIFICATE_PASSWORD",
  "SMF_IOS_PROVISIONING_PROFILES_BASE64",
] as const;

export async function run(
  command: string,
  args: string[],
  options: RunOptions = {},
): Promise<RunResult> {
  return new Promise((resolve, reject) => {
    const childEnvironment = { ...process.env };
    for (const name of sensitiveEnvironmentNames) {
      delete childEnvironment[name];
    }
    const child = spawn(command, args, {
      cwd: options.cwd,
      env: { ...childEnvironment, ...options.env },
      stdio: ["pipe", "pipe", "pipe"],
    });

    let stdout = "";
    let stderr = "";

    child.stdout.on("data", (chunk: Buffer) => {
      const value = chunk.toString();
      stdout += value;
      if (!options.silent) process.stdout.write(value);
    });
    child.stderr.on("data", (chunk: Buffer) => {
      const value = chunk.toString();
      stderr += value;
      if (!options.silent) process.stderr.write(value);
    });
    child.on("error", (error) => reject(error));
    child.on("close", (code) => {
      const exitCode = code ?? 1;
      const result = { stdout, stderr, exitCode };
      if (exitCode !== 0 && !options.allowFailure) {
        reject(
          new ShipError(
            `${command} failed with exit code ${exitCode}`,
            "COMMAND_FAILED",
            { cause: result },
          ),
        );
      } else {
        resolve(result);
      }
    });

    if (options.input !== undefined) child.stdin.end(options.input);
    else child.stdin.end();
  });
}
