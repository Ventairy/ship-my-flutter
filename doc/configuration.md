# Configuration

SMF reads `<flutter-app>/smf/config.yaml`.

The generated file includes a schema hint for editor validation:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/Ventairy/smf/main/packages/smf_engine/schemas/config.schema.json
```

Run `smf validate` after every change.

## Complete example

```yaml
schema_version: 1
target_branch: main
flavor: production

platforms:
  ios:
    enabled: true
    initial_version: 2.4.0
    bundle_id: com.example.myapp
    testflight:
      groups:
        - Internal
      wait_timeout_minutes: 45
    app_store:
      mode: upload

  android:
    enabled: true
    initial_version: 2.3.1
    package_name: com.example.myapp
    google_play:
      testing_track: internal
      production_track: production
      mode: upload
```

iOS and Android versions are intentionally independent.

## Global fields

| Field | Required/default | Meaning |
| --- | --- | --- |
| `schema_version` | required, currently `1` | Configuration format |
| `target_branch` | required | Branch containing normal application work |
| `flavor` | optional | One Flutter flavor passed to enabled platform builds |
| `platforms` | required | iOS and Android configuration |

At least one supported platform must be enabled.

One Git repository currently supports one independently released SMF app.
`--smf-path` selects a nested app but does not create separate branch/tag
namespaces for sibling apps.

## iOS

```yaml
platforms:
  ios:
    enabled: true
    initial_version: 2.4.0
    bundle_id: com.example.myapp
    build_command: flutter build ipa --release
    ipa_output_path: build/ios/ipa
    testflight:
      groups: [Internal]
      wait_timeout_minutes: 45
    app_store:
      mode: upload
```

| Field | Default | Meaning |
| --- | --- | --- |
| `enabled` | `true` when `ios/` exists at initialization | Include iOS |
| `initial_version` | initializer version | Existing iOS release baseline |
| `bundle_id` | detected when possible | Exact App Store bundle ID |
| `build_command` | FVM-aware Flutter IPA command | Trusted project build command |
| `ipa_output_path` | `build/ios/ipa` | App-contained IPA file or directory |
| `testflight.groups` | `[]` | Exact existing internal group names |
| `testflight.wait_timeout_minutes` | `45` | Processing wait, 5–180 |
| `app_store.mode` | `upload` | Post-merge App Store behavior |

The bundle ID must match the production Xcode target, App ID, provisioning
profile, and App Store Connect app.

App Store modes:

- `upload`: verify the tested build only; do not submit App Review.
- `review`: submit and wait for manual release after approval.
- `auto`: submit and allow automatic release after approval.

## Android

```yaml
platforms:
  android:
    enabled: true
    initial_version: 2.3.1
    package_name: com.example.myapp
    build_command: flutter build appbundle --release
    aab_output_path: build/app/outputs/bundle/release
    google_play:
      testing_track: internal
      production_track: production
      mode: upload
```

| Field | Default | Meaning |
| --- | --- | --- |
| `enabled` | `true` when `android/` exists at initialization | Include Android |
| `initial_version` | initializer version | Existing Android release baseline |
| `package_name` | detected for simple apps | Exact Google Play package name |
| `build_command` | FVM-aware Flutter AAB command | Trusted project build command |
| `aab_output_path` | standard release bundle directory | App-contained AAB file or directory |
| `google_play.testing_track` | `internal` | Existing candidate track |
| `google_play.production_track` | `production` | Destination track after approval |
| `google_play.mode` | `upload` | Post-merge Google Play behavior |

Set `package_name` explicitly for flavors, suffixes, or computed Gradle
application IDs.

SMF chooses the next available Play `versionCode`, passes it as Flutter’s
`--build-number`, signs the resulting AAB with the configured upload key, and
records that same integer as the candidate `artifactId`.

Google Play modes:

- `upload`: keep the exact bundle on the testing track; do not update
  production.
- `review`: move the exact `versionCode` to production and send it for review;
  **Managed Publishing must already be enabled** so a person controls final
  publication.
- `auto`: move the exact `versionCode` to production and allow normal
  publication after Play review.

`testing_track` and `production_track` must be different. SMF will not replace
a production track with an unfinished release.

## Custom build commands

Usually omit `build_command`. SMF selects:

```text
flutter build ipa --release
flutter build appbundle --release
```

or the corresponding `fvm flutter ...` command when the selected app/repository
declares FVM.

When a custom command is configured:

- it is trusted repository code executed through a POSIX shell;
- SMF appends the planned `--build-name` and store build number;
- SMF appends `--flavor` when `flavor` is set;
- it must produce exactly one artifact in the configured output path; and
- it must not leave tracked or unignored changes.

Both artifact paths must stay inside the Flutter app. Symbolic links that
escape the app are rejected.

## Store release notes

Localized notes are optional and live at:

```text
<flutter-app>/smf/store-release-notes.json
```

Example:

```json
{
  "ios": {
    "2.5.0": {
      "en-US": "Faster search and a clearer saved-items screen.",
      "pt-BR": "Busca mais rápida e uma tela de itens salvos mais clara."
    }
  },
  "android": {
    "2.4.0": {
      "en-US": "Faster search and improved back navigation."
    }
  }
}
```

Use store-supported locale identifiers. The file can be written by a release
owner or a hook. It remains absent when there are no notes.

## Commit routing

Recognized platform scopes are `ios` and `android`. Other known ecosystem
scopes (`web`, `macos`, `windows`, `linux`) are excluded from these platforms.
Feature scopes such as `auth` apply to all enabled platforms.

| Commit | Platforms | Bump |
| --- | --- | --- |
| `fix: prevent crash` | all enabled | patch |
| `feat(auth): add passkeys` | all enabled | minor |
| `fix(ios): repair entitlement` | iOS | patch |
| `fix(android): repair navigation` | Android | patch |
| `perf(ios,android): speed startup` | both | patch |
| `chore: update docs` | none | none |

Explicit stable versions:

```text
Release-As-ios: 3.0.0
Release-As-android: 2.8.0
```

Prerelease/build metadata values are rejected.

## Hooks

Add the lightweight SDK only when hooks are needed:

```bash
dart pub add --dev smf_hooks
```

Supported files:

```text
smf/hooks/before_create_pr.dart
smf/hooks/before_build.dart
```

`before_create_pr` receives every platform plan included in the shared PR.
`before_build` runs once per candidate with its platform and version.

Return `commit: true` only for deterministic files that belong in the release
PR, such as generated release notes. Return `commit: false` only when all
changes are ignored/untracked build outputs; tracked changes cause a hard stop.

Hooks and custom build commands are trusted deployment code. Review them before
they run with release permissions.

## Machine-owned files

SMF creates these only when needed:

| Path | What users do |
| --- | --- |
| `manifest.json` | Review; never edit manually |
| `changelog.json` | Review; never edit manually |
| `candidates/ios-X.Y.Z.json` | Match to TestFlight; never edit |
| `candidates/android-X.Y.Z.json` | Match to Play `versionCode`; never edit |

Use [How releases work](how-it-works.md) for the integrity boundary and
[Operations](operations.md) before resolving conflicts or retrying a release.
