# ship-my-flutter

Release PRs, TestFlight candidates, and App Store submission for Flutter apps.

> [!WARNING]
> This project is in pre-release validation. The `ship_my_flutter` Dart package
> is not published yet, and the companion action does not have a `v1` tag.
> Follow [core issue #1](https://github.com/Ventairy/ship-my-flutter/issues/1)
> and [action issue #1](https://github.com/Ventairy/ship-my-flutter-action/issues/1)
> for the live Apple acceptance and first publication gates. The quick start
> below describes the post-publication interface; do not assume pub.dev or `@v1`
> is available before those issues are complete. Non-Apple release planning is
> exercised publicly in
> [`Ventairy/ship-my-flutter-dart-e2e`](https://github.com/Ventairy/ship-my-flutter-dart-e2e).

For non-Apple evaluation before publication, copy the current immutable
core/Action pair recorded in the
[`ship-my-flutter-dart-e2e` README](https://github.com/Ventairy/ship-my-flutter-dart-e2e#readme).
That external fixture can name the core commit without creating a circular
self-reference in this repository. Its commits cover only the documented
non-Apple boundary; they are not a production release.

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

For a single-app repository, run this from the Git repository root (which is
also the Flutter project root):

```bash
dart pub add --dev ship_my_flutter
dart run ship_my_flutter init \
  --current-version <current-ios-version> \
  --bundle-id com.example.myapp
```

`--current-version` is the latest iOS marketing version already represented by
your release history, not the version you want the next PR to create. Existing
apps normally use the latest shipped App Store version. For a never-released
app, use `0.0.0` and put `Release-As-ios: 1.0.0` in the first release-worthy
commit if the first release should be 1.0.0. If omitted, the initializer reads
the stable version from `pubspec.yaml` and otherwise falls back to `0.0.0`;
passing it explicitly is safer.

In a monorepo, `.github` and `.ship-my-flutter` must live at the Git repository
root. If `ship_my_flutter` is installed in a nested app package, run from that
package but point initialization at the repository:

```bash
dart run ship_my_flutter init \
  --root ../.. \
  --current-version <current-ios-version> \
  --bundle-id com.example.myapp
```

Then set `platforms.ios.project_path` to the app path relative to the repository
root. The exact `--root` value depends on the workspace layout.

This creates:

```text
.ship-my-flutter/
├── candidates/
├── changelog.json
├── config.yaml
├── manifest.json
└── store-release-notes.json
.github/workflows/ship-my-flutter.yml
```

Commit those files with a non-release message such as
`chore: configure ship-my-flutter` before merging new release-worthy work. The
initializer records the pre-initialization commit as the release baseline, so
existing repository history is not released accidentally.

### CLI and Dart API

The package offers one discoverable CLI with subcommands:

```bash
dart run ship_my_flutter --help
dart run ship_my_flutter validate
dart run ship_my_flutter plan
dart run ship_my_flutter open-pr
dart run ship_my_flutter testflight
dart run ship_my_flutter app-store
```

Success writes one JSON value to stdout, so the same commands compose cleanly
inside custom GitHub workflows. Diagnostics go to stderr. `release` aliases
`open-pr`, `candidate` aliases `testflight`, and `promote` aliases `app-store`.

Package-qualified executables are also available when a single-purpose command
fits better:

```bash
dart run ship_my_flutter:init
dart run ship_my_flutter:open_pr
dart run ship_my_flutter:release
dart run ship_my_flutter:testflight
dart run ship_my_flutter:promote
dart run ship_my_flutter:app_store
```

For use outside a project, activate the package globally:

```bash
dart pub global activate ship_my_flutter
ship-my-flutter validate
```

Custom Dart automation imports the same implementation used by the Action:

```dart
import 'package:ship_my_flutter/ship_my_flutter.dart';

Future<void> main() async {
  const root = '.';
  await validateRepository(root);
  final manifest = await loadManifest(root);
  final plan = await createReleasePlan(root, manifest, Platform.ios);
  print(plan?.toJson());
}
```

See [`example/custom_workflow.dart`](example/custom_workflow.dart) for a
complete JSON-emitting example and [CLI reference](doc/cli.md) for each
command's branch, credentials, runner, and side effects.

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
repository and give it Contents, Pull requests, and Issues read/write access.
The same token performs the authenticated release-branch push. Treat the
alternative token as a release secret.

The default `GITHUB_TOKEN` does not trigger separate workflow runs for events
it creates. That does not affect ship-my-flutter's candidate job—the generated
workflow dispatches it from the plan job's outputs—but it can suppress your
repository's normal `pull_request` checks on the generated release PR. Use the
GitHub App or PAT path when those independent checks must run automatically.

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

On Linux, use `base64 -w 0 FILE` and copy the single-line output.

For an app with extensions, set `IOS_PROVISIONING_PROFILES_BASE64` to a JSON object whose keys are bundle IDs:

```json
{
  "com.example.myapp": "<base64 profile>",
  "com.example.myapp.ShareExtension": "<base64 profile>"
}
```

See [Apple bootstrap](doc/apple-bootstrap.md) for the one-time App Store Connect setup and required roles.

### CLI credential environment

The CLI reads secrets from environment variables so they never need to appear
in command history or process arguments:

| Variable                                                         | Used by                  |
| ---------------------------------------------------------------- | ------------------------ |
| `SHIP_MY_FLUTTER_GITHUB_TOKEN` or `GITHUB_TOKEN`                  | `open-pr`, `release`, promotion |
| `GITHUB_REPOSITORY`                                              | GitHub commands; `owner/name` |
| `SHIP_MY_FLUTTER_APP_STORE_CONNECT_KEY_ID`                       | TestFlight and App Store |
| `SHIP_MY_FLUTTER_APP_STORE_CONNECT_ISSUER_ID`                    | TestFlight and App Store |
| `SHIP_MY_FLUTTER_APP_STORE_CONNECT_PRIVATE_KEY_BASE64`           | TestFlight and App Store |
| `SHIP_MY_FLUTTER_IOS_CERTIFICATE_BASE64`                         | TestFlight candidate     |
| `SHIP_MY_FLUTTER_IOS_CERTIFICATE_PASSWORD`                       | TestFlight candidate     |
| `SHIP_MY_FLUTTER_IOS_PROVISIONING_PROFILES_BASE64`               | TestFlight candidate     |

For local files, replace the private key, certificate, or profile Base64
variable with its `_PATH` form:

```text
SHIP_MY_FLUTTER_APP_STORE_CONNECT_PRIVATE_KEY_PATH
SHIP_MY_FLUTTER_IOS_CERTIFICATE_PATH
SHIP_MY_FLUTTER_IOS_PROVISIONING_PROFILES_PATH
```

Set exactly one source for each credential. The certificate password remains
an environment secret. GitHub automation can alternatively use
`--github-token-file`; raw token arguments are intentionally unsupported.

### 4. Configure TestFlight and submission behavior

The generated `.ship-my-flutter/config.yaml` includes a JSON Schema directive
for editor validation and autocomplete. It is ready for a standard Flutter app;
add TestFlight group names if builds should be assigned automatically:

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
    bundle_id: com.example.myapp
    testflight:
      groups:
        - Internal
      wait_timeout_minutes: 45
    app_store:
      mode: upload-only
      release_type: manual
```

- `submit-for-review` creates or reuses the App Store version, attaches the tested build, applies localized notes, and submits it.
- `upload-only` keeps the tested build in TestFlight/App Store Connect and still creates the platform GitHub Release after merge.
- `release_type` controls what happens after Apple approval: `manual`, `automatic`, or `scheduled`.

The initializer deliberately defaults to `upload-only`. Change it to
`submit-for-review` only after the first candidate succeeds and the app's
submission metadata is complete.

The complete contract is in [Configuration](doc/configuration.md).

For a standard Flutter app, no build fields are needed. ship-my-flutter defaults
to `flutter build ipa --release` and reads the single IPA from
`build/ios/ipa`, matching Flutter's standard iOS output. Add `build_command` or
`artifact_path` only when the project uses FVM, Melos, a wrapper, or a custom
artifact location.

The generated candidate job installs Flutter before invoking the Action. The
Action itself does not install Flutter or FVM: the app repository owns the
exact toolchain used by `build_command`. Keep the generated
`subosito/flutter-action` step for a normal Flutter setup, or replace it with
the repository's established FVM/bootstrap steps. The generated setup reads a
root `.fvmrc` when present and otherwise uses current stable Flutter.

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

Set any repository-owned shell command as `hooks.before_release_pr`:

```yaml
hooks:
  before_release_pr: fvm dart run release:generate_store_release_notes
```

The command receives:

```text
SHIP_MY_FLUTTER_PLATFORM
SHIP_MY_FLUTTER_CURRENT_VERSION
SHIP_MY_FLUTTER_VERSION
SHIP_MY_FLUTTER_CHANGELOG_PATH
SHIP_MY_FLUTTER_STORE_RELEASE_NOTES_PATH
```

The changelog and next version already exist when the hook runs, so an AI or translation script can write deterministic drafts into the release PR for human review.

Project preparation can use the matching candidate hook:

```yaml
hooks:
  before_candidate: fvm dart run melos run prepare:ios --no-select
```

The optional `build_command` overrides the default project-owned IPA build
invocation. ship-my-flutter automatically appends the planned version, next App
Store build number, generated export-options plist, and configured flavor:

```yaml
platforms:
  ios:
    build_command: fvm flutter build ipa --release
    artifact_path: build/ios/ipa
```

Keep it to one command invocation, such as `flutter build` or a Dart wrapper
that accepts those appended arguments. Put chaining, preparation, logging, and
verification in `hooks.before_candidate`.

See [Configuration](doc/configuration.md) for hook context, managed arguments,
artifact validation, and schema version 1 migration.

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
- A macOS 26 job installs the project-selected Flutter toolchain, imports
  temporary signing material, runs the configured IPA build, uploads it, waits
  for `VALID`, writes TestFlight notes, assigns groups, and commits the
  candidate receipt.
- After the release PR merges, an Ubuntu job verifies the receipt, promotes the exact Apple build, and creates `ios-vX.Y.Z`.

GitHub does not create new workflow runs for events produced by the default
`GITHUB_TOKEN`. The TestFlight candidate job is unaffected because it continues
in the workflow that opened the PR. Your repository's separate `pull_request`
workflows, however, will not run for that generated PR.

If independent PR checks must run, generate a GitHub App installation token
(preferred) or use a narrowly scoped personal access token and pass it as the
plan step's `github-token` input. This is optional; do not add a long-lived
token merely for ship-my-flutter's own jobs.

Secrets are passed only as action inputs, masked by GitHub, written with restrictive permissions, and removed during cleanup. See [Security model](doc/security.md).

## Requirements

- Dart 3.10 or newer for the package CLI and custom automation. The GitHub
  Action installs its own pinned Dart SDK.
- A modern Flutter app with an `ios` project.
- A committed, current `pubspec.lock`; the project-owned build command must not
  introduce uncommitted dependency changes.
- A GitHub-hosted or self-hosted macOS runner capable of Xcode 26 builds.
- An existing App Store Connect app record; Apple does not let the API create one.
- An App Store Connect API key with `Developer` access for upload-only delivery
  without TestFlight groups, or at least `App Manager` access for group
  assignment and App Review submission; plus an Apple Distribution certificate
  and App Store provisioning profile.
- Required App Store product metadata already configured for the app.

Run `dart run ship_my_flutter validate` locally to catch repository
configuration problems before CI.

## Contributing to the core

The package uses Freezed and json_serializable for immutable release state and
typed JSON boundaries. Generated Dart files are committed, so package users do
not run a generator. Contributors changing an annotated model should run
`dart run build_runner build` and review the generated diff. See
[CONTRIBUTING.md](CONTRIBUTING.md) for the complete development gate.

## Validation boundary

The public
[`ship-my-flutter-dart-e2e`](https://github.com/Ventairy/ship-my-flutter-dart-e2e)
fixture verifies the Dart 3.10 package install, initializer, validator, planner,
public Dart API, thin Action adapter, Android/iOS commit isolation, release-PR
creation and updates, merge routing, platform GitHub Release, and terminal
`noop` state on GitHub-hosted runners.

It intentionally has no candidate or promotion job, stores no Apple
credentials, and calls no Apple endpoint. Real certificate import, signing, IPA
upload, TestFlight processing, and App Review submission remain the explicit
pre-publication acceptance gate in issues #1.

## More detail

- [Architecture and state machine](doc/architecture.md)
- [Apple bootstrap](doc/apple-bootstrap.md)
- [CLI reference](doc/cli.md)
- [Configuration reference](doc/configuration.md)
- [Operating release PRs](doc/operations.md)
- [Security model](doc/security.md)
- [Releasing ship-my-flutter itself](RELEASING.md)
