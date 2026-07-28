# CLI guide

The SMF command is named `smf`. It can run the complete release lifecycle
locally. The generated GitHub Actions workflow is an optional automated wrapper
around the same release operations.

For the complete human-operated setup process, follow
[CLI setup](cli-setup.md). For the recommended automated workflow, follow
[GitHub Actions setup](github-actions-setup.md).

## Install

```bash
dart install smf_cli
smf --help
```

Every command has its own help:

```bash
smf init --help
smf validate --help
smf upgrade --help
```

Use `smf <command> --help` whenever you need the complete, current list of
options.

## Keep the CLI current

SMF checks pub.dev when an interactive CLI command finishes. When a newer
version is published, it writes an informational notice to the terminal without
changing the command's result:

```text
SMF 1.2.0 is available; this installation is 1.1.0. Run `smf upgrade` to update.
```

Upgrade the globally installed CLI with:

```bash
smf upgrade
```

The command checks the latest `smf_cli` version published on pub.dev.
It does not migrate files inside your Flutter repository.
Run `smf migrate` separately when the newer version
changes generated files or persisted SMF formats.

Automatic checks are skipped in CI and in SMF's GitHub Action.
A failed advisory check is silent and never changes the requested command's exit code.
To disable the advisory check elsewhere, set `SMF_NO_UPDATE_CHECK=true`; `smf upgrade` still checks when explicitly run.

## Set up an app

Run `smf init` once for each Flutter app.

For an app at the repository root:

```bash
smf init \
  --version 1.0.0 \
  --ios-bundle-id com.acme.app \
  --android-package-name com.acme.app
```

For a nested app:

```bash
smf init \
  --app-path apps/mobile \
  --app-id mobile \
  --version 1.0.0 \
  --ios-bundle-id com.acme.app \
  --android-package-name com.acme.app
```

- `--version` is the latest version already released, not the next version.
- Use `--ios-version` and `--android-version` when the platforms have different
  released versions.
- Omit the iOS or Android identifier when the app does not support that
  platform.
- Choose an explicit, permanent `--app-id` for every app in a monorepo.
- You can omit version options and let SMF detect the current versions.

Initialization creates:

```text
<flutter-app>/smf/config.yaml
.github/workflows/smf-<app-id>.yml
```

Review both files before committing them.

For a CLI-only setup, omit the workflow:

```bash
smf init \
  --version 1.0.0 \
  --ios-bundle-id com.acme.app \
  --android-package-name com.acme.app \
  --no-github-actions
```

This creates `smf/config.yaml` without `.github/workflows/`. You can add the
generated wrapper later with `smf init --github-actions`.

If the configuration still exists but the generated workflow was deleted:

```bash
smf init --github-actions
```

For a nested app:

```bash
smf init --app-path apps/mobile --github-actions
```

## Check the setup

```bash
smf validate
```

A successful result lists every discovered `smf/` directory and means all of
their local SMF files are consistent. It does not check GitHub secrets, store
access, or signing credentials.

## Validate one app in a monorepo

By default, `smf validate` discovers and validates every initialized app in the
repository. To validate only one app, pass its repository-relative `smf/`
directory:

```bash
smf validate --smf-path apps/customer/smf
```

You can run the command from anywhere inside the repository.

`--app-path` and `--smf-path` have different jobs:

- `--app-path` points `smf init` to a Flutter app that is not at the repository
  root.
- `--smf-path` limits validation to one app that is already initialized.

## Update repository files after upgrading SMF

```bash
smf upgrade
smf migrate
smf validate
```

With no extra option, `smf migrate` updates the configuration and release
records, plus the generated workflow when that workflow already exists. It
does not add a workflow to a CLI-only repository, build, upload, or publish the
app.

In a monorepo:

```bash
smf migrate --smf-path apps/mobile/smf
```

Use `smf migrate --help` when you need to update only the configuration,
workflow, or SMF release records.

## Run a release from the CLI

Use this mode when the generated workflow is absent or disabled. Do not run
manual candidate creation while the automated wrapper is also active; both
would react to the same release branch and could upload concurrently.

Every release operation uses `--phase`:

| Phase               | Purpose                                                        |
| ------------------- | -------------------------------------------------------------- |
| `pull-request`      | Create or update the release PR and report planned platforms   |
| `release-candidate` | Build, upload, verify, and record the planned store candidates |
| `ship`              | Ship the exact tested candidates after the release PR merges   |

