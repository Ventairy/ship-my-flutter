# Configuration

Each Flutter app keeps its SMF configuration at `smf/config.yaml`. Keys use
Flutter-friendly `snake_case`, and schema version 1 is the only supported
contract.

The generated schema directive enables validation and autocomplete in editors
with YAML language-server support:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/Ventairy/smf/main/packages/smf_engine/schemas/config.schema.json

schema_version: 1
target_branch: main
platforms:
  ios:
    enabled: true
    initial_version: 0.0.0
    testflight:
      groups: []
      wait_timeout_minutes: 45
    app_store:
      mode: upload
```

SMF rejects unknown keys. The JSON Schema helps while editing, but
`smf validate` is authoritative for cross-field, shell, and filesystem safety
checks.

## App and configuration discovery

The `smf` directory must be a direct child of the Flutter app:

```text
repository/
  .github/workflows/smf.yml
  apps/mobile/
    pubspec.yaml
    ios/
    smf/
      config.yaml
      hooks/
```

The CLI and Action search forward from their working directory for
`smf/config.yaml`. One match is selected automatically. Zero matches fail with
initialization guidance. Multiple matches fail and list every candidate; pass
`--smf-path apps/mobile/smf` to the executable or
`smf-path: apps/mobile/smf` to the Action.

The explicit path must point directly to a directory named `smf`, stay below
the working directory, and contain `config.yaml`. Discovery does not follow
symbolic links and prunes Git metadata, hidden directories, build output,
dependency caches, FVM caches, and `node_modules`.

`smf init` is run from the Flutter app directory. It writes
`<app>/smf/config.yaml` and `<repository>/.github/workflows/smf.yml`; there is
no configurable app-path field. The generated workflow pins that exact
repository-relative `smf/` path and supplies it to every Action phase.

One Git repository currently supports one independently released SMF app.
Explicit path selection resolves discovery in a repository that contains
multiple app directories, but it does not namespace the shared `smf/ios`
release branch or `ios-vX.Y.Z` tags. Keep independently released apps in
separate repositories until SMF adds app-scoped release namespaces.

## Global fields

| Field | Default | Meaning |
| --- | --- | --- |
| `schema_version` | required | Configuration contract; currently `1` |
| `flavor` | none | Optional Flutter `--flavor` and matching Xcode scheme |
| `target_branch` | `main` | Branch whose commits feed release PRs |
| `platforms` | required | Platform-scoped release configuration |

A Flutter invocation accepts one flavor. SMF therefore exposes one optional
global `flavor`, shared by current and future platform builds.

## iOS fields

| Field | Default | Meaning |
| --- | --- | --- |
| `enabled` | `true` | Enable iOS release planning and delivery |
| `initial_version` | `0.0.0` | Current iOS marketing version before the first generated manifest |
| `bundle_id` | detected on macOS | Explicit App Store bundle identifier |
| `build_command` | automatic | One trusted POSIX shell build invocation |
| `ipa_output_path` | `build/ios/ipa` | IPA file or directory relative to the Flutter app |
| `testflight.groups` | `[]` | Exact existing TestFlight group names |
| `testflight.wait_timeout_minutes` | `45` | Apple processing wait, from 5 through 180 minutes |
| `app_store.mode` | `upload` | Delivery behavior after the release PR merges |

`initial_version` is a base, not a fixed next version. Conventional Commits
bump it until generated `manifest.json` becomes authoritative.

`bundle_id` can be omitted on macOS. SMF reads Xcode build settings for the
configured flavor or the `Runner` scheme. Configure it explicitly when
validation or promotion runs without Xcode.

The App Store modes are:

- `auto`: submit for review and release automatically after Apple approval;
- `review`: submit for review but wait for manual release after approval;
- `upload`: keep the exact tested build uploaded without submitting review.

## Build command and IPA output

With no `build_command`, SMF selects:

- `fvm flutter build ipa --release` when the app or an ancestor up to the Git
  root contains `.fvmrc` or `.fvm/fvm_config.json`;
- `flutter build ipa --release` otherwise.

The project workflow owns Flutter/FVM installation. SMF appends these managed
arguments:

```text
--build-name "$SMF_PLATFORM_VERSION"
--build-number "$SMF_BUILD_NUMBER"
--export-options-plist "$SMF_EXPORT_OPTIONS_PATH"
--flavor "$SMF_FLAVOR" # only when flavor is configured
```

The same values are available in the environment, together with
`SMF_PLATFORM=ios` and `SMF_IPA_OUTPUT_PATH`. A configured build command must
not supply managed flags. It is one shell invocation; put preparation,
pipelines, chaining, or redirection in a typed hook instead.

The default output matches Flutter's standard `build/ios/ipa` directory.
Configure `ipa_output_path` only when a custom command writes elsewhere. It
must remain inside the Flutter app after symbolic-link resolution and contain
exactly one IPA, or point directly to one IPA.

## Typed hooks

Hooks are Dart files, not YAML commands:

- `smf/hooks/before_create_pr.dart` runs after SMF prepares the version and
  changelog, before the release PR is opened or updated;
- `smf/hooks/before_build.dart` runs on the release branch before source
  fingerprinting and candidate creation.

Each existing hook must be a tracked regular file. SMF runs it from the
Flutter app with `fvm dart run` when the app uses FVM and `dart run` otherwise.
The entrypoint must call `runSmfHook`:

```dart
import 'package:smf_hooks/smf_hooks.dart';

final class GenerateNotes extends SmfHook {
  @override
  Future<void> run(SmfBeforeCreatePrContext context) async {
    // Use context.releasePlan and context.storeReleaseNotesFile.
  }

  // Defaults to true.
  @override
  bool get commitChanges => true;
}

Future<void> main() async {
  await runSmfHook(GenerateNotes());
}
```

`SmfHookContext` provides typed directories/files for the repository, app, SMF
state, configuration, changelog, and store notes, plus platform, platform
version, and flavor. `SmfBeforeCreatePrContext` adds the current platform
version and `ReleasePlan`; `SmfBeforeBuildContext` adds the
`ChangelogRelease`.

When `commitChanges` is true, SMF commits every tracked or unignored change
left by the hook. When false, the hook must commit its own changes or leave a
clean worktree. Absent hook files are skipped.

Hooks also receive non-secret `SMF_*` path and version variables for
subprocess interoperability. Apple and GitHub credential variables are
stripped before repository-owned code runs.

The generated workflow installs the selected app's project toolchain before
running an existing hook. The pull-request job skips that installation when
`before_create_pr.dart` is absent; the release-candidate job always installs
the selected app's Flutter/FVM toolchain for the build.

## Persisted release state

SMF creates these files only when needed:

```text
smf/manifest.json
smf/changelog.json
smf/store-release-notes.json
smf/candidates/ios-<version>.json
```

The manifest, changelog, and candidate receipts are machine-owned JSON audit
state. Store notes are user-owned and optional; SMF never creates an empty
placeholder. Secrets never belong in any persisted file.
