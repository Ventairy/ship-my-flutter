# Configuration

`.ship-my-flutter/config.yaml` uses snake_case keys and schema version 2. The
generated file starts with a `yaml-language-server` directive linked to
[`schemas/config.schema.json`](../schemas/config.schema.json), which provides
editor validation and autocomplete.

Configuration is strict. Unknown fields, unsafe relative paths, invalid
combinations, and managed build arguments are rejected before release work
begins.

## Complete example

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/Ventairy/ship-my-flutter/main/schemas/config.schema.json

schema_version: 2
target_branch: main
release_branch_prefix: ship-my-flutter
hooks: {}
platforms:
  ios:
    enabled: true
    project_path: .
    bundle_id: com.example.app
    build_command: flutter build ipa --release
    artifact_path: build/ios/ipa
    testflight:
      groups:
        - Internal
      wait_timeout_minutes: 45
    app_store:
      mode: upload-only
      release_type: manual
```

## Repository fields

| Field | Default | Meaning |
| --- | --- | --- |
| `schema_version` | `2` | Configuration contract version |
| `target_branch` | `main` | Branch whose commits feed release PRs |
| `release_branch_prefix` | `ship-my-flutter` | Prefix for platform release branches |

## Shell hooks

Hooks are optional POSIX shell commands committed by the repository:

| Field | When it runs |
| --- | --- |
| `hooks.before_release_pr` | After the next version and changelog are prepared, before the release PR is committed |
| `hooks.before_candidate` | On the release branch, before source fingerprinting and candidate creation |

Commands run from the Git repository root through Bash with `-euo pipefail`.
They can invoke FVM, Dart executables, Melos, generators, or tracked project
scripts:

```yaml
hooks:
  before_release_pr: fvm dart run release:generate_store_release_notes
  before_candidate: |
    fvm dart run melos run prepare:ios --no-select
    fvm dart run release:write_production_environment
```

Install every hook dependency before the corresponding Action step. For
example, a Flutter-dependent `before_release_pr` requires Flutter setup in the
plan job as well as the candidate job.

The release-PR hook receives:

```text
SHIP_MY_FLUTTER_PLATFORM
SHIP_MY_FLUTTER_CURRENT_VERSION
SHIP_MY_FLUTTER_VERSION
SHIP_MY_FLUTTER_CHANGELOG_PATH
SHIP_MY_FLUTTER_STORE_RELEASE_NOTES_PATH
```

The candidate hook receives:

```text
SHIP_MY_FLUTTER_PLATFORM
SHIP_MY_FLUTTER_VERSION
SHIP_MY_FLUTTER_PROJECT_PATH
SHIP_MY_FLUTTER_CHANGELOG_PATH
SHIP_MY_FLUTTER_STORE_RELEASE_NOTES_PATH
```

Changes from `before_release_pr` are intentionally staged into the release PR,
which is how generated store notes or other reviewable release inputs are
updated. `before_candidate` must leave tracked and unignored files clean; put
any generated release input in the release-PR hook instead. GitHub, Apple,
signing, and certificate credentials are removed from both hook environments.

## `platforms.ios`

| Field | Default | Meaning |
| --- | --- | --- |
| `enabled` | `true` | Enables iOS planning and delivery |
| `project_path` | `.` | Flutter project root relative to the repository |
| `bundle_id` | detected on macOS | App Store bundle identifier; explicit configuration is recommended |
| `scheme` | unset | Custom Flutter flavor/Xcode scheme |
| `build_command` | `flutter build ipa --release` | Project-owned command that builds one IPA |
| `artifact_path` | `build/ios/ipa` | IPA file or directory relative to `project_path` |

The consumer owns the build toolchain. `ship-my-flutter-action` does not install
Flutter or FVM. Set them up in the workflow before the candidate Action step,
using the exact version selected by the project.

`build_command` is one shell command invocation, not a preparation hook.
ship-my-flutter automatically appends these arguments:

```text
--build-name <planned version>
--build-number <next App Store Connect build number>
--export-options-plist <generated signing export options>
--flavor <scheme>  # only when scheme is configured
```

Do not repeat those flags in the command. They are rejected so release identity
cannot be overridden. Shell chaining, pipelines, redirections, comments, and
command substitution are also rejected: otherwise Bash could attach the
managed arguments to a different command or ignore them. Put dependency
resolution, code generation, environment preparation, logging, or verification
in `before_candidate`.

Examples:

```yaml
# Flutter already on PATH
build_command: flutter build ipa --release

