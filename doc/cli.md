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

The command checks the latest `smf_cli` version published on pub.dev and
replaces the installed executable. Review that version's release notes before
using it in an existing repository.

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
- Add `--platform ios` or `--platform android` to initialize only one platform;
  omit it to configure every detected platform directory.
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

## Run a release from the CLI

Use this mode when the generated workflow is absent or disabled. Do not run
manual release candidate creation while the automated wrapper is also active; both
would react to the same release branch and could upload concurrently.

Every release operation uses `--phase`:

| Phase               | Purpose                                                        |
| ------------------- | -------------------------------------------------------------- |
| `pull-request`      | Create or update the release PR and report planned platforms   |
| `release-candidate` | Build, upload, verify, and record the planned store release candidates |
| `ship`              | Ship the exact tested release candidates after the release PR merges   |

The `pull-request` phase detects `owner/name` from the current Git repository's
`origin` remote. Set `SMF_GITHUB_REPOSITORY` or use `--repository owner/name`
only to override that detected repository. It derives the affected platforms
from the release changes and returns the release branch in its JSON result.
The result's `nextPhase` field reports the next work to run
(`release-candidate` or `ship`), or `noop`; it does not merely echo
`pull-request`.

The manual sequence is:

```bash
smf release --phase pull-request
smf release --phase release-candidate
```

For one app in a monorepo, keep its selector on every phase:

```bash
smf release --phase pull-request --smf-path apps/customer/smf
smf release --phase release-candidate --smf-path apps/customer/smf
```

Install and test every release candidate from its configured TestFlight or Google Play
testing destination. Review and merge the release PR. Then ship from anywhere
inside the same Git repository:

```bash
smf release --phase ship
```

For that monorepo app:

```bash
smf release --phase ship --smf-path apps/customer/smf
```

The `pull-request` and `ship` phases fetch the configured remote target branch
into an isolated temporary checkout. The `release-candidate` phase does the
same with the remote release branch. Every phase deletes its checkout when
finished and does not depend on or switch your local branch. Local uncommitted
files and unpushed commits do not participate. An iOS release candidate requires macOS
and the local Flutter/iOS toolchain. Android release candidates can run on a supported
Android build machine.

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

First export the GitHub token. On macOS or Linux:

```bash
export SMF_GITHUB_TOKEN="<token>"
```

In Windows PowerShell:

```powershell
$env:SMF_GITHUB_TOKEN = "<token>"
```

Then follow the platform guide for the remaining values:

- [Export the five Apple CLI variables](apple-bootstrap.md#cli-environment-variables)
  for iOS;
- [export the five Android CLI variables](android-bootstrap.md#cli-environment-variables)
  for Android.

For a two-platform run without `--platform`, export both sets.

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

Run release commands from anywhere inside the repository. The configured
remote target and release branches are authoritative; local branches,
uncommitted files, and unpushed commits do not participate. See
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

- [Apple credential variables](apple-bootstrap.md#8-provide-the-five-apple-credential-variables)
  for App Store Connect and iOS signing;
- [Android credential variables](android-bootstrap.md#8-provide-the-five-android-credential-variables)
  for Google Play and Android signing; and
- [Security](security.md) before using credentials in custom automation.

If a command fails, it prints an explanation and a short error name in
brackets, such as `[INVALID_CONFIG]`. Use that name when searching the
documentation or reporting the problem.
