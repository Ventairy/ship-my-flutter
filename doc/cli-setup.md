# CLI setup

Use this setup when a human or custom automation will run SMF release phases
directly. For the automated path recommended for most teams, follow
[GitHub Actions setup](github-actions-setup.md).

The safe first release creates candidates for testing before anything is
shipped. Do not run the `ship` phase until the release PR is merged and the
exact candidates have been approved.

## 1. Confirm the repository is ready

You need:

- a Git repository hosted on GitHub;
- at least one Flutter app with `ios/`, `android/`, or both;
- a stable target branch such as `main`;
- a local release build that succeeds for every enabled platform;
- access to create release pull requests and GitHub Releases; and
- the store, signing, and API credentials required for every enabled platform.

SMF supports multiple independently released Flutter apps in one repository.
Initialize each app separately.

## 2. Install the CLI

```bash
dart install smf_cli
smf --help
```

The Flutter app does not add an SMF package to `dev_dependencies`.

## 3. Initialize an app without GitHub Actions

The initial version is the latest version already shipped for the platform,
not the version you want SMF to create next. For a new app or newly enabled
platform, this is normally `0.0.0`.

For a Flutter app at the repository root:

```bash
smf init --version 1.0.0 --ios-bundle-id com.acme.myapp --android-package-name com.acme.myapp --no-github-actions
```

For a nested Flutter app:

```bash
smf init --app-path apps/mobile --app-id mobile --version 1.0.0 --ios-bundle-id com.acme.myapp --android-package-name com.acme.myapp --no-github-actions
```

Add `--platform ios` or `--platform android` to initialize only one platform,
even when the Flutter project contains both native directories. Omit
`--platform` to configure every detected platform. If the platforms have
different current versions, use `--ios-version` and `--android-version`
instead of `--version`.

SMF creates `<flutter-app>/smf/config.yaml` and does not create a workflow.
Choose a permanent, repository-unique `app_id`, especially for monorepos. It
names the app's release branch, tags, GitHub Releases, and other release
resources.

Initialize every app independently:

```bash
smf init --app-path apps/customer --app-id customer --version 1.0.0 --ios-bundle-id com.acme.customer --android-package-name com.acme.customer --no-github-actions
smf init --app-path apps/driver --app-id driver --version 1.0.0 --ios-bundle-id com.acme.driver --android-package-name com.acme.driver --no-github-actions
```

Run `smf init --help` for version detection and the complete option list.

## 4. Review and validate the configuration

Open `<flutter-app>/smf/config.yaml`. Confirm:

- `app_id` is the permanent identity you intend to keep;
- every platform identifier matches its production store record;
- each `initial_version` is the latest version already shipped; and
- `release_trigger_paths` includes shared repository paths that should release
  this app.

See [Configuration](configuration.md) before changing flavors, build commands,
candidate destinations, or ship destinations.

Validate every initialized app:

```bash
smf validate
```

To validate only one:

```bash
smf validate --smf-path apps/customer/smf
```

Validation does not contact GitHub or either store and cannot prove that local
credentials are correct. The credentialed release-candidate phase performs
those external checks.

## 5. Prepare each enabled store

For iOS, follow [Set up Apple delivery](apple-bootstrap.md) for the App ID, App
Store Connect app, API key, distribution certificate, and TestFlight group.
Provide its five credentials using the
[CLI environment-variable instructions](apple-bootstrap.md#cli-environment-variables).

For Android, follow
[Set up Android and Google Play delivery](android-bootstrap.md) for the Play
app, Play App Signing, upload key, tester list, service account, permissions,
and SMF configuration. Provide its five credentials using the
[CLI environment-variable instructions](android-bootstrap.md#cli-environment-variables).

Also export `SMF_GITHUB_TOKEN` as described in
[Supply credentials](cli.md#supply-credentials). Never commit credentials,
service-account JSON, certificates, or keystores.

The pull-request phase needs the GitHub token, not store/signing credentials.
The candidate phase needs the GitHub token plus every credential for the
selected platform. The ship phase needs the GitHub token plus that platform's
store API credentials, but not its certificate or keystore.

## 6. Add an optional preparation hook

Skip this step unless the build requires generated tracked inputs or release
notes immediately before planning or building.

```bash
dart pub add --dev smf_hooks
```

Follow [Typed hooks](hooks.md) to add `before_create_pr.dart` or
`before_build.dart`. Hooks are trusted repository code and run inside the
credential-aware release process.

## 7. Prepare the release pull request

Get a real release-worthy Conventional Commit onto the configured target
branch:

```text
fix: prevent startup crash
feat(auth): add passkeys
feat!: replace the account model
```

Export `SMF_GITHUB_TOKEN` and any custom variables needed by
`before_create_pr`, then run:

```bash
smf release --phase pull-request
```

SMF fetches the configured remote target branch into an isolated temporary
checkout and plans from that source. Your current branch, uncommitted files,
and unpushed commits do not participate.

For a monorepo with more than one initialized app, select the app:

```bash
smf release --phase pull-request --smf-path apps/customer/smf
```

SMF opens or updates `smf/<app-id>/release`. Review the planned platform
versions and changelogs before creating candidates. The command's JSON output
includes the exact release branch.

## 8. Create and test the candidates

Run the candidate phase on the required native host:

```bash
smf release --phase release-candidate
```

SMF fetches the remote release branch into an isolated temporary checkout,
builds and records candidates there, then deletes that checkout. It does not
depend on or switch your local branch.

Use `--platform ios` or `--platform android` to process only one platform.
Run iOS on macOS. Run Android candidates on macOS or Linux. Windows supports
the pull-request and ship phases, but candidate builds currently require the
POSIX command environment available on macOS or Linux.

In a monorepo, keep selecting the same app:

```bash
smf release --phase release-candidate --smf-path apps/customer/smf
```

Verify that the candidate receipt was committed under `smf/candidates/`. Match
its version, build number, and artifact ID in TestFlight or Play Console,
install that exact candidate, and complete the team's release test.

Do not merge the release PR until every intended candidate is approved.

## 9. Merge and ship the exact candidates

Merge the approved release PR through the repository's normal review process.
Then run from anywhere inside the same Git repository:

```bash
smf release --phase ship
```

In a monorepo:

```bash
smf release --phase ship --smf-path apps/customer/smf
```

The command promotes the recorded candidate; it does not rebuild it. A missing
merge, source mismatch, fingerprint mismatch, or artifact identity mismatch
stops the operation.

New configurations omit `ship`, so the first candidate-only cycle cannot move
an artifact toward public distribution. After that cycle is proven, configure
an explicit destination using [Apple targets](configuration.md#apple-targets)
or [Google Play targets](configuration.md#google-play-targets).

## 10. Verify and recover

Confirm the expected tags and GitHub Releases:

```text
<app-id>/ios-vX.Y.Z
<app-id>/android-vX.Y.Z
```

Also confirm the exact recorded artifacts have the intended store status. A
successful CLI result does not replace checking App Store Connect or Play
Console.

For retries, failures, or abandonment, keep the release branch and candidate
receipt intact and follow
[Release operations and recovery](operations.md).

To adopt the recommended automated workflow later, run from the Flutter app:

```bash
smf init --github-actions
```

For a nested app, add `--app-path`. This creates only the workflow and does not
replace `smf/config.yaml` or release state. Review and commit the generated
workflow, then continue with
[GitHub Actions setup](github-actions-setup.md#6-allow-actions-to-create-the-release-pr).
