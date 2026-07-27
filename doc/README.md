# SMF user guide

This directory is the definitive guide for installing, configuring, operating,
and troubleshooting SMF. It is written for app teams; you do not need to
understand SMF’s package internals.

SMF supports:

- iOS candidates in TestFlight and delivery through App Store Connect;
- Android App Bundles in a Google Play testing track and promotion of the same
  `versionCode` to production; and
- one shared release PR when either or both platforms need a release.

> [!WARNING]
> SMF is still completing its first public release. The packages and
> `Ventairy/smf-action@v1` may not be installable yet. This manual documents the
> intended stable interface.

## Start here

Follow [Getting started](getting-started.md) in order. It sends you to the
platform setup guides when needed:

- [Set up Apple delivery](apple-bootstrap.md)
- [Set up Android and Google Play delivery](android-bootstrap.md)

Return to Getting Started after each platform guide. Store setup does not
replace SMF initialization, and initialization does not create store accounts,
apps, tester lists, or signing credentials.

## Daily use

- [Configuration](configuration.md) explains every supported setting.
- [How releases work](how-it-works.md) explains commit routing, the shared
  release PR, platform candidates, approval, and exact-artifact shipping.
- [Release operations and recovery](operations.md) is the checklist for
  reviewing, merging, retrying, or abandoning a release.
- [CLI reference](cli.md) lists commands, branches, credentials, outputs, and
  side effects.
- [Security guide](security.md) explains secrets, trusted project code,
  permissions, Action pinning, and incident response.

Most teams use the generated GitHub Actions workflow. Direct CLI lifecycle
commands exist for recovery and custom automation, not as extra setup steps.

## Choose the right package

Standard users install the CLI:

```bash
dart install smf_cli
```

The Flutter app does not add an SMF package. Add a package as a development
dependency only for customization:

| Need | Package |
| --- | --- |
| Write a typed repository hook | `smf_hooks` |
| Build platform-neutral release automation | `smf_engine` |
| Call Apple delivery operations from Dart | `smf_apple` |
| Call Android/Google Play delivery operations from Dart | `smf_android` |

## Core guarantees

- iOS and Android versions are independent.
- One `smf/release` PR can contain either or both platform releases.
- Each candidate is built once, uploaded to its testing destination, and
  recorded in a machine-owned receipt.
- Shipping verifies that receipt and reuses the exact store artifact.
- The default `upload` mode never submits an iOS build for review and never
  moves an Android build to production.
- A person must test and approve every candidate before the release PR is
  merged.

## Common questions

### Does a normal application commit publish immediately?

No. A qualifying commit updates the release PR. SMF then creates store
candidates for testing. Public delivery can happen only after the release PR
is merged and the platform is configured for it.

### Must iOS and Android release together?

No. Unscoped and feature-scoped commits apply to all enabled platforms.
`ios`- or `android`-scoped commits apply only to that platform. When both need
a release, their plans share one PR but retain separate versions and receipts.

### Does SMF rebuild after approval?

No. It verifies and promotes the recorded App Store Connect build ID or Google
Play `versionCode`.

### Where is release state stored?

Under the Flutter app’s `smf/` directory. User-owned configuration and store
notes are reviewed alongside machine-owned manifests, changelogs, and
candidate receipts.

### Where should I start troubleshooting?

Run:

```bash
smf validate
```

Then use [Retry and recovery](operations.md#retry-and-recovery). Include the
stable SMF error code and message when asking for help, but never include
credentials or encoded signing files.
