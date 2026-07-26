import { importPKCS8, SignJWT } from "jose";
import { ShipError, invariant } from "../errors.js";
import type { AppleCredentials, StoreReleaseType } from "../types.js";

export interface ApiResource<TAttributes = Record<string, unknown>> {
  type: string;
  id: string;
  attributes: TAttributes;
}

interface CollectionResponse<T> {
  data: T[];
  links?: {
    next?: string | null;
  };
}

interface ResourceResponse<T> {
  data: T;
}

interface IncludedResponse<T, TIncluded> {
  data: T[];
  included?: TIncluded[];
}

interface ApiErrorDocument {
  errors?: Array<{
    status?: string;
    code?: string;
    title?: string;
    detail?: string;
    source?: { pointer?: string };
  }>;
}

export interface AppAttributes {
  name: string;
  bundleId: string;
  sku: string;
  primaryLocale: string;
}

export interface BuildAttributes {
  version: string;
  uploadedDate: string;
  processingState: "PROCESSING" | "FAILED" | "INVALID" | "VALID";
  expired: boolean;
  usesNonExemptEncryption?: boolean;
}

export interface PrereleaseVersionAttributes {
  version: string;
  platform: "IOS";
}

export interface BetaGroupAttributes {
  name: string;
  isInternalGroup: boolean;
}

export interface AppStoreVersionAttributes {
  platform: "IOS";
  versionString: string;
  appStoreState: string;
  releaseType: "MANUAL" | "AFTER_APPROVAL" | "SCHEDULED";
  earliestReleaseDate?: string;
}

export interface ReviewSubmissionAttributes {
  platform?: "IOS";
  state: string;
  submittedDate?: string;
}

export class AppStoreConnectClient {
  readonly baseUrl = "https://api.appstoreconnect.apple.com";

  constructor(
    private readonly credentials: AppleCredentials,
    private readonly fetchImplementation: typeof fetch = fetch,
  ) {}

  private async token(): Promise<string> {
    const key = await importPKCS8(this.credentials.privateKey, "ES256");
    return new SignJWT({})
      .setProtectedHeader({
        alg: "ES256",
        kid: this.credentials.keyId,
        typ: "JWT",
      })
      .setIssuer(this.credentials.issuerId)
      .setAudience("appstoreconnect-v1")
      .setIssuedAt()
      .setExpirationTime("19m")
      .sign(key);
  }

  async request<T>(method: string, path: string, body?: unknown): Promise<T> {
    const url = new URL(path, this.baseUrl);
    invariant(
      url.origin === new URL(this.baseUrl).origin,
      "App Store Connect pagination returned an unexpected origin.",
      "APP_STORE_CONNECT_ORIGIN",
    );
    const response = await this.fetchImplementation(url, {
      method,
      headers: {
        Authorization: `Bearer ${await this.token()}`,
        Accept: "application/json",
        ...(body === undefined ? {} : { "Content-Type": "application/json" }),
      },
      ...(body === undefined ? {} : { body: JSON.stringify(body) }),
    });
    if (!response.ok) {
      let document: ApiErrorDocument | undefined;
      try {
        document = (await response.json()) as ApiErrorDocument;
      } catch {
        document = undefined;
      }
      const details = document?.errors
        ?.map((error) =>
          [error.code, error.title, error.detail].filter(Boolean).join(": "),
        )
        .join("; ");
      throw new ShipError(
        `App Store Connect ${method} ${url.pathname}${url.search} failed (${response.status})${
          details ? `: ${details}` : ""
        }`,
        "APP_STORE_CONNECT_API",
      );
    }
    if (response.status === 204) return undefined as T;
    return (await response.json()) as T;
  }

  private async collection<T>(path: string): Promise<T[]> {
    const data: T[] = [];
    const seen = new Set<string>();
    let next: string | undefined = path;
    while (next) {
      invariant(
        !seen.has(next),
        "App Store Connect returned a pagination loop.",
        "APP_STORE_CONNECT_PAGINATION",
      );
      seen.add(next);
      const page: CollectionResponse<T> = await this.request<
        CollectionResponse<T>
      >("GET", next);
      data.push(...page.data);
      next = page.links?.next ?? undefined;
    }
    return data;
  }

  async findApp(bundleId: string): Promise<ApiResource<AppAttributes>> {
    const result = await this.request<
      CollectionResponse<ApiResource<AppAttributes>>
    >("GET", `/v1/apps?filter%5BbundleId%5D=${encodeURIComponent(bundleId)}`);
    invariant(
      result.data.length === 1,
      result.data.length === 0
        ? `No App Store Connect app found for ${bundleId}`
        : `Multiple App Store Connect apps found for ${bundleId}`,
      "APP_NOT_FOUND",
    );
    return result.data[0]!;
  }

  async listPrereleaseVersions(
    appId: string,
    version?: string,
  ): Promise<Array<ApiResource<PrereleaseVersionAttributes>>> {
    const params = new URLSearchParams({
      "filter[app]": appId,
      "filter[platform]": "IOS",
      limit: "200",
    });
    if (version) params.set("filter[version]", version);
    return this.collection<ApiResource<PrereleaseVersionAttributes>>(
      `/v1/preReleaseVersions?${params.toString()}`,
    );
  }

