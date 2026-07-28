<div align="center">

# SMF

**Release Flutter apps through one reviewable pull request.**

[![CI](https://github.com/Ventairy/smf/actions/workflows/ci.yml/badge.svg)](https://github.com/Ventairy/smf/actions/workflows/ci.yml)
[![Dart 3.10+](https://img.shields.io/badge/Dart-3.10%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![Status: pre-release](https://img.shields.io/badge/Status-pre--release-orange.svg)](#project-status)

[Why SMF](#why-smf) · [How it works](#how-it-works) ·
[Get started](#get-started) · [User guide](#user-guide)

</div>

SMF turns normal Conventional Commits into independently versioned iOS and
Android releases. It prepares a release PR, uploads signed candidates to
TestFlight and Google Play for testing, and records exactly what was tested.
After approval, merging the PR verifies or promotes those same store artifacts,
according to your settings, without rebuilding them.

> [!IMPORTANT]
> SMF is currently under pre-release validation. The Dart packages and
> `Ventairy/smf-action@v1` are not published yet, so the installation commands
> below describe the intended stable interface and cannot be used from public
> registries today.

## Why SMF

Mobile release automation often stops at “build and upload.” The difficult
part comes afterward: proving which source produced which store build, giving
people time to test it, and ensuring the approved artifact is the one that
reaches users.

SMF makes the release pull request that control point:

- **One place to review a release.** Versions, changelogs, store notes,
  candidates, and approvals stay together in Git.
- **Test before deciding to ship.** iOS goes to TestFlight and Android goes to
  a Google Play testing track while the release PR is still open.
- **Promote without rebuilding.** SMF ships the recorded App Store Connect
  build or Play `versionCode`, not a newly produced binary.
- **Release platforms independently.** iOS and Android keep separate versions,
  histories, candidates, delivery settings, tags, and GitHub Releases.
- **Start conservatively.** The generated configuration uploads candidates
  only. App Review and production delivery remain opt-in.
- **Scale to monorepos.** Every Flutter app gets isolated release state and can
  observe its own directory plus explicitly selected shared paths.

SMF coordinates Flutter, GitHub, App Store Connect, and Google Play through its
CLI. Its generated GitHub Actions workflow is an optional automation wrapper,
not a requirement. SMF does not create store accounts, apps, tester lists,
signing identities, policy answers, or product metadata for you.

## How it works

| What happens | What SMF does | What your team controls |
| --- | --- | --- |
| A `fix:` or `feat:` commit reaches the target branch | Calculates each affected platform's next version and opens or updates the app's release PR | The code review and Conventional Commit message |
| The release PR is open | Builds, signs, uploads, verifies, and records one candidate per planned platform | Testing the exact TestFlight or Play artifact and approving the release |
| The release PR is merged | Revalidates each recorded artifact, then applies the platform's optional `ship` target | Branch protection, merge approval, and the selected store destination |

```text
normal feature and fix PRs
            |
            v
   target branch (main)
            |
            v
   SMF app release PR
      /           \
     v             v
iOS candidate   Android candidate
 TestFlight     Play testing track
     \             /
      v           v
    test and approve
            |
      merge release PR
            |
            v
 verify, then leave or promote the same artifacts
```

The release PR is separate from your normal feature and fix PRs. Keep merging
application work into the target branch as usual; every qualifying commit
updates the same app-scoped release PR until you are ready to release.

### What a commit means

SMF uses Conventional Commits to decide which platforms need a release and how
their versions change:

| Commit on the target branch | Result |
| --- | --- |
| `fix: prevent startup crash` | Patch release for every enabled platform |
| `feat(auth): add passkeys` | Minor release for every enabled platform |
| `fix(ios): repair camera permission` | iOS patch only |
| `fix(android): repair back navigation` | Android patch only |
| `feat(ios,android)!: replace storage` | Major release for both |
| `chore: update documentation` | No release |

Feature scopes such as `auth` apply to every enabled platform. The special
`ios` and `android` scopes select platforms. Each platform's configured
`initial_version` is its release-history baseline; SMF calculates later
versions from qualifying commits.

### What merging the release PR means

Each platform separates the candidate destination from the optional `ship`
destination. New configurations create an internal-testing release candidate
and omit `ship`, so the first merge cannot move the artifact toward public
distribution. [Release candidate and ship targets](doc/configuration.md#ios)
explains every Apple and Google Play target, including TestFlight Beta App
Review, App Review, and Play Console Managed publishing.

## Get started

Follow the [Getting started guide](doc/getting-started.md) from beginning to
end. It is the single setup path for installation, initialization, store
access, credentials, GitHub configuration, the first candidate, and the first
safe merge. It keeps standard-repository and monorepo instructions separate so
you only need to follow the path that matches your repository.

## What SMF guarantees

- **No rebuild after approval.** Promotion uses the exact recorded Apple build
  ID or Google Play `versionCode`.
- **Source-to-artifact evidence.** Candidate receipts bind the source commit,
  tracked-input fingerprint, app identity, artifact digest, store artifact ID,
  and testing destination.
- **Hard identity checks.** A source, fingerprint, bundle ID, package name, or
  store-artifact mismatch stops delivery.
- **Git-backed release state.** Configuration, platform manifests,
  changelogs, store notes, and candidate receipts live under the Flutter app's
  `smf/` directory.
- **Credential boundaries.** Secrets use environment values and temporary
  files, never command arguments or committed release state.
- **Safe retries.** Matching valid candidates and completed release resources
  are reused where store contracts permit.

Candidate receipts are machine-owned evidence. Never edit one to work around a
failed integrity check.

## User guide

Start with one guide based on what you are trying to do:

| I need to... | Read |
| --- | --- |
| Set up SMF for the first time | [Getting started](doc/getting-started.md) |
| Prepare App Store Connect, TestFlight, signing, and Apple secrets | [Apple setup](doc/apple-bootstrap.md) |
| Prepare Google Play, testing, upload signing, and Android secrets | [Android setup](doc/android-bootstrap.md) |
| Understand the release PR and exact-candidate lifecycle | [How releases work](doc/how-it-works.md) |
| Change versions, paths, flavors, build commands, candidate targets, or ship targets | [Configuration](doc/configuration.md) |
| Write, localize, or generate customer-facing store notes | [Store release notes](doc/store-release-notes.md) |
| Automate the proven path from a qualifying change through production delivery | [End-to-end release automation](doc/end-to-end-automation.md) |
| Generate project files or release notes during the workflow | [Typed hooks](doc/hooks.md) |
| Review, merge, retry, recover, or abandon a release | [Operations and recovery](doc/operations.md) |
| Run SMF directly or integrate custom automation | [CLI reference](doc/cli.md) |
| Review credentials, permissions, trusted code, or incident response | [Security guide](doc/security.md) |

Most teams use the generated GitHub Actions workflow. Direct lifecycle commands
exist for recovery and custom automation, not as additional setup steps.

## Packages

Most users install only `smf_cli`; the generated Action provides the release
runtime. Add another package only when extending SMF:

| Package | Use it for |
| --- | --- |
| `smf_hooks` | Lightweight typed repository hooks |
| `smf_engine` | Custom platform-neutral planning and state |
| `smf_apple` | Custom Apple delivery integrations |
| `smf_android` | Custom Android and Google Play integrations |

## Common questions

### Do we keep using normal pull requests?

Yes. Feature, fix, and maintenance PRs still merge into your normal target
branch. SMF observes the resulting commits and maintains a separate release PR.
Merging the release PR does not prevent or replace other application PRs.

### Does a normal application commit publish immediately?

No. A qualifying commit prepares or updates the release PR and its store
candidates. Delivery can happen only after the exact candidates are tested,
the release PR is approved and merged, and the platform is configured for that
delivery behavior.

### Must iOS and Android release together?

No. They can share one app release PR while keeping different versions and
candidate receipts. Platform-scoped commits can release only iOS or only
Android.

### Does SMF rebuild after approval?

No. It reuses the recorded App Store Connect build ID or Google Play
`versionCode`, either leaving it in testing or promoting it according to the
configured [ship target](doc/configuration.md#candidate-only-default).

### Will the SMF release PR run our normal PR checks?

Not always with GitHub's default `GITHUB_TOKEN`. That token can run SMF and
create the release PR, but GitHub may suppress unrelated `pull_request`
workflows for a PR created by the same token. For example, a separate workflow
that normally runs `flutter analyze`, `flutter test`, or coverage checks may
not start. Use a GitHub App installation token, or a narrowly scoped
fine-grained token, when the SMF PR must trigger the same independent checks as
a human-authored PR. See
[GitHub permissions](doc/security.md#github-permissions).

### Where should I start troubleshooting?

Run `smf validate`, then use
[Retry and recovery](doc/operations.md#retry-and-recovery). Share the stable
SMF error code and message when asking for help, but never share credentials or
encoded signing files.

## Project status

SMF is being validated before its first public package and Action release.
Until the pre-release notice at the top is removed, treat the repository as an
auditable preview of the intended stable workflow rather than an installable
production dependency.

Contributor setup, architecture, and release procedures live in
[CONTRIBUTING.md](CONTRIBUTING.md), [ARCHITECTURE.md](ARCHITECTURE.md), and
[RELEASING.md](RELEASING.md). Security vulnerabilities should be reported
privately through [SECURITY.md](SECURITY.md). For usage questions and confirmed
bugs, [open a GitHub issue](https://github.com/Ventairy/smf/issues/new).
