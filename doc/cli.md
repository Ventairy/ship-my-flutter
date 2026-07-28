# CLI guide

The SMF command is named `smf`. Most users use it to set up SMF and check their
work. The generated GitHub Actions workflow handles releases.

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

With no extra option, `smf migrate` updates every SMF-owned file that needs the
new format. It does not build, upload, or publish the app.

In a monorepo:

```bash
smf migrate --smf-path apps/mobile/smf
```

Use `smf migrate --help` when you need to update only the configuration,
workflow, or SMF release records.

## Commands normally run by GitHub Actions

The generated workflow normally runs these commands for you:

| Command         | Purpose                                           |
| --------------- | ------------------------------------------------- |
| `smf open-pr`   | Open or update the app's release pull request     |
| `smf candidate` | Build and upload a platform candidate for testing |
| `smf promote`   | Verify or ship the tested candidate after merge   |

The CLI also provides platform-specific names such as `smf testflight`,
`smf internal-testing`, `smf app-store`, and `smf google-play`.

Only run these commands manually when building custom automation. Use the
command's `--help`, then read [How releases work](how-it-works.md) and
[Release operations and recovery](operations.md) first.

## Supply environment variables manually

The generated GitHub Actions workflow supplies the required environment
variables automatically. Follow this section only when running release commands
yourself or building custom automation.

On macOS or Linux, place variables immediately before the command to make them
available only to that command:

```bash
SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH="/secure/service-account.json" \
smf google-play --github-token-file "/secure/github-token"
```

For several commands in the same terminal session, export the variable once:

```bash
export SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH="/secure/service-account.json"

smf google-play --github-token-file "/secure/github-token"

unset SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH
```

In Windows PowerShell:

```powershell
$env:SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH = "C:\secure\service-account.json"

smf google-play --github-token-file "C:\secure\github-token"

Remove-Item Env:SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH
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

Some values, such as signing passwords, do not have a file-path alternative.
Enter those without showing or saving the value in shell history.

For example, a manual Android candidate can receive all five Android values
like this:

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

smf candidate \
  --platform android \
  --github-token-file "/secure/github-token"

unset SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH \
  SMF_ANDROID_KEYSTORE_PATH \
  SMF_ANDROID_KEY_ALIAS \
  SMF_ANDROID_KEYSTORE_PASSWORD \
  SMF_ANDROID_KEY_PASSWORD
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
