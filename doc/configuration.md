# Configuration

`.ship-my-flutter/config.yaml` uses schema version 1 and starts with a
`yaml-language-server` directive linked to
[`schemas/config.schema.json`](../schemas/config.schema.json). Editors with YAML
language-server support provide validation and autocomplete without additional
workspace configuration.

## Top-level fields

| Field                   | Default           | Meaning                                                               |
| ----------------------- | ----------------- | --------------------------------------------------------------------- |
| `schemaVersion`         | `1`               | Configuration contract version                                        |
| `targetBranch`          | `main`            | Branch whose commits feed release PRs                                 |
| `releaseBranchPrefix`   | `ship-my-flutter` | Prefix for platform release branches                                  |
| `hooks.beforeReleasePr` | unset             | Repository-relative executable run after version/changelog generation |

Paths must remain inside the repository.

## `platforms.ios`

| Field         | Default           | Meaning                                                |
| ------------- | ----------------- | ------------------------------------------------------ |
| `enabled`     | `true`            | Enables iOS planning and delivery                      |
| `projectPath` | `.`               | Flutter project root relative to the repository        |
| `bundleId`    | detected on macOS | App Store bundle identifier; setting it is recommended |
| `scheme`      | unset             | Actual custom Flutter flavor/Xcode scheme              |
| `buildArgs`   | `[]`              | Extra arguments appended to `flutter build ipa`        |

Do not put secrets in `buildArgs`. The version, build number, and export options are controlled by ship-my-flutter.

Omit `scheme` for a normal unflavored Flutter app. Bundle-ID detection uses the
standard Runner scheme when it is absent, but an explicitly configured value is
also passed to `flutter build ipa --flavor`; setting `Runner` on an unflavored
app can therefore break the build.

## TestFlight

`testflight.groups` contains exact existing App Store Connect beta-group names. With an empty array, Apple processes the build but the action does not change group access.

`testflight.waitTimeoutMinutes` controls how long the action polls Apple after upload. Allowed values are 5–180 minutes.

External groups can require Beta App Review. ship-my-flutter assigns the build to the requested group and surfaces Apple’s response; it does not bypass external testing review.

## App Store

`appStore.mode`:

- `submit-for-review`: create/reuse the iOS App Store version, attach the tested build, apply supplied notes, and submit it.
- `upload-only`: stop after TestFlight delivery; merging still tags the code and creates the GitHub Release.

The initializer defaults to `upload-only`, making App Review submission an
explicit opt-in.

`appStore.releaseType` controls release after Apple approves the submission:

- `manual`: wait in Pending Developer Release.
- `automatic`: release after approval.
- `scheduled`: requires `earliestReleaseDate`, an ISO 8601 timestamp. That field is rejected for the other release types.

## Signing profiles

The common case uses one Base64 profile. Apps with extensions pass a JSON object through `IOS_PROVISIONING_PROFILES_BASE64`:

```json
{
  "com.example.app": "BASE64",
  "com.example.app.ShareExtension": "BASE64"
}
```

Every key must match the profile’s embedded application identifier, and every profile must belong to the same team. The action validates both facts before starting the Flutter build.

## Build arguments

Example with a Dart environment file:

```yaml
buildArgs:
  - --dart-define-from-file=config/production.json
```

The config file is part of the source fingerprint when tracked by Git, so changing it invalidates the candidate.
