import { Buffer } from "node:buffer";
import { ShipError, invariant } from "../errors.js";
import type { AppleCredentials, SigningCredentials } from "../types.js";

function required(env: NodeJS.ProcessEnv, name: string): string {
  const value = env[name]?.trim();
  if (!value) {
    throw new ShipError(
      `Missing required secret ${name}.`,
      "MISSING_CREDENTIAL",
    );
  }
  return value;
}

function decodeBase64(value: string, name: string): string {
  const decoded = Buffer.from(value, "base64").toString("utf8").trim();
  invariant(decoded, `${name} decoded to an empty value`, "INVALID_CREDENTIAL");
  return decoded;
}

export function appleCredentialsFromEnvironment(
  env = process.env,
): AppleCredentials {
  return {
    keyId: required(env, "SMF_APP_STORE_CONNECT_KEY_ID"),
    issuerId: required(env, "SMF_APP_STORE_CONNECT_ISSUER_ID"),
    privateKey: decodeBase64(
      required(env, "SMF_APP_STORE_CONNECT_PRIVATE_KEY_BASE64"),
      "SMF_APP_STORE_CONNECT_PRIVATE_KEY_BASE64",
    ),
  };
}

export function signingCredentialsFromEnvironment(
  env = process.env,
): SigningCredentials {
  return {
    certificateBase64: required(env, "SMF_IOS_CERTIFICATE_BASE64"),
    certificatePassword: required(env, "SMF_IOS_CERTIFICATE_PASSWORD"),
    provisioningProfiles: required(env, "SMF_IOS_PROVISIONING_PROFILES_BASE64"),
  };
}
