# Configuration

`.ship-my-flutter/config.yaml` uses snake_case keys and schema version 3. The
generated file starts with a `yaml-language-server` directive linked to
[`schemas/config.schema.json`](../schemas/config.schema.json), which provides
editor validation and autocomplete.

Configuration is strict. Unknown fields, unsafe relative paths, invalid
combinations, and managed build arguments are rejected before release work
begins. The schema provides structural validation, defaults, and conservative
editor checks. `dart run ship_my_flutter validate` is authoritative for shell
quoting, cross-field rules, and path safety on every supported host platform.

## Typical configuration

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/Ventairy/ship-my-flutter/main/schemas/config.schema.json

schema_version: 3
app_path: .
target_branch: main
release_branch_prefix: ship-my-flutter
hooks: {}
platforms:
  ios:
    enabled: true
    bundle_id: com.example.app
    testflight:
      groups:
        - Internal
      wait_timeout_minutes: 45
    app_store:
      mode: upload
```

## Repository fields

| Field | Default | Meaning |
| --- | --- | --- |
| `schema_version` | `3` | Configuration contract version |
| `app_path` | `.` | Flutter app root shared by every platform |
| `target_branch` | `main` | Branch whose commits feed release PRs |
| `release_branch_prefix` | `ship-my-flutter` | Prefix for platform release branches |

## Shell hooks

Hooks are optional POSIX shell commands committed by the repository:

| Field | When it runs |
| --- | --- |
| `hooks.before_create_pr` | After the next version and changelog are prepared, before the release PR is created or updated |
| `hooks.before_build` | On the release branch, before source fingerprinting and candidate creation |

Commands run from the Git repository root through Bash with `-euo pipefail`.
They can invoke FVM, Dart executables, Melos, generators, or tracked project
scripts:

```yaml
hooks:
  before_create_pr:
    run: fvm dart run release:generate_store_release_notes
  before_build:
    run: |
      fvm dart run melos run prepare:ios --no-select
      fvm dart run release:write_production_environment
    commit: false
```

Install every hook dependency before the corresponding Action step. For
example, a Flutter-dependent `before_create_pr` requires Flutter setup in the
plan job as well as the candidate job.

The release-PR hook receives:

```text
SHIP_MY_FLUTTER_PLATFORM
SHIP_MY_FLUTTER_CURRENT_VERSION
SHIP_MY_FLUTTER_VERSION
SHIP_MY_FLUTTER_CHANGELOG_PATH
SHIP_MY_FLUTTER_STORE_RELEASE_NOTES_PATH
```

The build hook receives:

```text
SHIP_MY_FLUTTER_PLATFORM
SHIP_MY_FLUTTER_VERSION
SHIP_MY_FLUTTER_APP_PATH
SHIP_MY_FLUTTER_CHANGELOG_PATH
SHIP_MY_FLUTTER_STORE_RELEASE_NOTES_PATH
```

Each hook defaults to `commit: true`. ship-my-flutter commits every tracked or
unignored file left by `before_create_pr` before pushing the release PR, and
commits and pushes `before_build` output before fingerprinting or building the
candidate. This makes generated notes, code, and environment inputs part of the
reviewed and tested release branch.

Set `commit: false` when a hook produces only ignored files or external side
effects, or when the hook performs its own commit. In that mode the hook must
leave a clean worktree; ship-my-flutter refuses to create the PR or build from
uncommitted inputs. GitHub, Apple, signing, and certificate credentials are
removed from both hook environments.

## `app_path`

`app_path` is global because iOS and future Android delivery operate on the
same Flutter application. It is relative to the Git repository root and cannot
escape it, including through a symlink.

## `platforms.ios`

| Field | Default | Meaning |
| --- | --- | --- |
| `enabled` | `true` | Enables iOS planning and delivery |
| `bundle_id` | detected on macOS | App Store bundle identifier; explicit configuration is recommended |
| `scheme` | unset | Custom Flutter flavor/Xcode scheme |
| `build_command` | auto-detected | Optional project-owned command that builds one IPA |
| `ipa_output_path` | `build/ios/ipa` | IPA file or directory relative to `app_path` |

The consumer owns the build toolchain. `ship-my-flutter-action` does not install
Flutter or FVM. Set them up in the workflow before the candidate Action step,
using the exact version selected by the project.

For a standard Flutter app, omit both build fields. If `.fvmrc` or legacy
`.fvm/fvm_config.json` exists at the project or repository level, the default
command is `fvm flutter build ipa --release`; otherwise it is
`flutter build ipa --release`. Flutter's standard output is:

```yaml
ipa_output_path: build/ios/ipa
```

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
in `before_build.run`.

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
SHIP_MY_FLUTTER_IPA_OUTPUT_PATH
SHIP_MY_FLUTTER_SCHEME
```

`ipa_output_path` may name one `.ipa` file or a directory containing exactly
one IPA. It cannot escape `app_path`, including through a symlink. Keep it
omitted for normal Flutter and FVM builds. Its concrete use case is a custom
single-command wrapper that deliberately emits or moves the IPA to a different
project-relative location; explicit configuration prevents stale or ambiguous
IPA discovery.

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

- `upload`: keep the tested build in TestFlight and finish the GitHub Release
  after merge;
- `review`: attach the tested build, apply supplied notes, and submit the
  version for App Review, then wait for a manual release after approval;
- `auto`: submit the same way and release automatically after Apple approval.

The initializer defaults to `upload`.

## Migrating to schema version 3

Version 3 makes the shared app root global and gives hooks explicit behavior:

| Version 2 | Version 3 |
| --- | --- |
| `schema_version: 2` | `schema_version: 3` |
| `platforms.ios.project_path` | root `app_path` |
| `hooks.before_release_pr: <command>` | `hooks.before_create_pr.run: <command>` |
| `hooks.before_candidate: <command>` | `hooks.before_build.run: <command>` |

Both hooks default to `commit: true`; add `commit: false` only for the clean
worktree cases described above. Other snake_case version 2 keys remain
unchanged. State files such as `manifest.json`, `changelog.json`, and candidate
receipts remain versioned JSON.

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