The `pull-request` phase detects `owner/name` from the current Git repository's
`origin` remote. Set `SMF_GITHUB_REPOSITORY` or use `--repository owner/name`
only to override that detected repository. It derives the affected platforms
from the release changes and returns the release branch in its JSON result.

The manual sequence is:

```bash
git switch main
git pull --ff-only origin main
smf release --phase pull-request
git fetch origin
git switch smf/<app-id>/release
smf release --phase release-candidate
```

Install and test every candidate from its configured TestFlight or Google Play
testing destination. Review and merge the release PR. Then ship from anywhere
inside the same Git repository:

```bash
smf release --phase ship
```

The `pull-request` phase requires a clean checkout. The `release-candidate`
phase must run from the reported release branch. The `ship` phase fetches the
repository into an isolated temporary checkout, treats the configured remote
target branch as its source of truth, and deletes the checkout when it
finishes. An iOS candidate requires macOS and the local Flutter/iOS toolchain.
Android candidates can run on a supported Android build machine.

Omit `--platform` to process every eligible platform. Add `--platform ios` or
`--platform android` to any phase to plan, create, ship, or retry only that
platform. The generated GitHub workflow uses the same commands and supplies
`--platform` to its runner-specific matrix jobs.

Read [How releases work](how-it-works.md) and
[Release operations and recovery](operations.md) before a live release.

## Supply credentials

Export the store and signing variables described in the platform setup guides
before `--phase release-candidate`. The `ship` phase needs store API
credentials but does not need signing credentials because it never rebuilds.

Every public SMF environment variable starts with `SMF_`. Generic provider
names such as `GITHUB_TOKEN` and `GITHUB_REPOSITORY` are not aliases and are
ignored by the CLI.

For production and shared machines, use environment variables. Process
arguments may be visible to other local processes, shell history, job
diagnostics, or monitoring tools.

On macOS or Linux, export the credentials for the release:

```bash
export SMF_GITHUB_TOKEN="<token>"
export SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON="$(<"/secure/service-account.json")"
export SMF_ANDROID_KEYSTORE_BASE64="$(base64 <"/secure/upload-keystore.jks" | tr -d '\n')"
export SMF_ANDROID_KEY_ALIAS="upload"
export SMF_ANDROID_KEYSTORE_PASSWORD="<keystore-password>"
export SMF_ANDROID_KEY_PASSWORD="<key-password>"

smf release --phase release-candidate
```

In Windows PowerShell:

```powershell
$env:SMF_GITHUB_TOKEN = "<token>"
$env:SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON = Get-Content "C:\secure\service-account.json" -Raw
$env:SMF_ANDROID_KEYSTORE_BASE64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\secure\upload-keystore.jks"))
$env:SMF_ANDROID_KEY_ALIAS = "upload"
$env:SMF_ANDROID_KEYSTORE_PASSWORD = "<keystore-password>"
$env:SMF_ANDROID_KEY_PASSWORD = "<key-password>"

smf release --phase release-candidate
```

For a quick local run, every credential also has a direct option:

```bash
smf release --phase ship \
  --platform android \
  --github-token "<token>" \
  --google-play-service-account-json '<complete JSON>'
```

Use `smf release --phase pull-request --help` for the complete option list. SMF rejects
an option when its matching `SMF_*` variable is also set. SMF does not accept
credential-file options or credential `_PATH` variables.

Run release commands only from the branch and repository state described in
[Release operations and recovery](operations.md). The platform setup guides
list the complete set of variables required by Apple and Android.

Do not:

- use direct credential options in production automation;
- paste direct credential options into shell history on shared machines;
- commit secrets in a `.env` file; or
- add release secrets permanently to a shell startup file.

SMF does not automatically load `.env` files.

## Find the required variables

Follow:

- [Apple setup](apple-bootstrap.md) for App Store Connect and iOS signing;
- [Android setup](android-bootstrap.md) for Google Play and Android signing; and
- [Security](security.md) before using credentials in custom automation.

If a command fails, it prints an explanation and a short error name in
brackets, such as `[INVALID_CONFIG]`. Use that name when searching the
documentation or reporting the problem.