# Project-owned FVM
build_command: fvm flutter build ipa --release

# A package executable that accepts the appended build arguments
build_command: fvm dart run release:build_ios
```

For a custom Dart executable, read the appended options from `args` and forward
them to the underlying Flutter build. The executable may also read the matching
environment variables below.

The command also receives the calculated values as environment variables for
logging or wrapper logic:

```text
SHIP_MY_FLUTTER_PLATFORM
SHIP_MY_FLUTTER_VERSION
SHIP_MY_FLUTTER_BUILD_NUMBER
SHIP_MY_FLUTTER_EXPORT_OPTIONS_PATH
SHIP_MY_FLUTTER_ARTIFACT_PATH
SHIP_MY_FLUTTER_SCHEME
```

`artifact_path` may name one `.ipa` file or a directory containing exactly one
IPA. It cannot escape `project_path`, including through a symlink.

Omit `scheme` for a standard unflavored Flutter app. Bundle-ID detection uses
the Runner scheme when no scheme is configured.

## TestFlight

`testflight.groups` contains exact existing App Store Connect beta-group names.
An empty array leaves group access unchanged.

`testflight.wait_timeout_minutes` controls how long the candidate waits for
Apple processing. The allowed range is 5–180 minutes.

External groups can require Beta App Review. ship-my-flutter surfaces Apple's
response; it does not bypass external testing review.

## App Store

`app_store.mode` supports:

- `upload-only`: keep the tested build in TestFlight and finish the GitHub
  Release after merge;
- `submit-for-review`: attach the tested build, apply supplied notes, and submit
  the version for App Review.

The initializer defaults to `upload-only`.

`app_store.release_type` controls behavior after approval:

- `manual`: wait in Pending Developer Release;
- `automatic`: release after approval;
- `scheduled`: require `earliest_release_date` as an ISO 8601 timestamp.

## Migrating schema version 1

Version 2 replaces camelCase configuration keys and the Flutter-specific
`buildArgs` array:

| Version 1 | Version 2 |
| --- | --- |
| `schemaVersion` | `schema_version: 2` |
| `targetBranch` | `target_branch` |
| `releaseBranchPrefix` | `release_branch_prefix` |
| `hooks.beforeReleasePr` executable path | `hooks.before_release_pr` shell command |
| `platforms.ios.projectPath` | `platforms.ios.project_path` |
| `platforms.ios.bundleId` | `platforms.ios.bundle_id` |
| `platforms.ios.buildArgs` | include project-specific flags in `build_command` |
| `testflight.waitTimeoutMinutes` | `testflight.wait_timeout_minutes` |
| `appStore` | `app_store` |
| `releaseType` | `release_type` |
| `earliestReleaseDate` | `earliest_release_date` |

Add `artifact_path`, and optionally add `before_candidate`. State files such as
`manifest.json`, `changelog.json`, and candidate receipts remain versioned JSON
and are not migrated to snake_case.

## Signing profiles

The common case uses one Base64 profile. Apps with extensions pass a JSON
object through `IOS_PROVISIONING_PROFILES_BASE64`:

```json
{
  "com.example.app": "BASE64",
  "com.example.app.ShareExtension": "BASE64"
}
```

Every key must match the profile's embedded application identifier, and every
profile must belong to the same team.