  async listBuildsForPrereleaseVersion(
    prereleaseVersionId: string,
  ): Promise<Array<ApiResource<BuildAttributes>>> {
    return this.collection<ApiResource<BuildAttributes>>(
      `/v1/preReleaseVersions/${prereleaseVersionId}/builds?limit=200`,
    );
  }

  async buildsForVersion(
    appId: string,
    version: string,
  ): Promise<Array<ApiResource<BuildAttributes>>> {
    const versions = await this.listPrereleaseVersions(appId, version);
    const matching = versions.find(
      (item) =>
        item.attributes.version === version &&
        item.attributes.platform === "IOS",
    );
    if (!matching) return [];
    return this.listBuildsForPrereleaseVersion(matching.id);
  }

  async nextBuildNumber(appId: string, version: string): Promise<string> {
    const builds = await this.buildsForVersion(appId, version);
    const numeric = builds
      .map((build) => Number.parseInt(build.attributes.version, 10))
      .filter(Number.isFinite);
    return String((numeric.length ? Math.max(...numeric) : 0) + 1);
  }

  async waitForBuild(
    appId: string,
    version: string,
    buildNumber: string,
    timeoutMinutes: number,
    intervalMilliseconds = 30_000,
  ): Promise<ApiResource<BuildAttributes>> {
    const deadline = Date.now() + timeoutMinutes * 60_000;
    while (Date.now() < deadline) {
      const builds = await this.buildsForVersion(appId, version);
      const build = builds.find(
        (item) => item.attributes.version === buildNumber,
      );
      if (build?.attributes.processingState === "VALID") return build;
      if (
        build?.attributes.processingState === "FAILED" ||
        build?.attributes.processingState === "INVALID"
      ) {
        throw new ShipError(
          `Apple marked ${version} (${buildNumber}) as ${build.attributes.processingState}.`,
          "BUILD_INVALID",
        );
      }
      await new Promise((resolve) => {
        setTimeout(resolve, intervalMilliseconds);
      });
    }
    throw new ShipError(
      `Timed out waiting for ${version} (${buildNumber}) to finish processing.`,
      "BUILD_TIMEOUT",
    );
  }

  async setBetaBuildLocalization(
    buildId: string,
    locale: string,
    whatsNew: string,
  ): Promise<void> {
    const localizations = await this.collection<
      ApiResource<{ locale: string; whatsNew: string }>
    >(`/v1/builds/${buildId}/betaBuildLocalizations?limit=200`);
    const existing = localizations.find(
      (item) => item.attributes.locale === locale,
    );
    if (existing) {
      await this.request("PATCH", `/v1/betaBuildLocalizations/${existing.id}`, {
        data: {
          type: "betaBuildLocalizations",
          id: existing.id,
          attributes: { whatsNew },
        },
      });
    } else {
      await this.request("POST", "/v1/betaBuildLocalizations", {
        data: {
          type: "betaBuildLocalizations",
          attributes: { locale, whatsNew },
          relationships: {
            build: { data: { type: "builds", id: buildId } },
          },
        },
      });
    }
  }

  async addBuildToGroups(
    appId: string,
    buildId: string,
    names: string[],
  ): Promise<void> {
    if (names.length === 0) return;
    const params = new URLSearchParams({
      "filter[app]": appId,
      limit: "200",
    });
    const groups = await this.collection<ApiResource<BetaGroupAttributes>>(
      `/v1/betaGroups?${params.toString()}`,
    );
    for (const name of names) {
      const group = groups.find((item) => item.attributes.name === name);
      invariant(
        group,
        `TestFlight group "${name}" was not found for this app.`,
        "BETA_GROUP_NOT_FOUND",
      );
      const linked = await this.collection<{ type: "builds"; id: string }>(
        `/v1/betaGroups/${group.id}/relationships/builds?limit=200`,
      );
      if (linked.some((item) => item.id === buildId)) continue;
      await this.request(
        "POST",
        `/v1/betaGroups/${group.id}/relationships/builds`,
        { data: [{ type: "builds", id: buildId }] },
      );
    }
  }

