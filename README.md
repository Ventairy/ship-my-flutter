# ship-my-flutter

Release PRs, TestFlight candidates, and App Store submission for Flutter apps.

`ship-my-flutter` turns the iOS release process into a code review:

1. Merge normal Conventional Commits into `main`.
2. Review an automatically maintained iOS release PR and test its exact build in TestFlight.
3. Merge the release PR to submit that same build to App Review—or leave it uploaded only.

No Fastfile is required. Versions, changelog data, localized store notes, and the TestFlight candidate receipt all live in `.ship-my-flutter`.

> [!IMPORTANT]
> v1 supports iOS and App Store Connect. The configuration and release state are platform-scoped so Android can be added without introducing a shared app version.

## Why this workflow is safer

The binary uploaded from the release PR gets a source fingerprint and an App Store Connect build ID. After merge, promotion verifies both values and refuses to continue if the merged app source differs from the tested candidate. It never rebuilds a supposedly approved release.

| Commit                               | iOS result                               |
| ------------------------------------ | ---------------------------------------- |
| `feat: add saved searches`           | Minor release                            |
| `fix(ios): repair sign in`           | iOS patch release                        |
| `fix(android): repair back button`   | No iOS release                           |
| `feat(auth): add passkeys`           | Minor release for every enabled platform |
| `feat(ios)!: replace local database` | iOS major release                        |

Unknown scopes such as `auth` are feature scopes, not platform scopes, so they apply to all enabled platforms.

## Quick start

### 1. Initialize the Flutter repository

Run this from the Flutter project root:

```bash
npx ship-my-flutter init \
  --current-version 1.0.0 \
  --bundle-id com.example.myapp
```

This creates:

```text
.ship-my-flutter/
├── candidates/
├── changelog.json
├── config.json
├── manifest.json
└── store-release-notes.json
.github/workflows/ship-my-flutter.yml
```

Commit those files before merging new release-worthy work. The initializer records the current commit as the release baseline, so existing repository history is not released accidentally.

### 2. Allow the workflow to open release PRs

In the Flutter repository, open **Settings → Actions → General → Workflow
permissions** and enable **Allow GitHub Actions to create and approve pull
requests**. Organization policy can lock this setting; if it does, ask an
organization owner to enable it or give the plan step a GitHub App installation
token (preferred) or narrowly scoped personal access token:

```yaml
- uses: Ventairy/ship-my-flutter-action@v1
  with:
    phase: plan
    github-token: ${{ secrets.SHIP_MY_FLUTTER_GITHUB_TOKEN }}
```

For a fine-grained personal access token, grant access only to the Flutter
repository and give it Pull requests and Issues read/write access. The
workflow's existing `contents: write` permission continues to own the release
branch push. Treat the alternative token as a release secret.

### 3. Add six Apple GitHub Actions secrets

| Secret                                 | Value                                                                  |
| -------------------------------------- | ---------------------------------------------------------------------- |
| `APP_STORE_CONNECT_KEY_ID`             | App Store Connect API key ID                                           |
| `APP_STORE_CONNECT_ISSUER_ID`          | API issuer ID                                                          |
| `APP_STORE_CONNECT_PRIVATE_KEY_BASE64` | Base64-encoded `.p8` API private key                                   |
| `IOS_CERTIFICATE_BASE64`               | Base64-encoded Apple Distribution `.p12`                               |
| `IOS_CERTIFICATE_PASSWORD`             | Password used when the `.p12` was exported                             |
| `IOS_PROVISIONING_PROFILES_BASE64`     | One Base64 App Store profile, or a JSON map for an app with extensions |

On macOS:

```bash
base64 -i AuthKey_ABC123.p8 | pbcopy
base64 -i distribution.p12 | pbcopy
base64 -i AppStore.mobileprovision | pbcopy
```

For an app with extensions, set `IOS_PROVISIONING_PROFILES_BASE64` to a JSON object whose keys are bundle IDs:

```json
{
  "com.example.myapp": "<base64 profile>",
  "com.example.myapp.ShareExtension": "<base64 profile>"
}
```

See [Apple bootstrap](docs/apple-bootstrap.md) for the one-time App Store Connect setup and required roles.

### 4. Configure TestFlight and submission behavior

The generated `.ship-my-flutter/config.json` is ready for a standard Flutter app. Add TestFlight group names if builds should be assigned automatically:

```json
{
  "schemaVersion": 1,
  "targetBranch": "main",
  "releaseBranchPrefix": "ship-my-flutter",
  "hooks": {},
  "platforms": {
    "ios": {
      "enabled": true,
      "projectPath": ".",
      "bundleId": "com.example.myapp",
      "buildArgs": [],
      "testflight": {
        "groups": ["Internal"],
        "waitTimeoutMinutes": 45
      },
      "appStore": {
        "mode": "submit-for-review",
        "releaseType": "manual"
      }
    }
  }
}
```

- `submit-for-review` creates or reuses the App Store version, attaches the tested build, applies localized notes, and submits it.
- `upload-only` keeps the tested build in TestFlight/App Store Connect and still creates the platform GitHub Release after merge.
- `releaseType` controls what happens after Apple approval: `manual`, `automatic`, or `scheduled`.

The complete contract is in [Configuration](docs/configuration.md).

The action automatically honors a tracked `.fvmrc` or FVM config. Without one, it uses the configured Flutter channel (`stable` by default). You can instead set `flutter-version` or `flutter-version-file` explicitly on the candidate action step.

## Store release notes

Notes are user-owned. Add them to `.ship-my-flutter/store-release-notes.json` under the platform, version, and Apple locale:

```json
{
  "ios": {
    "1.1.0": {
      "en-US": "Saved searches are here, with a faster sign-in experience.",
      "pt-BR": "As buscas salvas chegaram, com uma experiência de login mais rápida."
    }
  }
}
```

Omitting a version is allowed; ship-my-flutter will not invent notes. Apple may still require “What’s New” for an App Store update and will return a precise submission error if the version metadata is incomplete.

### Generate notes before the PR opens

Set a repository script as `hooks.beforeReleasePr`:

```json
{
  "hooks": {
    "beforeReleasePr": "tool/generate-store-notes"
  }
}
```

The executable receives:

```text
SHIP_MY_FLUTTER_PLATFORM
SHIP_MY_FLUTTER_CURRENT_VERSION
SHIP_MY_FLUTTER_VERSION
SHIP_MY_FLUTTER_CHANGELOG_PATH
SHIP_MY_FLUTTER_STORE_RELEASE_NOTES_PATH
```

The changelog and next version already exist when the hook runs, so an AI or translation script can write deterministic drafts into the release PR for human review.

## Version overrides

Release bumps mirror Release Please’s Conventional Commit rules:

- `fix`, `perf`, and `deps` produce a patch.
- `feat` produces a minor.
- `!` or a `BREAKING CHANGE` footer produces a major.
- `Release-As: 2.0.0` forces a version for every applicable platform.
- `Release-As-ios: 2.0.0` forces only iOS.

Every platform owns its version. `pubspec.yaml` is not treated as a global release manifest; the iOS build receives `--build-name` and a collision-free App Store Connect build number at build time.

## What happens in GitHub Actions

The generated workflow uses one repository-wide concurrency lane:

- An Ubuntu job plans or updates `ship-my-flutter/ios`.
- A macOS 26 job imports temporary signing material, builds the IPA with Flutter, uploads it, waits for `VALID`, writes TestFlight notes, assigns groups, and commits the candidate receipt.
- After the release PR merges, an Ubuntu job verifies the receipt, promotes the exact Apple build, and creates `ios-vX.Y.Z`.

GitHub places other `pull_request` workflows triggered by a release PR created
with the default `GITHUB_TOKEN` in an approval-required state. A maintainer with
write access must select **Approve workflows to run** in the release PR before
those checks start. The TestFlight candidate job itself does not need that
approval because it continues in the workflow that opened the PR.

If independent PR checks must start without approval, generate a GitHub App
installation token (preferred) or use a narrowly scoped personal access token
and pass it as the plan step's `github-token` input. This is optional; do not add
a long-lived token merely for ship-my-flutter's own jobs.

Secrets are passed only as action inputs, masked by GitHub, written with restrictive permissions, and removed during cleanup. See [Security model](docs/security.md).

## Requirements

- A modern Flutter app with an `ios` project.
- A committed, current `pubspec.lock`; release builds enforce it rather than resolving new dependency versions in CI.
- A GitHub-hosted or self-hosted macOS runner capable of Xcode 26 builds.
- An existing App Store Connect app record; Apple does not let the API create one.
- An App Store Connect API key, Apple Distribution certificate, and App Store provisioning profile.
- Required App Store product metadata already configured for the app.

Run `npx ship-my-flutter validate` locally to catch repository configuration problems before CI.

## More detail

- [Architecture and state machine](docs/architecture.md)
- [Apple bootstrap](docs/apple-bootstrap.md)
- [Configuration reference](docs/configuration.md)
- [Security model](docs/security.md)
- [Releasing ship-my-flutter itself](RELEASING.md)
