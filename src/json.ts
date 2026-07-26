import fs from "node:fs/promises";
import path from "node:path";
import YAML from "yaml";

export async function readJson<T>(filePath: string): Promise<T> {
  const source = await fs.readFile(filePath, "utf8");
  return JSON.parse(source) as T;
}

export async function writeJson(
  filePath: string,
  value: unknown,
): Promise<void> {
  await fs.mkdir(path.dirname(filePath), { recursive: true });
  await fs.writeFile(filePath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

export async function readYaml<T>(filePath: string): Promise<T> {
  const source = await fs.readFile(filePath, "utf8");
  return YAML.parse(source) as T;
}

export async function writeYaml(
  filePath: string,
  value: unknown,
  schemaUrl?: string,
): Promise<void> {
  await fs.mkdir(path.dirname(filePath), { recursive: true });
  const schemaDirective = schemaUrl
    ? `# yaml-language-server: $schema=${schemaUrl}\n\n`
    : "";
  await fs.writeFile(
    filePath,
    `${schemaDirective}${YAML.stringify(value)}`,
    "utf8",
  );
}

export async function fileExists(filePath: string): Promise<boolean> {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}
