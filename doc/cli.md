# CLI guide

The SMF command is named `smf`. It can run the complete release lifecycle
locally. The generated GitHub Actions workflow is an optional automated wrapper
around the same release operations.

For the complete setup process, follow
[Getting started](getting-started.md).

## Install

```bash
dart install smf_cli
smf --help
```

Every command has its own help:

```bash
smf init --help
smf validate --help
```

Use `smf <command> --help` whenever you need the complete, current list of
options.

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

A successful result means the local SMF files are consistent. It does not
check GitHub secrets, store access, or signing credentials.

## Select an app in a monorepo

When the repository contains several initialized apps, select one by its
`smf/` directory:

```bash
smf validate --smf-path apps/customer/smf
```

Run this command from the repository root.

`--app-path` and `--smf-path` have different jobs:

- `--app-path` points `smf init` to a Flutter app that is not at the repository
  root.
- `--smf-path` selects an app that is already initialized.

## Update after installing a newer SMF version

```bash
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

The complete manual lifecycle uses two commands:

Use this mode when the generated workflow is absent or disabled. Do not run
manual candidate creation while the automated wrapper is also active; both
would react to the same release branch and could upload concurrently.

| Command              | Purpose                                                   |
| -------------------- | --------------------------------------------------------- |
| `smf create-release` | Create/update the release PR and create its candidates    |
| `smf ship`           | Ship the created release to its configured store targets |

`smf create-release` detects `owner/name` from `GITHUB_REPOSITORY` or the
current Git repository's `origin` remote. Use `--repository owner/name` only to
override that detected repository. The command stops with an explanation when
it cannot detect one. SMF derives the affected platforms from the release
changes, creates or updates the release PR, checks out its release branch,
builds, signs, uploads, and records every candidate, then restores your
starting branch.

`smf ship` must run after that release PR has been reviewed, tested, and merged.
It fetches the repository into an isolated temporary checkout, reads the
committed configuration and release state from the configured remote target
branch, checks remote release tags, and delivers each exact tested candidate to
its configured target. Your current branch, uncommitted files, and local tags
do not affect what ships. You do not select iOS or Android manually.

The manual sequence is:

```bash
git switch main
git pull --ff-only origin main
smf create-release --github-token-file "/secure/github-token"
```

Install and test every candidate from its configured TestFlight or Google Play
testing destination. Review and merge the release PR. Then ship from anywhere
inside the same Git repository:

```bash
smf ship --github-token-file "/secure/github-token"
```

`create-release` requires a clean checkout. `ship` does not read or modify the
caller checkout; it deletes its temporary remote checkout when the command
finishes. An iOS candidate requires macOS and the local Flutter/iOS toolchain.
Android candidates can run on a supported Android build machine. On a macOS
machine configured for both, the default command creates both candidates
sequentially.

For split machines or a targeted retry, use `--platform ios` or
`--platform android`. `create-release --prepare-only` prepares the PR without
building candidates so separate runners can create them afterward. These are
also useful when building a custom automation wrapper.

Read [How releases work](how-it-works.md) and
[Release operations and recovery](operations.md) before a live release.

## Supply environment variables manually

Export the store and signing variables described in the platform setup guides
before running a release command. `create-release` needs store API credentials
and signing credentials for every selected candidate. `ship` needs the store
API credentials but does not need signing credentials because it never
rebuilds.

On macOS or Linux, place variables immediately before the command to make them
available only to that command:

```bash
SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH="/secure/service-account.json" \
smf ship --platform android --github-token-file "/secure/github-token"
```

For several commands in the same terminal session, export the variable once:

```bash
export SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH="/secure/service-account.json"
export SMF_ANDROID_KEYSTORE_PATH="/secure/upload-keystore.jks"
export SMF_ANDROID_KEY_ALIAS="upload"

read -r -s SMF_ANDROID_KEYSTORE_PASSWORD
export SMF_ANDROID_KEYSTORE_PASSWORD
echo

read -r -s SMF_ANDROID_KEY_PASSWORD
export SMF_ANDROID_KEY_PASSWORD
echo

smf create-release --github-token-file "/secure/github-token"

unset SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH \
  SMF_ANDROID_KEYSTORE_PATH \
  SMF_ANDROID_KEY_ALIAS \
  SMF_ANDROID_KEYSTORE_PASSWORD \
  SMF_ANDROID_KEY_PASSWORD
```

In Windows PowerShell:

```powershell
$env:SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH = "C:\secure\service-account.json"
$env:SMF_ANDROID_KEYSTORE_PATH = "C:\secure\upload-keystore.jks"
$env:SMF_ANDROID_KEY_ALIAS = "upload"
$env:SMF_ANDROID_KEYSTORE_PASSWORD = Read-Host "Keystore password" -MaskInput
$env:SMF_ANDROID_KEY_PASSWORD = Read-Host "Key password" -MaskInput

smf create-release --github-token-file "C:\secure\github-token"

Remove-Item Env:SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH,Env:SMF_ANDROID_KEYSTORE_PATH,Env:SMF_ANDROID_KEY_ALIAS,Env:SMF_ANDROID_KEYSTORE_PASSWORD,Env:SMF_ANDROID_KEY_PASSWORD
```

Prefer a documented `_PATH` variable for secret files. It points SMF to the
protected file without placing the file's contents in shell history. For
example:

```text
SMF_APP_STORE_CONNECT_AUTH_KEY_PATH
SMF_IOS_CERTIFICATE_PATH
SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH
SMF_ANDROID_KEYSTORE_PATH
```

Run release commands only from the branch and repository state described in
[Release operations and recovery](operations.md). The platform setup guides
list the complete set of variables required by Apple and Android.

Do not:

- pass a secret as a command option;
- paste a secret directly into a command that shell history may save;
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
