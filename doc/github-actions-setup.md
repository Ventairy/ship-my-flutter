# GitHub Actions setup

This is the recommended setup path. The generated GitHub Actions workflow
prepares release pull requests, uploads exact candidates for testing, and
delivers approved releases after the release PR is merged.

For a human-operated or custom-automation workflow instead, choose
[CLI setup](cli-setup.md). Return to [Get started](../README.md#get-started) to
compare the two paths.

The safe first run uploads candidates only:

- iOS goes to TestFlight without App Review submission.
- Android goes to the configured testing track without changing production.
- Merging still creates the app's version tags and GitHub Releases, even while
  `ship` is omitted and neither store artifact moves toward production.

## 1. Confirm the repository is ready

You need:

- a Git repository hosted on GitHub;
- at least one Flutter app with `ios/`, `android/`, or both;
- a stable target branch such as `main`;
- a local build that succeeds for every enabled platform; and
- permission to add workflows, GitHub Environments and their secrets, and
  repository settings.

SMF supports multiple independently released Flutter apps in one Git
repository. Each app is initialized separately and receives independent
release resources.

You can run `init` and `validate` in a local Git repository before it has a
GitHub remote. GitHub hosting is required when you start the automated release
lifecycle.

## 2. Install the CLI

```bash
dart install smf_cli
smf --help
```

The Flutter app does not add `smf_cli` or another SMF package to
`dev_dependencies`.

After installation, SMF prints an informational notice when a newer CLI is
available. Run `smf upgrade` to install it, followed by `smf migrate` for each
initialized app when the release notes for that SMF version require generated
or persisted files to change.

## 3. Initialize from the Flutter app

The initializer needs each platform's current version. This is the latest
version already shipped for the platform, not the version you want SMF to
create next:

- existing iOS app: use the latest App Store marketing version;
- existing Android app: use the latest Google Play marketing version; and
- new app or newly enabled platform: normally use `0.0.0`.

The examples below assume the current version is `1.0.0`. Replace it with your
app's real current version.

Before running `smf init`, write down these different identities:

| Identity             | Example             | What it controls                                                            |
| -------------------- | ------------------- | --------------------------------------------------------------------------- |
| Flutter package name | `customer_app`      | Dart package name in `pubspec.yaml`; the default `app_id`                   |
| SMF `app_id`         | `customer`          | Permanent release branches, tags, workflow filename, and GitHub Environment |
| Display name         | `Customer`          | Name shown to people; SMF does not use it as identity                       |
| iOS bundle ID        | `com.acme.customer` | Permanent App Store identity                                                |
| Android package name | `com.acme.customer` | Permanent Google Play identity                                              |

Do not register or release a placeholder such as `com.example.*`. Choose the
production bundle ID and package name with the app owner first. The iOS and
Android values may differ.

### Standard repository

Use this path when the Git repository contains one Flutter app at the repository
root.

For a two-platform app, run from the Flutter app directory:

```bash
smf init --version 1.0.0 --ios-bundle-id com.acme.myapp --android-package-name com.acme.myapp
```

For an Android-only app:

```bash
smf init --version 1.0.0 --android-package-name com.acme.myapp
```

For iOS only, omit `--android-package-name`. SMF detects the platform
directories that actually exist and generates configuration only for those
platforms.

This creates:

```text
smf/config.yaml
.github/workflows/smf-<app-id>.yml
```

The initializer reads the Flutter package name from `pubspec.yaml`, stores it
as `app_id`, and uses it in the workflow filename. Pass an explicit `--app-id`
if the package name is generic or is not the permanent release identity you
want.

If iOS and Android currently have different versions, replace `--version` with
one or both platform-specific options:

```bash
smf init --ios-version 2.4.0 --android-version 2.3.1 --ios-bundle-id com.acme.myapp --android-package-name com.acme.myapp
```

If you omit the version options, SMF detects each platform version from the app.

If the generated workflow was removed but `smf/config.yaml` still exists,
recreate only the workflow:

```bash
smf init --github-actions
```

This does not change `smf/config.yaml` or release state. Always review the
generated workflow before committing it.

### Monorepo

Use this path when the Git repository contains a Flutter app in a nested
directory, such as `apps/mobile`.

Run from the repository root and point to the Flutter app:

```bash
smf init --app-path apps/mobile --app-id mobile --version 1.0.0 --ios-bundle-id com.acme.myapp --android-package-name com.acme.myapp
```

This creates:

```text
apps/mobile/smf/config.yaml
.github/workflows/smf-<app-id>.yml
```

For iOS only, omit `--android-package-name`. For Android only, omit
`--ios-bundle-id`.

If iOS and Android currently have different versions, replace `--version` with
one or both platform-specific options:

```bash
smf init --app-path apps/mobile --app-id mobile --ios-version 2.4.0 --android-version 2.3.1 --ios-bundle-id com.acme.myapp --android-package-name com.acme.myapp
```

If you omit the version options, SMF detects each platform version from the
nested app.

Initialize every app independently:

```bash
smf init --app-path apps/customer --app-id customer --version 1.0.0 --ios-bundle-id com.acme.customer --android-package-name com.acme.customer
smf init --app-path apps/driver --app-id driver --version 1.0.0 --ios-bundle-id com.acme.driver --android-package-name com.acme.driver
```

Choose an explicit, repository-unique `app_id` for every monorepo app. Flutter
apps often share generic package names such as `mobile`; relying on that
default can give the first app an unintended permanent identity and make the
next app collide. Replace every example version and store identifier with the
corresponding app's real values.

Each nested app automatically observes commits that change its own directory.
If shared code should also trigger the app, add it to `release_trigger_paths`
in that app's `smf/config.yaml`:

```yaml
release_trigger_paths:
  - packages/shared_models/**
```

If an app's generated workflow was removed but its `smf/config.yaml` still
exists, recreate only that app's workflow:

```bash
smf init --app-path apps/mobile --github-actions
```

This does not change `smf/config.yaml` or release state. Always review the
generated workflow before committing it.

### Version detection and app identity

Never combine `--version` with `--ios-version`, `--android-version`, or a
future platform-specific version option.

When a platform has no supplied version, SMF checks:

1. iOS: literal `MARKETING_VERSION` values, then a literal
   `CFBundleShortVersionString`;
2. Android: a literal Gradle `versionName`, then
   `android/local.properties` → `flutter.versionName`;
3. the stable version in the Flutter app's `pubspec.yaml`; and
4. `0.0.0` when none of those files provides a stable version.

If an iOS or Android project contains conflicting literal versions, pass the
matching platform-specific option explicitly.

SMF reads the Flutter package name from `pubspec.yaml`, stores it as `app_id`,
and uses it in the workflow filename. For a standard repository, override it
when the package name is unsuitable. For a monorepo, choose it explicitly:

```bash
smf init --app-id customer
smf init --app-path apps/customer --app-id customer
```

The `app_id` is a permanent release identity. Moving the app directory does
not change it. It produces these app-scoped names:

```text
.github/workflows/smf-<app-id>.yml
smf-<app-id>
smf/<app-id>/release
<app-id>/ios-vX.Y.Z
<app-id>/android-vX.Y.Z
```

If you notice a wrong `app_id` immediately after initialization, before
committing or running any workflow, remove only the newly generated app
`smf/` directory and its `.github/workflows/smf-<wrong-app-id>.yml`, then
initialize again. Never use that reset after release history exists; migrate
released identity deliberately instead.

## 4. Review the generated configuration

Open `<flutter-app>/smf/config.yaml`.

Confirm `app_id` uniquely and permanently identifies this app. Confirm every
`release_trigger_paths` entry names shared code whose qualifying commits should
release this app. Do not list the app directory; SMF includes it automatically.

The generated `initial_version` is the release baseline copied from `--version`
or the matching platform-specific version option. It tells SMF where existing
release history ends. It does not select the next version.

When iOS and Android have different versions, confirm each `initial_version`
matches the corresponding platform-specific option before committing.

If the app uses a Flutter flavor, set the one global `flavor`. See
[Configuration](configuration.md) before adding custom build commands.

Validate every initialized app in the repository:

```bash
smf validate
```

To validate only one initialized app, select its repository-relative `smf/`
directory:

```bash
smf validate --smf-path apps/customer/smf
```

The default command discovers every `smf/config.yaml` in the repository and
fails if any app is invalid. It checks configuration, repository layout, paths,
and Git-controlled release files. It does not read GitHub Environment secrets,
contact either store, prove signing credentials, or confirm that configured
identifiers match store records. Those checks happen in the credentialed
candidate workflow.

At this point, local preparation is complete when the app builds normally,
and `smf validate` succeeds. Store and GitHub readiness are separate
milestones in the next sections. SMF calculates release versions automatically
after qualifying commits reach the target branch.

## 5. Complete each enabled store setup

For iOS, follow [Set up Apple delivery](apple-bootstrap.md). It creates/verifies
the App IDs, App Store Connect app, API key, distribution certificate, optional
internal TestFlight group, and five secrets in the app's `smf-<app-id>` GitHub
Environment.

For Android, follow
[Set up Android and Google Play delivery](android-bootstrap.md). It
creates/verifies the Play app, Play App Signing, upload key, internal tester
list, service account, permissions, and five secrets in the app's
`smf-<app-id>` GitHub Environment.

Return here only after each enabled platform’s final checklist passes.

## 6. Allow Actions to create the release PR

In the Flutter repository:

1. Open **Settings → Actions → General**.
2. Find **Workflow permissions**.
3. Enable **Allow GitHub Actions to create and approve pull requests**.
4. Save.

Organization policy can lock this setting. Ask an organization owner if it is
disabled.

The default `GITHUB_TOKEN` can run SMF and create the release PR. However, PRs
created or updated by that token do not always start the repository's other
`pull_request` workflows. For example, if your normal PRs run
`.github/workflows/ci.yml` with jobs such as `flutter analyze`, `flutter test`,
coverage, danger, or label checks, those separate PR checks may not run
automatically on the SMF-generated release PR.

That is fine when the SMF workflow is the only required release check. If the
generated release PR must behave like a normal human-authored PR and trigger the
same required `pull_request` checks before merge, configure SMF with a different
GitHub identity: a GitHub App installation token is preferred, or use a narrowly
scoped fine-grained token as explained in
[GitHub permissions](security.md#github-permissions).

## 7. Add an optional preparation hook

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

Follow [Typed hooks](hooks.md). Hooks execute trusted repository code in a
credential-aware release workflow.

## 8. Push a change that should be released

SMF opens the release PR after a release-worthy commit reaches the configured
target branch. A release-worthy commit is a real app change with a Conventional
Commit message that should create a new version, such as `fix:` or `feat:`.

Do not create an empty or fake release commit. Use the real change that you want
to ship. For example:

```text
fix: prevent startup crash
fix(ios): repair camera permission
fix(android): repair back navigation
feat(auth): add passkeys
```

Get that commit onto the configured target branch, such as `main`. You can push
directly if that is how the repository works, or merge a normal PR that
contains the commit. After the commit lands on the target branch, the SMF
workflow opens or updates the release PR.

Every app-scoped workflow starts on repository pushes. SMF then checks the
configured target branch and whether commits affect that app directory or one
of its `release_trigger_paths`. An unaffected sibling app returns `noop`; it
does not create a release merely because its workflow started.

SMF always starts from the platform's configured `initial_version` and applies
the Conventional Commit bump: `fix` produces a patch, `feat` produces a minor,
and a breaking change (feat!) produces a major. A commit message cannot replace the
configured baseline or select an arbitrary next version.

## 9. Review the app release PR

The workflow opens or updates branch `smf/<app-id>/release`.

The PR can contain iOS, Android, or both. Verify:

- each planned platform and version is expected;
- the changelog matches the qualifying commits;
- only intended platforms are included; and
- the `release-candidate (<platform>)` jobs succeed.

Do not merge yet.

## 10. Test every exact candidate

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
- verify the candidate receipt is committed under `smf/candidates/`; and
- obtain release-owner approval.

The receipt is machine-owned. Never edit it.

## 11. Merge safely

Keep `ship` omitted for both platforms on the first merge. After that
candidate-only cycle succeeds, read
[Apple targets](configuration.md#apple-targets) and
[Google Play targets](configuration.md#google-play-targets), then choose a
ship destination independently for iOS and Android.

When the complete candidate-only path is proven, use
[End-to-end release automation](end-to-end-automation.md) to configure the
approved merge-to-production behavior and
[Store release notes](store-release-notes.md) to add localized customer notes.

Changing release-candidate or ship settings updates the release PR. Recheck
the candidate before merging.

## 12. Confirm completion

After merge, watch the `ship (<platform>)` jobs.

Expected tags:

```text
<app-id>/ios-vX.Y.Z
<app-id>/android-vX.Y.Z
```

Then confirm the exact recorded artifacts have the intended store status. A
green GitHub job does not replace checking App Store Connect or Play Console.

For failures, keep the release branch and receipt intact and use
[Release operations and recovery](operations.md).
