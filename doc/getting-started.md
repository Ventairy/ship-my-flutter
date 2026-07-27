# Getting started

This guide installs SMF in one Flutter repository and prepares its first safe
iOS release. The standard path uses the generated GitHub Actions workflow.

Before starting, you need:

- a Flutter app with a committed `ios/` project;
- a committed `pubspec.lock` at the Flutter app or Dart workspace root;
- a Git repository hosted on GitHub;
- Dart 3.10 or newer on the setup machine;
- permission to change the repository's Actions settings and secrets; and
- access to the app's Apple Developer Program team.

If the app does not have its Apple account, identifiers, signing assets, or App
Store Connect record yet, that is expected. The [Apple setup
guide](apple-bootstrap.md) creates them step by step.

> [!WARNING]
> During SMF's pre-release period, stop unless the
> [project status](../README.md#smf) confirms that `smf_cli` and
> `Ventairy/smf-action@v1` are published. The public test fixture is not a
> substitute for live Apple delivery.

## 1. Install the CLI

Install `smf_cli` globally:

```bash
dart install smf_cli
```

Verify the executable is available:

```bash
smf --help
```

If your shell cannot find `smf`, follow Dart's message to add the global
executable directory to `PATH`, restart the terminal, and retry.

## 2. Choose the current iOS version

SMF needs the stable iOS version it should treat as **already released**:

- for an app already on the App Store, use the latest shipped marketing
  version, such as `2.4.1`;
- for an app that has never shipped, use `0.0.0`.

This value is not necessarily the next version. Conventional Commits determine
the next bump. A never-released app can explicitly make its first release
`1.0.0` later with `Release-As-ios: 1.0.0`.

## 3. Initialize from the Flutter app

Start from the configured target branch—`main` by default—and a clean,
up-to-date worktree, then create a non-release setup branch:

```bash
git status --short
git switch main
git pull --ff-only
git switch -c chore/configure-smf
```

Replace `main` when the repository releases from another branch. If
`git status --short` shows intentional work, commit it on the correct branch or
stash it before continuing. The setup branch works with protected target
branches and keeps configuration review separate from release-worthy work.

Ensure dependencies resolve, then make the lockfile visible for review:

```bash
flutter pub get
git add --intent-to-add pubspec.lock
git diff -- pubspec.lock
```

Use `fvm flutter pub get` when the repository uses FVM. In a Dart workspace,
use the workspace-root `pubspec.lock` path instead. An already committed,
unchanged lockfile produces no diff. If the diff changes dependency
resolution, confirm that change is intentional before continuing; otherwise
reconcile it with the project's normal dependency workflow.

After approval, stage and review the exact lockfile content:

```bash
git add pubspec.lock
git diff --cached -- pubspec.lock
```

For reproducible candidate builds, commit the Flutter version used by the app
in `.fvmrc`. Without FVM, the generated workflow installs the current stable
Flutter SDK. Before initialization, verify that the project's selected SDK can
build the iOS project on macOS:

```bash
flutter pub get
flutter build ios --release --no-codesign
```

Use the matching `fvm flutter` commands when the repository uses FVM.

Now run SMF from the directory containing the Flutter app's `pubspec.yaml` and
`ios/` directory:

```bash
smf init \
  --current-version 0.0.0 \
  --bundle-id com.example.myapp
```

Replace:

- `0.0.0` with the current version chosen above; and
- `com.example.myapp` with the production bundle ID shown in Xcode under
  **Runner → Signing & Capabilities → Bundle Identifier**.

In a monorepo, change into the nested Flutter app first:

```bash
cd apps/mobile
smf init \
  --current-version 0.0.0 \
  --bundle-id com.example.myapp
```

SMF creates:

```text
<flutter-app>/smf/config.yaml
<repository>/.github/workflows/smf.yml
```

It does not create or store credentials.

## 4. Keep the first-run safety settings

Open `<flutter-app>/smf/config.yaml` and confirm:

```yaml
platforms:
  ios:
    enabled: true
    bundle_id: com.example.myapp
    testflight:
      groups: []
      wait_timeout_minutes: 45
    app_store:
      mode: upload
```

For the first run:

- keep `app_store.mode: upload`; and
- keep `groups: []`, or later add only the internal TestFlight group created by
  the Apple setup guide.

`upload` cannot publish the app. It uploads and records the exact build without
submitting App Review.

## 5. Complete Apple setup

Follow [Set up Apple delivery](apple-bootstrap.md). It covers:

- finding every app and extension bundle ID in Xcode;
- the required Apple roles;
- App IDs and the App Store Connect app record;
- export compliance;
- the App Store Connect API key;
- the Apple Distribution `.p12`;
- one provisioning profile per signed target;
- an optional internal TestFlight group; and
- the six GitHub Actions secrets.

For the complete acceptance run in this guide, create an internal TestFlight
group and add its exact name to `testflight.groups`. Leaving `groups: []` is
valid for an upload-only infrastructure check, but no tester can install the
build until a person assigns it to a group.

Apple setup ends by returning here. Continue only after all six secret names
appear under **GitHub repository → Settings → Secrets and variables →
Actions**.

## 6. Allow the workflow to open release PRs

In the GitHub repository:

1. Open **Settings → Actions → General**.
2. Find **Workflow permissions**.
3. Enable **Allow GitHub Actions to create and approve pull requests**.
4. Save.

If organization policy locks the option, ask an organization owner to enable
it. Repositories that cannot use the default `GITHUB_TOKEN` can use the
alternate GitHub App or fine-grained token described in the [security
guide](security.md#github-permissions).

## 7. Validate and commit the setup

From the Flutter app directory:

```bash
smf validate
```

Success prints one JSON value. Fix every reported error before continuing.

Return to the Git root and inspect the generated files:

```bash
cd "$(git rev-parse --show-toplevel)"
git status --short
git add --intent-to-add smf/config.yaml .github/workflows/smf.yml
git diff -- smf/config.yaml .github/workflows/smf.yml
```

For a nested app, replace `smf/config.yaml` with its path from the Git root,
such as `apps/mobile/smf/config.yaml`, in both `git add --intent-to-add` and
`git diff`. Intent-to-add makes a new file's contents visible in the diff; it
does not stage those contents.

Confirm that no `.p8`, `.p12`, `.mobileprovision`, password, or other secret is
present. Then commit and push the setup branch:

```bash
git add smf/config.yaml .github/workflows/smf.yml
git commit -m "chore: configure smf"
git push -u origin chore/configure-smf
```

Use the nested config path in `git add` when applicable. Commit this setup
before new release-worthy work so older repository history is not included in
the first release plan.

Open a pull request into the configured target branch with the non-release
title `chore: configure smf`, complete the repository's normal review and
checks, and merge it. Then update the local target branch:

```bash
git switch main
git pull --ff-only
```

Replace `main` when necessary. Do not place a `fix`, `feat`, breaking-change,
or `Release-As-ios` marker in the setup PR title or commit.

## 8. Trigger the first release PR

After setup is on the target branch, push a genuine release-worthy
Conventional Commit. Examples:

```text
fix(ios): correct sign-in callback
feat(ios): add offline mode
```

For a never-released app whose first version should be `1.0.0`:

```text
feat(ios): prepare first release

Release-As-ios: 1.0.0
```

The GitHub workflow should:

1. open or update the iOS release PR;
2. build and upload its exact candidate on macOS;
3. wait for App Store Connect processing;
4. optionally assign the configured internal TestFlight group; and
5. commit the candidate receipt at
   `<flutter-app>/smf/candidates/ios-<version>.json` to the release PR.

Do not merge yet. Follow [Release operations and
recovery](operations.md#before-merging) to verify and test the exact candidate.

## Setup success checklist

Setup is complete when:

- `smf validate` succeeds;
- `<flutter-app>/smf/config.yaml`, the applicable `pubspec.lock`, and
  `.github/workflows/smf.yml` are committed;
- all six GitHub secret names exist;
- the release PR opens;
- its candidate job succeeds;
- the matching build is valid in TestFlight; and
- the configured internal group can install it; and
- an authorized tester has approved that exact build.

## Upgrading SMF later

After installing a newer CLI, refresh only the generated workflow:

```bash
smf init --workflow-only
```

Review and commit the workflow diff before the next release. This preserves
configuration, manifests, changelogs, store notes, and candidate receipts.

Never use `smf init --force` as a routine upgrade command; it replaces the
generated configuration and workflow.
