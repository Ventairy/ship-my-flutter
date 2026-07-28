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
app_id: my_app
target_branch: main
flavor: production
release_trigger_paths:
  - packages/shared_models/**

platforms:
  ios:
    enabled: true
    initial_version: 2.4.0
    bundle_id: com.example.myapp
    app_store:
      release_candidate:
        target: internal-testing
        groups:
          - Internal
        wait_timeout_minutes: 45
      ship:
        target: submit-for-review

  android:
    enabled: true
    initial_version: 2.3.1
    package_name: com.example.myapp
    google_play:
      release_candidate:
        target: internal-testing
      ship:
        target: production
```

iOS and Android versions are intentionally independent.

## Global fields

| Field                   | Required/default        | Meaning                                                                |
| ----------------------- | ----------------------- | ---------------------------------------------------------------------- |
| `schema_version`        | required, currently `1` | Configuration format                                                   |
| `app_id`                | required, generated     | Stable identity for this app's release resources                       |
| `target_branch`         | required                | Branch containing normal application work                              |
| `flavor`                | optional                | One Flutter flavor passed to enabled platform builds                   |
| `release_trigger_paths` | `[]`                    | Additional repository paths whose qualifying commits apply to this app |
| `platforms`             | required                | iOS and Android configuration                                          |

At least one supported platform must be enabled.

`app_id` defaults to the Flutter package name during initialization. It must be
unique within the Git repository and remain unchanged if the app directory or
display name changes. Pass `--app-id` during initialization only when the
package name is unsuitable or already used by another initialized app.

For a nested app, every qualifying commit that changes its app directory
applies to that app automatically. Use `release_trigger_paths` for shared code
outside the app:

```yaml
release_trigger_paths:
  - packages/shared_models/**
  - packages/design_system/**
```

Paths and glob patterns are relative to the Git repository. They cannot be
absolute, escape through `..`, or use Git pathspec magic. A qualifying commit
that changes a shared path applies independently to every app that lists that
path. A root-level Flutter app observes the entire repository, so it does not
need additional trigger paths.

Each app gets its own:

- `.github/workflows/smf-<app-id>.yml`;
- `smf/<app-id>/release` branch and pull request;
- `<app-id>/<platform>-v<version>` tags and GitHub Releases;
- `smf-<app-id>` GitHub Environment; and
- release registry under that app's `smf/` directory.

## iOS

```yaml
platforms:
  ios:
    enabled: true
    initial_version: 2.4.0
    bundle_id: com.example.myapp
    build_command: flutter build ipa --release
    ipa_output_path: build/ios/ipa
    app_store:
      release_candidate:
        target: internal-testing
        groups: [Internal]
        wait_timeout_minutes: 45
      ship:
        target: submit-for-review
```

| Field                                              | Default                                     | Meaning                                           |
| -------------------------------------------------- | ------------------------------------------- | ------------------------------------------------- |
| `enabled`                                          | `true` when `ios/` exists at initialization | Include iOS                                       |
| `initial_version`                                  | initializer version                         | Existing iOS release baseline                     |
| `bundle_id`                                        | detected when possible                      | Exact App Store bundle ID                         |
| `build_command`                                    | FVM-aware Flutter IPA command               | Trusted project build command                     |
| `ipa_output_path`                                  | `build/ios/ipa`                             | App-contained IPA file or directory               |
| `app_store.release_candidate.target`               | `internal-testing`                          | TestFlight audience before merge                  |
| `app_store.release_candidate.groups`               | `[]`                                        | Existing groups matching the candidate target     |
| `app_store.release_candidate.wait_timeout_minutes` | `45`                                        | Processing wait, 5–180 minutes                    |
| `app_store.ship`                                   | omitted                                     | Leave the approved candidate in its testing state |
| `app_store.ship.target`                            | required when `ship` exists                 | [Apple ship destination](#apple-targets)          |
| `app_store.ship.groups`                            | `[]`                                        | Existing external groups for `external-testing`   |

The bundle ID must match the production Xcode target, App ID, provisioning
profile, and App Store Connect app.

### Apple targets

`release_candidate` controls who receives the exact build while the release PR
is open:

| Target             | What SMF does                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| `internal-testing` | Uploads the build and assigns it to the listed internal TestFlight groups. The group list may be empty.                       |
| `external-testing` | Assigns the build to the listed external groups and submits it to TestFlight Beta App Review. At least one group is required. |

App Store Connect identifies every group as internal or external. SMF resolves
the configured names and fails before assigning the build if a group does not
match the selected target.

`ship` is optional. When present, it controls the Apple action after the
release PR is merged:

| Target              | What SMF does                                                                                   |
| ------------------- | ----------------------------------------------------------------------------------------------- |
| `external-testing`  | Assigns the same build to `ship.groups` and submits it to TestFlight Beta App Review.           |
| `submit-for-review` | Submits the same build to App Review with manual release. After approval, a person releases it. |
| `production`        | Submits the same build to App Review with automatic release after approval.                     |

TestFlight Beta App Review and App Review are different reviews.
`external-testing` never submits the app for public App Store distribution.

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
      release_candidate:
        target: closed-testing
        tracks:
          - internal-qa
          - trusted-users
      ship:
        target: production
```

| Field                                  | Default                                         | Meaning                                              |
| -------------------------------------- | ----------------------------------------------- | ---------------------------------------------------- |
| `enabled`                              | `true` when `android/` exists at initialization | Include Android                                      |
| `initial_version`                      | initializer version                             | Existing Android release baseline                    |
| `package_name`                         | detected for simple apps                        | Exact Google Play package name                       |
| `build_command`                        | FVM-aware Flutter AAB command                   | Trusted project build command                        |
| `aab_output_path`                      | standard release bundle directory               | App-contained AAB file or directory                  |
| `google_play.release_candidate.target` | `internal-testing`                              | Play destination before merge                        |
| `google_play.release_candidate.tracks` | `[]`                                            | Existing tracks for `closed-testing`                 |
| `google_play.ship`                     | omitted                                         | Leave the approved candidate on its testing tracks   |
| `google_play.ship.target`              | required when `ship` exists                     | [Google Play ship destination](#google-play-targets) |
| `google_play.ship.tracks`              | `[]`                                            | Existing tracks for `closed-testing`                 |

Set `package_name` explicitly for flavors, suffixes, or computed Gradle
application IDs.

SMF chooses the next available Play `versionCode`, passes it as Flutter’s
`--build-number`, signs the resulting AAB with the configured upload key, and
records that same integer as the candidate `artifactId`.

### Google Play targets

`release_candidate.target` accepts:

| Target             | What SMF does                                          |
| ------------------ | ------------------------------------------------------ |
| `internal-testing` | Assigns the candidate to Google Play internal testing. |
| `closed-testing`   | Assigns it to every existing custom track in `tracks`. |
| `open-testing`     | Assigns it to Google Play open testing.                |

`tracks` is required and must be nonempty only for `closed-testing`. Google
Play supports multiple closed tests, so one candidate can be assigned to
several named tracks without rebuilding it.

`ship` is optional. When present, `ship.target` accepts:

| Target           | What SMF does after merge                                              |
| ---------------- | ---------------------------------------------------------------------- |
| `closed-testing` | Assigns the candidate to every existing custom track in `ship.tracks`. |
| `open-testing`   | Moves the candidate to Google Play open testing.                       |
| `production`     | Moves the candidate to production and sends the change for review.     |

Google Play does not provide a per-release API choice between “publish after
approval” and “wait after approval.” That behavior belongs to the app-wide
**Managed publishing** setting in Play Console:

- when Managed publishing is off, an approved production change publishes
  automatically;
- when Managed publishing is on, the approved change waits for a person to
  publish it from Play Console; and
- SMF cannot enable, disable, verify, or bypass Managed publishing through the
  Google Play Developer API.

SMF will not replace a destination track containing an unfinished release.
Finish or halt that release in Play Console first.

## Candidate-only default

The initializer creates a `release_candidate` for each enabled platform and
omits `ship`. This is the safest first run: merging still revalidates the exact
candidate and creates the platform tag and GitHub Release, but does not move
the store artifact beyond its candidate-testing destination.

Add `ship` independently for each platform only after the complete
candidate-only workflow succeeds. A ship-only configuration change can reuse
an existing candidate after SMF revalidates its source, identity, and store
artifact.

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
owner or a hook. It remains absent when there are no notes. Follow
[Store release notes](store-release-notes.md) for platform behavior,
localization, deterministic generation, and AI-assisted drafting.

## Commit routing

Recognized platform scopes are `ios` and `android`. Feature scopes such as `auth` apply to all enabled platforms.

| Commit                             | Platforms   | Bump  |
| ---------------------------------- | ----------- | ----- |
| `fix: prevent crash`               | all enabled | patch |
| `feat(auth): add passkeys`         | all enabled | minor |
| `feat!: replace account model`     | all enabled | major |
| `fix(ios): repair entitlement`     | iOS         | patch |
| `fix(android): repair navigation`  | Android     | patch |
| `perf(ios,android): speed startup` | both        | patch |
| `chore: update docs`               | none        | none  |

`initial_version` is the only manual version baseline for a platform. After
initialization, SMF calculates later versions from that baseline and qualifying
Conventional Commits. Commit messages cannot override the next version.

## Hooks

Hooks are optional Dart files discovered at
`smf/hooks`. They are not configured in `config.yaml`.

Use the complete [Typed hooks guide](hooks.md) to install `smf_hooks`, choose a
phase, implement the typed context, verify the hook, and recover from a
failure.

## Machine-owned files

SMF creates these only when needed:

| Path                            | What users do                           |
| ------------------------------- | --------------------------------------- |
| `manifest.json`                 | Review; never edit manually             |
| `changelog.json`                | Review; never edit manually             |
| `candidates/ios-X.Y.Z.json`     | Match to TestFlight; never edit         |
| `candidates/android-X.Y.Z.json` | Match to Play `versionCode`; never edit |
| `candidates/*.intent.json`      | Leave intact during a failed upload     |

Use [How releases work](how-it-works.md) for the integrity boundary and
[Operations](operations.md) before resolving conflicts or retrying a release.
After upgrading SMF, use `smf migrate`; never migrate these files by hand.
