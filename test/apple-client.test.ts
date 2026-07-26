import crypto from "node:crypto";
import { describe, expect, it, vi } from "vitest";
import { AppStoreConnectClient } from "../src/apple/client.js";

const privateKey = crypto
  .generateKeyPairSync("ec", { namedCurve: "P-256" })
  .privateKey.export({ type: "pkcs8", format: "pem" })
  .toString();

function response(body: unknown, status = 200): Response {
  return new Response(status === 204 ? null : JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function clientWith(...responses: Response[]): {
  client: AppStoreConnectClient;
  fetchMock: ReturnType<typeof vi.fn>;
} {
  const fetchMock = vi.fn();
  for (const item of responses) fetchMock.mockResolvedValueOnce(item);
  return {
    client: new AppStoreConnectClient(
      { keyId: "KEY123", issuerId: "issuer", privateKey },
      fetchMock as typeof fetch,
    ),
    fetchMock,
  };
}

describe("App Store Connect client", () => {
  it("finds an app by exact bundle identifier", async () => {
    const { client, fetchMock } = clientWith(
      response({
        data: [
          {
            type: "apps",
            id: "app-1",
            attributes: {
              name: "Example",
              bundleId: "dev.example.app",
              sku: "example",
              primaryLocale: "en-US",
            },
          },
        ],
      }),
    );
    await expect(client.findApp("dev.example.app")).resolves.toMatchObject({
      id: "app-1",
    });
    expect(String(fetchMock.mock.calls[0]?.[0])).toContain(
      "filter%5BbundleId%5D=dev.example.app",
    );
  });

  it("rejects a missing app instead of guessing", async () => {
    const { client } = clientWith(response({ data: [] }));
    await expect(client.findApp("dev.example.missing")).rejects.toThrow(
      /No App Store Connect app found/,
    );
  });

  it("calculates the next integer build number", async () => {
    const { client } = clientWith(
      response({
        data: [
          {
            type: "preReleaseVersions",
            id: "pre-1",
            attributes: { version: "1.2.0", platform: "IOS" },
          },
        ],
      }),
      response({
        data: [
          {
            type: "builds",
            id: "build-1",
            attributes: { version: "8", processingState: "VALID" },
          },
          {
            type: "builds",
            id: "build-2",
            attributes: { version: "12", processingState: "VALID" },
          },
        ],
      }),
    );
    await expect(client.nextBuildNumber("app-1", "1.2.0")).resolves.toBe("13");
  });

  it("starts build numbering at one for a new marketing version", async () => {
    const { client } = clientWith(response({ data: [] }));
    await expect(client.nextBuildNumber("app-1", "9.0.0")).resolves.toBe("1");
  });

  it("follows App Store Connect collection pagination", async () => {
    const { client, fetchMock } = clientWith(
      response({
        data: [
          {
            type: "preReleaseVersions",
            id: "pre-1",
            attributes: { version: "1.0.0", platform: "IOS" },
          },
        ],
        links: {
          next: "https://api.appstoreconnect.apple.com/v1/preReleaseVersions?cursor=next",
        },
      }),
      response({
        data: [
          {
            type: "preReleaseVersions",
            id: "pre-2",
            attributes: { version: "2.0.0", platform: "IOS" },
          },
        ],
      }),
    );
    await expect(client.listPrereleaseVersions("app-1")).resolves.toHaveLength(
      2,
    );
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it("waits until the exact uploaded build is valid", async () => {
    const { client } = clientWith(
      response({
        data: [
          {
            type: "preReleaseVersions",
            id: "pre-1",
            attributes: { version: "1.2.0", platform: "IOS" },
          },
        ],
      }),
      response({
        data: [
          {
            type: "builds",
            id: "build-13",
            attributes: { version: "13", processingState: "VALID" },
          },
        ],
      }),
    );
    await expect(
      client.waitForBuild("app-1", "1.2.0", "13", 5, 0),
    ).resolves.toMatchObject({ id: "build-13" });
  });

  it("fails immediately when Apple marks a build invalid", async () => {
    const { client } = clientWith(
      response({
        data: [
          {
            type: "preReleaseVersions",
            id: "pre-1",
            attributes: { version: "1.2.0", platform: "IOS" },
          },
        ],
      }),
      response({
        data: [
          {
            type: "builds",
            id: "build-13",
            attributes: { version: "13", processingState: "INVALID" },
          },
        ],
      }),
    );
    await expect(
      client.waitForBuild("app-1", "1.2.0", "13", 5, 0),
    ).rejects.toThrow(/marked.*INVALID/);
  });

  it("updates or creates TestFlight localizations", async () => {
    const existing = clientWith(
      response({
        data: [
          {
            type: "betaBuildLocalizations",
            id: "localization-1",
            attributes: { locale: "en-US", whatsNew: "Old" },
          },
        ],
      }),
      response({
        data: {
          type: "betaBuildLocalizations",
          id: "localization-1",
          attributes: { locale: "en-US", whatsNew: "New" },
        },
      }),
    );
    await existing.client.setBetaBuildLocalization("build-1", "en-US", "New");
    expect(
      JSON.parse(
        (existing.fetchMock.mock.calls[1]?.[1] as RequestInit).body as string,
      ),
    ).toMatchObject({ data: { attributes: { whatsNew: "New" } } });

    const created = clientWith(
      response({ data: [] }),
      response({
        data: {
          type: "betaBuildLocalizations",
          id: "localization-2",
          attributes: { locale: "pt-BR", whatsNew: "Novo" },
        },
      }),
    );
    await created.client.setBetaBuildLocalization("build-1", "pt-BR", "Novo");
    expect(
      JSON.parse(
        (created.fetchMock.mock.calls[1]?.[1] as RequestInit).body as string,
      ),
    ).toMatchObject({
      data: {
        attributes: { locale: "pt-BR", whatsNew: "Novo" },
        relationships: { build: { data: { id: "build-1" } } },
      },
    });
  });

  it("assigns a build to every named TestFlight group", async () => {
    const { client, fetchMock } = clientWith(
      response({
        data: [
          {
            type: "betaGroups",
            id: "internal",
            attributes: { name: "Internal", isInternalGroup: true },
          },
          {
            type: "betaGroups",
            id: "external",
            attributes: { name: "External", isInternalGroup: false },
          },
        ],
      }),
      response({ data: [] }),
      response(null, 204),
      response({ data: [] }),
      response(null, 204),
    );
    await client.addBuildToGroups("app-1", "build-1", ["Internal", "External"]);
    expect(fetchMock).toHaveBeenCalledTimes(5);
    expect(String(fetchMock.mock.calls[2]?.[0])).toContain(
      "/v1/betaGroups/internal/relationships/builds",
    );
  });

  it("does not add a build that is already in a TestFlight group", async () => {
    const { client, fetchMock } = clientWith(
      response({
        data: [
          {
            type: "betaGroups",
            id: "internal",
            attributes: { name: "Internal", isInternalGroup: true },
          },
        ],
      }),
      response({ data: [{ type: "builds", id: "build-1" }] }),
    );
    await client.addBuildToGroups("app-1", "build-1", ["Internal"]);
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it("does nothing when no TestFlight groups are configured", async () => {
    const { client, fetchMock } = clientWith();
    await client.addBuildToGroups("app-1", "build-1", []);
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("creates an App Store version and attaches the tested build", async () => {
    const { client, fetchMock } = clientWith(
      response({ data: [] }),
      response({
        data: {
          type: "appStoreVersions",
          id: "version-1",
          attributes: {
            platform: "IOS",
            versionString: "2.0.0",
            appStoreState: "PREPARE_FOR_SUBMISSION",
            releaseType: "MANUAL",
          },
        },
      }),
      response(null, 204),
    );
    const version = await client.findOrCreateAppStoreVersion(
      "app-1",
      "2.0.0",
      "manual",
    );
    await client.attachBuildToVersion(version.id, "build-1");
    expect(version.id).toBe("version-1");
    expect(
      JSON.parse((fetchMock.mock.calls[2]?.[1] as RequestInit).body as string),
    ).toEqual({ data: { type: "builds", id: "build-1" } });
  });

  it("reads the build attached to an App Store version", async () => {
    const { client } = clientWith(
      response({ data: { type: "builds", id: "build-1" } }),
      response({ data: null }),
    );
    await expect(client.appStoreVersionBuildId("version-1")).resolves.toBe(
      "build-1",
    );
    await expect(
      client.appStoreVersionBuildId("version-2"),
    ).resolves.toBeUndefined();
  });

  it("reuses an existing App Store version", async () => {
    const { client, fetchMock } = clientWith(
      response({
        data: [
          {
            type: "appStoreVersions",
            id: "version-1",
            attributes: {
              platform: "IOS",
              versionString: "2.0.0",
              appStoreState: "PREPARE_FOR_SUBMISSION",
              releaseType: "MANUAL",
            },
          },
        ],
      }),
    );
    await expect(
      client.findOrCreateAppStoreVersion("app-1", "2.0.0", "manual"),
    ).resolves.toMatchObject({ id: "version-1" });
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it("updates the release policy of an editable App Store version", async () => {
    const { client, fetchMock } = clientWith(
      response({
        data: [
          {
            type: "appStoreVersions",
            id: "version-1",
            attributes: {
              platform: "IOS",
              versionString: "2.0.0",
              appStoreState: "PREPARE_FOR_SUBMISSION",
              releaseType: "MANUAL",
            },
          },
        ],
      }),
      response({
        data: {
          type: "appStoreVersions",
          id: "version-1",
          attributes: {
            platform: "IOS",
            versionString: "2.0.0",
            appStoreState: "PREPARE_FOR_SUBMISSION",
            releaseType: "AFTER_APPROVAL",
          },
        },
      }),
    );
    await expect(
      client.findOrCreateAppStoreVersion("app-1", "2.0.0", "automatic"),
    ).resolves.toMatchObject({
      attributes: { releaseType: "AFTER_APPROVAL" },
    });
    expect(
      JSON.parse((fetchMock.mock.calls[1]?.[1] as RequestInit).body as string),
    ).toMatchObject({
      data: { attributes: { releaseType: "AFTER_APPROVAL" } },
    });
  });

  it("updates existing localized App Store release notes", async () => {
    const { client, fetchMock } = clientWith(
      response({
        data: [
          {
            type: "appStoreVersionLocalizations",
            id: "store-loc-1",
            attributes: { locale: "en-US", whatsNew: "" },
          },
        ],
      }),
      response({
        data: {
          type: "appStoreVersionLocalizations",
          id: "store-loc-1",
          attributes: { locale: "en-US", whatsNew: "Ready" },
        },
      }),
    );
    await client.setAppStoreReleaseNotes("version-1", "en-US", "Ready");
    expect(String(fetchMock.mock.calls[1]?.[0])).toContain(
      "/v1/appStoreVersionLocalizations/store-loc-1",
    );
  });

  it("rejects notes for a locale missing from App Store Connect", async () => {
    const { client } = clientWith(response({ data: [] }));
    await expect(
      client.setAppStoreReleaseNotes("version-1", "pt-BR", "Pronto"),
    ).rejects.toThrow(/locale "pt-BR" does not exist/);
  });

  it("creates and submits the current review-submission workflow", async () => {
    const { client, fetchMock } = clientWith(
      response({ data: [], included: [] }),
      response({
        data: {
          type: "reviewSubmissions",
          id: "submission-1",
          attributes: { state: "READY_FOR_REVIEW" },
        },
      }),
      response({
        data: {
          type: "reviewSubmissionItems",
          id: "item-1",
          attributes: { state: "READY_FOR_REVIEW" },
        },
      }),
      response({
        data: {
          type: "reviewSubmissions",
          id: "submission-1",
          attributes: { state: "WAITING_FOR_REVIEW" },
        },
      }),
    );

    await expect(
      client.submitVersionForReview("app-1", "version-1"),
    ).resolves.toBe("submission-1");
    const finalBody = JSON.parse(
      (fetchMock.mock.calls[3]?.[1] as RequestInit).body as string,
    ) as { data: { attributes: { submitted: boolean } } };
    expect(finalBody.data.attributes.submitted).toBe(true);
  });

  it("reuses an active review submission for the same version", async () => {
    const { client, fetchMock } = clientWith(
      response({
        data: [
          {
            type: "reviewSubmissions",
            id: "submission-1",
            attributes: { state: "WAITING_FOR_REVIEW" },
            relationships: {
              appStoreVersionForReview: {
                data: { type: "appStoreVersions", id: "version-1" },
              },
            },
          },
        ],
        included: [
          {
            type: "appStoreVersions",
            id: "version-1",
            attributes: {
              platform: "IOS",
              versionString: "1.0.0",
              appStoreState: "WAITING_FOR_REVIEW",
              releaseType: "MANUAL",
            },
          },
        ],
      }),
    );

    await expect(
      client.submitVersionForReview("app-1", "version-1"),
    ).resolves.toBe("submission-1");
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it("surfaces structured Apple errors without leaking credentials", async () => {
    const { client } = clientWith(
      response(
        {
          errors: [
            {
              code: "ENTITY_ERROR",
              title: "The request is invalid",
              detail: "Missing metadata",
            },
          ],
        },
        409,
      ),
    );
    await expect(client.findApp("dev.example.app")).rejects.toThrow(
      /ENTITY_ERROR.*Missing metadata/,
    );
  });
});
