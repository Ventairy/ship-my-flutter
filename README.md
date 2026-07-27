# smf

Release PRs, TestFlight candidates, and App Store submission for Flutter apps.

> [!WARNING]
> This project is in pre-release validation. The `smf` Dart package
> is not published yet, and the companion action does not have a `v1` tag.
> Follow [core issue #1](https://github.com/Ventairy/smf/issues/1)
> and [action issue #1](https://github.com/Ventairy/smf-action/issues/1)
> for the live Apple acceptance and first publication gates. The quick start
> below describes the post-publication interface; do not assume pub.dev or `@v1`
> is available before those issues are complete. Non-Apple release planning is
> exercised publicly in
> [`Ventairy/smf-e2e`](https://github.com/Ventairy/smf-e2e).

For non-Apple evaluation before publication, copy the current immutable
core/Action pair recorded in the
[`smf-e2e` README](https://github.com/Ventairy/smf-e2e#readme).
That external fixture can name the core commit without creating a circular
self-reference in this repository. Its commits cover only the documented
non-Apple boundary; they are not a production release.

`smf` turns the iOS release process into a code review:

1. Merge normal Conventional Commits into `main`.
2. Review an automatically maintained iOS release PR and test its exact build in TestFlight.
3. Merge the release PR to submit that same build to App Review—or leave it uploaded only.

No Fastfile is required. Versions, changelog data, localized store notes, and
the TestFlight candidate receipt all live beside the Flutter app in `smf/`.

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

### 1. Install and initialize SMF

SMF is a project-local development dependency. Add it and run its CLI from the
Flutter app directory:

```bash
dart pub add --dev smf
dart run smf init \
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

In a monorepo, add SMF to the nested Flutter app and run it there. SMF places
configuration beside that app and the workflow at the Git repository root:

```bash
cd apps/mobile
dart pub add --dev smf
dart run smf init \
  --current-version <current-ios-version> \
  --bundle-id com.example.myapp
```

This creates:

```text
<flutter-app>/smf/config.yaml
<repository>/.github/workflows/smf.yml
```

The generated workflow records the exact relative `smf/` path and passes it to
every Action phase. This prevents a later sibling app from changing which
configuration or FVM toolchain the workflow selects.

One Git repository currently supports one independently released SMF app.
`--smf-path` and the Action's `smf-path` input select a nested app when
discovery is ambiguous; they do not create separate release branch and tag
namespaces. Repositories that must release multiple apps independently should
use separate Git repositories until app-scoped namespaces are supported.

After upgrading SMF, refresh only the generated workflow without touching
configuration or release state:

```bash
dart run smf init --workflow-only
```

Review and commit the resulting workflow diff before the next release.

Commit both files with a non-release message such as
`chore: configure smf` before merging new release-worthy work. The
first plan derives the release baseline from the commit that introduced
`config.yaml`, so existing repository history is not released accidentally.

The release flow creates `manifest.json`, `changelog.json`, and candidate
receipts only when they first carry release state. Users do not create or edit
those machine-owned files. `store-release-notes.json` is different: it remains
absent unless a maintainer or hook supplies at least one localized note.

### CLI and Dart API

After adding `smf` to `dev_dependencies`, invoke its project-local CLI through
`dart run`. The package offers one discoverable command with subcommands:

```bash
dart run smf --help
dart run smf validate
dart run smf plan
dart run smf open-pr
dart run smf testflight
dart run smf app-store
```

Success writes one JSON value to stdout, so the same commands compose cleanly
inside custom GitHub workflows. Diagnostics go to stderr. `release` aliases
`open-pr`, `candidate` aliases `testflight`, and `promote` aliases `app-store`.

Package-qualified executables are also available when a single-purpose command
fits better:

```bash
dart run smf:init
dart run smf:open_pr
dart run smf:release
dart run smf:testflight
dart run smf:promote
dart run smf:app_store
```

Custom Dart automation imports the same implementation used by the Action:

```dart
import 'package:smf/smf.dart';

Future<void> main() async {
  final paths = resolveSmfPaths('.');
  await validateRepository(paths.directory);
  final manifest = await loadManifest(paths.directory);
  final plan = await createReleasePlan(
    paths.repositoryRoot,
    manifest,
    Platform.ios,
  );
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
organization owner to enable it or give the pull-request step a GitHub App installation
token (preferred) or narrowly scoped personal access token:

```yaml
- uses: Ventairy/smf-action@v1
  with:
    phase: pull-request
    github-token: ${{ secrets.SMF_GITHUB_TOKEN }}
```

For a fine-grained personal access token, grant access only to the Flutter
repository and give it Contents, Pull requests, and Issues read/write access.
The same token performs the authenticated release-branch push. Treat the
alternative token as a release secret.

The default `GITHUB_TOKEN` does not trigger separate workflow runs for events
it creates. That does not affect smf's release-candidate job—the generated
workflow dispatches it from the pull-request job's outputs—but it can suppress your
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
| `SMF_GITHUB_TOKEN` or `GITHUB_TOKEN`                  | `open-pr`, `release`, promotion |
| `GITHUB_REPOSITORY`                                              | GitHub commands; `owner/name` |
| `SMF_APP_STORE_CONNECT_KEY_ID`                       | TestFlight and App Store |
| `SMF_APP_STORE_CONNECT_ISSUER_ID`                    | TestFlight and App Store |
| `SMF_APP_STORE_CONNECT_PRIVATE_KEY_BASE64`           | TestFlight and App Store |
| `SMF_IOS_CERTIFICATE_BASE64`                         | TestFlight candidate     |
| `SMF_IOS_CERTIFICATE_PASSWORD`                       | TestFlight candidate     |
| `SMF_IOS_PROVISIONING_PROFILES_BASE64`               | TestFlight candidate     |

For local files, replace the private key, certificate, or profile Base64
variable with its `_PATH` form:

```text
SMF_APP_STORE_CONNECT_PRIVATE_KEY_PATH
SMF_IOS_CERTIFICATE_PATH
SMF_IOS_PROVISIONING_PROFILES_PATH
```

Set exactly one source for each credential. The certificate password remains
an environment secret. GitHub automation can alternatively use
`--github-token-file`; raw token arguments are intentionally unsupported.

### 4. Configure TestFlight and submission behavior

The generated `smf/config.yaml` includes a JSON Schema directive
for editor validation and autocomplete. It is ready for a standard Flutter app;
add TestFlight group names if builds should be assigned automatically:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/Ventairy/smf/main/schemas/config.schema.json

schema_version: 1
# flavor: production
target_branch: main
platforms:
  ios:
    enabled: true
    bundle_id: com.example.myapp
    testflight:
      groups:
        - Internal
      wait_timeout_minutes: 45
    app_store:
      mode: upload
```

- `auto` submits the tested build for App Review and releases it automatically
  after Apple approval.
- `review` submits the tested build for App Review and waits for you to release
  it manually after approval.
- `upload` keeps the tested build in TestFlight/App Store Connect without
  submitting it for review.

The initializer deliberately defaults to `upload`. Change it to `review` or
`auto` only after the first candidate succeeds and the app's submission
metadata is complete.

The complete contract is in [Configuration](doc/configuration.md).

For a standard Flutter app, no build fields are needed. smf uses
`fvm flutter build ipa --release` when the project or an ancestor declares FVM,
and `flutter build ipa --release` otherwise. It reads the single IPA from
`build/ios/ipa`, matching Flutter's standard iOS output. Add `build_command`
only for a custom wrapper or build system. Add `ipa_output_path` only when that
custom command writes the IPA somewhere else.

The generated workflow resolves FVM only from the selected app and its
ancestors. It installs that declared SDK for the release-candidate job, or
current stable Flutter when the selected app does not use FVM. The
pull-request job installs the same project toolchain only when
`before_create_pr.dart` exists. The Action's private Dart runtime remains
isolated and does not replace the consumer's Flutter toolchain.

## Store release notes

Notes are optional and user-owned. Create
`smf/store-release-notes.json` only when a release has localized
notes, under the platform, version, and Apple locale:

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

If the file or a version is absent, smf sends no notes and does not
create an empty placeholder. Apple may still require “What’s New” for an App
Store update and will return a precise submission error if the version metadata
is incomplete.

### Generate notes before the PR opens

Create `smf/hooks/before_create_pr.dart` and implement the typed hook:

```dart
import 'package:smf/smf.dart';

final class GenerateStoreReleaseNotes extends SmfHook {
  @override
  Future<void> run(SmfBeforeCreatePrContext context) async {
    // Generate context.storeReleaseNotesFile from context.releasePlan.
  }
}

Future<void> main() async {
  await runSmfHook(GenerateStoreReleaseNotes());
}
```

The typed context exposes the repository, Flutter app, SMF directory, config,
changelog, optional notes file, flavor, platform, current platform version,
next platform version, and full release plan. The process also receives:

```text
SMF_PLATFORM
SMF_CURRENT_PLATFORM_VERSION
SMF_PLATFORM_VERSION
SMF_REPOSITORY_ROOT
SMF_APP_ROOT
SMF_PATH
SMF_CONFIG_PATH
SMF_CHANGELOG_PATH
SMF_STORE_RELEASE_NOTES_PATH
```

The changelog and next version already exist when the hook runs, so an AI or translation script can write deterministic drafts into the release PR for human review.

Project preparation uses the matching `smf/hooks/before_build.dart` file and
`SmfBeforeBuildContext`. Each `SmfHook` defaults `commitChanges` to `true`, so
every tracked or unignored file it leaves is committed to the release branch.
Override it to `false` only when the hook leaves the worktree clean, produces
ignored/external output, or performs its own commit.

The optional `build_command` overrides automatic Flutter/FVM selection.
smf automatically appends the planned version, next App Store build
number, generated export-options plist, and configured flavor:

```yaml
platforms:
  ios:
    build_command: fvm dart run release:build_ios
    ipa_output_path: dist/ios
```

Keep it to one command invocation, such as `flutter build` or a Dart wrapper
that accepts those appended arguments. Put chaining, preparation, logging, and
verification in `smf/hooks/before_build.dart`. Omit `ipa_output_path` unless the
wrapper moves the IPA away from Flutter's standard `build/ios/ipa` directory.

See [Configuration](doc/configuration.md) for hook context, managed arguments,
artifact validation, and configuration details.

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

- The Ubuntu `pull-request` job plans or updates `smf/ios`.
- A macOS 26 job installs the project-selected Flutter toolchain, imports
  temporary signing material, runs the configured IPA build, uploads it, waits
  for `VALID`, writes TestFlight notes, assigns groups, and commits the
  candidate receipt.
- After the release PR merges, an Ubuntu job verifies the receipt, promotes the exact Apple build, and creates `ios-vX.Y.Z`.

GitHub does not create new workflow runs for events produced by the default
`GITHUB_TOKEN`. The TestFlight release-candidate job is unaffected because it continues
in the workflow that opened the PR. Your repository's separate `pull_request`
workflows, however, will not run for that generated PR.

If independent PR checks must run, generate a GitHub App installation token
(preferred) or use a narrowly scoped personal access token and pass it as the
pull-request step's `github-token` input. This is optional; do not add a long-lived
token merely for smf's own jobs.

Secrets are passed only as action inputs, masked by GitHub, written with restrictive permissions, and removed during cleanup. See [Security model](doc/security.md).

## Requirements

- Dart 3.10 or newer for the package CLI and custom automation. The GitHub
  Action installs its own pinned Dart SDK.
- A modern Flutter app with an `ios` project.
- A committed, current `pubspec.lock`; the project-owned build command must not
  introduce uncommitted dependency changes.
- A GitHub-hosted or self-hosted macOS runner capable of Xcode 26 builds.
- An existing App Store Connect app record; Apple does not let the API create one.
- An App Store Connect API key with `Developer` access for upload delivery
  without TestFlight groups, or at least `App Manager` access for group
  assignment and App Review submission; plus an Apple Distribution certificate
  and App Store provisioning profile.
- Required App Store product metadata already configured for the app.

Run `dart run smf validate` locally to catch repository
configuration problems before CI.

## Contributing to the core

The package uses Freezed and json_serializable for immutable release state and
typed JSON boundaries. Generated Dart files are committed, so package users do
not run a generator. Contributors changing an annotated model should run
`dart run build_runner build` and review the generated diff. See
[CONTRIBUTING.md](CONTRIBUTING.md) for the complete development gate.

## Validation boundary

The public
[`smf-e2e`](https://github.com/Ventairy/smf-e2e)
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
- [Releasing smf itself](RELEASING.md)
