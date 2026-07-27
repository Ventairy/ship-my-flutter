# Getting started

This is the complete setup path for a standard Flutter repository using the
generated GitHub Actions workflow.

The safe first run uploads candidates only:

- iOS goes to TestFlight without App Review submission.
- Android goes to the configured testing track without changing production.

## 1. Confirm the repository is ready

You need:

- a Git repository hosted on GitHub;
- one Flutter app with `ios/`, `android/`, or both;
- a stable target branch such as `main`;
- a committed `pubspec.yaml` and lockfile;
- a local build that succeeds for every enabled platform; and
- permission to add workflows, Actions secrets, and repository settings.

One Git repository currently supports one independently released SMF app. A
nested Flutter app is supported; multiple independently released apps should
use separate repositories until app-scoped branch/tag namespaces exist.

## 2. Choose the current platform versions

`initial_version` is the latest version already represented by each platform’s
release history, not the version you want SMF to create next.

- Existing iOS app: latest shipped App Store marketing version.
- Existing Android app: latest shipped Google Play marketing version.
- New platform: normally `0.0.0`, then put
  `Release-As-ios: 1.0.0` or `Release-As-android: 1.0.0` in the first
  release-worthy commit.

If iOS and Android currently have different versions, initialize with one value
and then edit each `initial_version` before committing.

## 3. Install the CLI

```bash
dart install smf_cli
smf --help
```

The Flutter app does not add `smf_cli` or another SMF package to
`dev_dependencies`.

## 4. Initialize from the Flutter app

For a two-platform app:

```bash
smf init \
  --current-version 1.0.0 \
  --bundle-id com.example.myapp \
  --package-name com.example.myapp
```

For iOS only, omit `--package-name`. For Android only, omit `--bundle-id`.
SMF enables the platform directories that actually exist.

In a monorepo:

```bash
cd apps/mobile
smf init \
  --current-version 1.0.0 \
  --bundle-id com.example.myapp \
  --package-name com.example.myapp
```

This creates:

```text
<flutter-app>/smf/config.yaml
<repository>/.github/workflows/smf.yml
```

The workflow records the exact relative `smf/` path. After an SMF upgrade,
refresh only the generated workflow with:

```bash
smf init --workflow-only
```

Always review that diff.

## 5. Review the generated configuration

Open `<flutter-app>/smf/config.yaml`.

For iOS:

- confirm `enabled`;
- confirm `initial_version`;
- set the exact production `bundle_id`;
- leave `testflight.groups: []` until the group exists; and
- keep `app_store.mode: upload`.

For Android:

- confirm `enabled`;
- confirm `initial_version`;
- set the exact production `package_name`, especially for flavors;
- keep `testing_track: internal`;
- keep `production_track: production`; and
- keep `google_play.mode: upload`.

If the app uses a Flutter flavor, set the one global `flavor`. See
[Configuration](configuration.md) before adding custom build commands.

Run:

```bash
smf validate
```

Commit initialization with a non-release message:

```bash
git add smf/config.yaml .github/workflows/smf.yml
git commit -m "chore: configure smf"
git push
```

Commit this before merging release-worthy work. It establishes the baseline so
SMF does not treat old repository history as a new release.

## 6. Complete each enabled store setup

For iOS, follow [Set up Apple delivery](apple-bootstrap.md). It creates/verifies
the App IDs, App Store Connect app, API key, distribution certificate,
provisioning profiles, optional internal TestFlight group, and six GitHub
secrets.

For Android, follow
[Set up Android and Google Play delivery](android-bootstrap.md). It
creates/verifies the Play app, Play App Signing, upload key, internal tester
list, service account, permissions, and five GitHub secrets.

Return here only after each enabled platform’s final checklist passes.

## 7. Allow Actions to create the release PR

In the Flutter repository:

1. Open **Settings → Actions → General**.
2. Find **Workflow permissions**.
3. Enable **Allow GitHub Actions to create and approve pull requests**.
4. Save.

Organization policy can lock this setting. Ask an organization owner if it is
disabled.

The default `GITHUB_TOKEN` can run SMF. If your normal `pull_request` checks
must trigger on the generated PR, use a GitHub App installation token
(preferred) or a narrowly scoped fine-grained token as explained in
[GitHub permissions](security.md#github-permissions).

## 8. Add an optional preparation hook

Skip this section unless the build requires generated, tracked inputs or
release notes immediately before planning/building.

Add `smf_hooks`:

```bash
dart pub add --dev smf_hooks
```

Create:

```text
<flutter-app>/smf/hooks/before_create_pr.dart
<flutter-app>/smf/hooks/before_build.dart
```

Use [Configuration: hooks](configuration.md#hooks). Hooks execute trusted
repository code in a credential-aware release workflow and require release
owner review.

## 9. Create a harmless release-worthy commit

Use the real change’s Conventional Commit message. Examples:

```text
fix: prevent startup crash
fix(ios): repair camera permission
fix(android): repair back navigation
feat(auth): add passkeys
```

For a first `1.0.0` release from `0.0.0`, include the platform footer:

```text
feat(android): prepare first Android release

Release-As-android: 1.0.0
```

Push to the configured target branch.

## 10. Review the shared release PR

The workflow opens or updates branch `smf/release`.

The PR can contain iOS, Android, or both. Verify:

- each planned platform and version is expected;
- the changelog matches the qualifying commits;
- store notes are accurate;
- only intended platforms are included; and
- the `release-candidate (<platform>)` jobs succeed.

Do not merge yet.

## 11. Test every exact candidate

For iOS:

1. Open App Store Connect → TestFlight.
2. Match the receipt’s `version`, `buildNumber`, and `artifactId`.
3. Install that build through TestFlight.

For Android:

1. Open Play Console → Internal testing.
2. Match the receipt’s `version`, `buildNumber`, and `artifactId`
   (`artifactId` is the Play `versionCode`).
3. Install from the internal-test opt-in link.

For both:

- complete the team’s release test;
- verify localized notes;
- verify the candidate receipt is committed under `smf/candidates/`; and
- obtain release-owner approval.

The receipt is machine-owned. Never edit it.

## 12. Merge safely

With both platform modes still set to `upload`, merging verifies the candidate
and creates the platform tag/GitHub Release, but does not submit iOS for App
Review or move Android to production.

After the upload-only cycle succeeds, choose the desired behavior:

- iOS: `upload`, `review`, or `auto`.
- Android: `upload`, `review`, or `auto`.

Android `review` requires Play Console Managed Publishing to be enabled; see
[Android setup](android-bootstrap.md#10-decide-how-production-will-work-later).

Changing delivery settings updates the release PR. Recheck the candidate
before merging.

## 13. Confirm completion

After merge, watch the `ship (<platform>)` jobs.

Expected tags:

```text
ios-vX.Y.Z
android-vX.Y.Z
```

Then confirm the exact recorded artifacts have the intended store status. A
green GitHub job does not replace checking App Store Connect or Play Console.

For failures, keep the release branch and receipt intact and use
[Release operations and recovery](operations.md).