  async findOrCreateAppStoreVersion(
    appId: string,
    version: string,
    releaseType: StoreReleaseType,
    earliestReleaseDate?: string,
  ): Promise<ApiResource<AppStoreVersionAttributes>> {
    invariant(
      releaseType !== "scheduled" || earliestReleaseDate,
      "earliestReleaseDate is required for a scheduled App Store release.",
      "SCHEDULED_RELEASE_DATE",
    );
    const appleReleaseType = {
      manual: "MANUAL",
      automatic: "AFTER_APPROVAL",
      scheduled: "SCHEDULED",
    } as const;
    const desiredReleaseType = appleReleaseType[releaseType];
    const params = new URLSearchParams({
      "filter[platform]": "IOS",
      "filter[versionString]": version,
      limit: "10",
    });
    const existing = await this.collection<
      ApiResource<AppStoreVersionAttributes>
    >(`/v1/apps/${appId}/appStoreVersions?${params.toString()}`);
    const match = existing.find(
      (item) => item.attributes.versionString === version,
    );
    if (match) {
      const releasePolicyChanged =
        match.attributes.releaseType !== desiredReleaseType ||
        (releaseType === "scheduled" &&
          Date.parse(match.attributes.earliestReleaseDate ?? "") !==
            Date.parse(earliestReleaseDate!));
      if (releasePolicyChanged) {
        invariant(
          match.attributes.appStoreState === "PREPARE_FOR_SUBMISSION",
          `App Store version ${version} is already ${match.attributes.appStoreState}; its release policy can no longer be changed.`,
          "APP_STORE_RELEASE_POLICY_LOCKED",
        );
        const updated = await this.request<
          ResourceResponse<ApiResource<AppStoreVersionAttributes>>
        >("PATCH", `/v1/appStoreVersions/${match.id}`, {
          data: {
            type: "appStoreVersions",
            id: match.id,
            attributes: {
              releaseType: desiredReleaseType,
              ...(earliestReleaseDate ? { earliestReleaseDate } : {}),
            },
          },
        });
        return updated.data;
      }
      return match;
    }

    const result = await this.request<
      ResourceResponse<ApiResource<AppStoreVersionAttributes>>
    >("POST", "/v1/appStoreVersions", {
      data: {
        type: "appStoreVersions",
        attributes: {
          platform: "IOS",
          versionString: version,
          releaseType: desiredReleaseType,
          ...(earliestReleaseDate ? { earliestReleaseDate } : {}),
        },
        relationships: {
          app: { data: { type: "apps", id: appId } },
        },
      },
    });
    return result.data;
  }

  async attachBuildToVersion(
    appStoreVersionId: string,
    buildId: string,
  ): Promise<void> {
    await this.request(
      "PATCH",
      `/v1/appStoreVersions/${appStoreVersionId}/relationships/build`,
      { data: { type: "builds", id: buildId } },
    );
  }

  async appStoreVersionBuildId(
    appStoreVersionId: string,
  ): Promise<string | undefined> {
    const response = await this.request<
      ResourceResponse<{ type: "builds"; id: string } | null>
    >("GET", `/v1/appStoreVersions/${appStoreVersionId}/relationships/build`);
    return response.data?.id;
  }

  async setAppStoreReleaseNotes(
    appStoreVersionId: string,
    locale: string,
    whatsNew: string,
  ): Promise<void> {
    const localizations = await this.collection<
      ApiResource<{ locale: string; whatsNew: string }>
    >(
      `/v1/appStoreVersions/${appStoreVersionId}/appStoreVersionLocalizations?limit=200`,
    );
    const localization = localizations.find(
      (item) => item.attributes.locale === locale,
    );
    invariant(
      localization,
      `App Store locale "${locale}" does not exist. Add it to the app in App Store Connect before releasing.`,
      "APP_STORE_LOCALE_NOT_FOUND",
    );
    await this.request(
      "PATCH",
      `/v1/appStoreVersionLocalizations/${localization.id}`,
      {
        data: {
          type: "appStoreVersionLocalizations",
          id: localization.id,
          attributes: { whatsNew },
        },
      },
    );
  }

  async submitVersionForReview(
    appId: string,
    appStoreVersionId: string,
  ): Promise<string> {
    const active = await this.request<
      IncludedResponse<
        ApiResource<ReviewSubmissionAttributes> & {
          relationships?: {
            appStoreVersionForReview?: {
              data?: { type: "appStoreVersions"; id: string };
            };
          };
        },
        ApiResource<AppStoreVersionAttributes>
      >
    >(
      "GET",
      `/v1/apps/${appId}/reviewSubmissions?filter%5Bplatform%5D=IOS&include=appStoreVersionForReview&limit=200`,
    );
    const current = active.data.find(
      (item) =>
        item.relationships?.appStoreVersionForReview?.data?.id ===
          appStoreVersionId &&
        [
          "READY_FOR_REVIEW",
          "WAITING_FOR_REVIEW",
          "IN_REVIEW",
          "UNRESOLVED_ISSUES",
        ].includes(item.attributes.state),
    );
    if (current) return current.id;

    const submission = await this.request<
      ResourceResponse<ApiResource<ReviewSubmissionAttributes>>
    >("POST", "/v1/reviewSubmissions", {
      data: {
        type: "reviewSubmissions",
        relationships: {
          app: { data: { type: "apps", id: appId } },
        },
      },
    });
    await this.request("POST", "/v1/reviewSubmissionItems", {
      data: {
        type: "reviewSubmissionItems",
        relationships: {
          reviewSubmission: {
            data: { type: "reviewSubmissions", id: submission.data.id },
          },
          appStoreVersion: {
            data: { type: "appStoreVersions", id: appStoreVersionId },
          },
        },
      },
    });
    await this.request("PATCH", `/v1/reviewSubmissions/${submission.data.id}`, {
      data: {
        type: "reviewSubmissions",
        id: submission.data.id,
        attributes: { submitted: true },
      },
    });
    return submission.data.id;
  }
}
