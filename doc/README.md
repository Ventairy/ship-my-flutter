# SMF user guide

SMF turns ordinary Flutter commits into a release pull request, an exact
TestFlight candidate, and—only after approval—the delivery of that same build.

This directory is the definitive guide for people installing, configuring, and
operating SMF. You do not need to understand SMF's source repositories or
package internals to use it.

> [!NOTE]
> SMF currently supports iOS delivery through App Store Connect. Android
> delivery is not available yet.

> [!WARNING]
> SMF is still completing its first public release. Check the
> [project status](../README.md#smf) before expecting the Dart packages or
> `Ventairy/smf-action@v1` to be installable. This guide documents the intended
> stable interface.

## Start here

Begin with [Getting started](getting-started.md). It owns the complete setup
sequence. When section 5 sends you to [Apple setup](apple-bootstrap.md),
complete that Apple-only procedure and follow its return link back to section
6 of Getting Started. Do not run initialization or trigger a release from the
Apple guide.

After the first setup, use:

1. [Configuration](configuration.md) — choose versions, flavors, build
   commands, TestFlight groups, App Store behavior, and optional hooks.
2. [How releases work](how-it-works.md) — understand commit routing, the
   release PR, candidate build, approval, and promotion.
3. [Release operations and recovery](operations.md) — review, merge, retry, or
   abandon a release safely.

Most teams use the generated GitHub Actions workflow and do not need to call
the lifecycle commands directly.

## Reference and security

- [CLI reference](cli.md) lists every command, required credentials, runner,
  output, and side effect.
- [Security guide](security.md) explains credential handling, GitHub
  permissions, trusted code, Action pinning, and what to do after exposure.

## Choose the right SMF package

Standard GitHub Actions users install only the global CLI:

```bash
dart install smf_cli
```

The CLI generates the workflow; the Flutter app does not add an SMF package.

Add a package only for customization:

| Need | Package |
| --- | --- |
| Write a typed repository hook | `smf_hooks` as a development dependency |
| Build custom platform-neutral Dart automation | `smf_engine` as a development dependency |
| Call Apple delivery APIs from custom Dart automation | `smf_apple` as a development dependency |

The standard workflow already includes the necessary runtime.

## Common questions

### Does merging normal application work publish immediately?

No. Qualifying commits update a release PR. SMF first builds and uploads a
candidate from that PR. A release owner tests the exact candidate before
merging the release PR.

### Does the first setup make the app public?

No. The generated configuration uses `app_store.mode: upload`. It uploads the
tested build without submitting App Review. Changing to `review` or `auto` is
an explicit later decision.

### Does SMF rebuild after approval?

No. Promotion verifies the App Store Connect build recorded by the release PR.
It refuses to continue when the app identity or tracked build inputs no longer
match.

### Where are versions stored?

Each platform owns its version in SMF's Git-backed release state. The iOS
release tag is `ios-vX.Y.Z`; the Flutter app does not need one global version
for every platform.

### Where should I ask for help?

First run:

```bash
smf validate
```

Then use the [recovery guide](operations.md#retry-and-recovery). When reporting
an error, include the command or workflow phase, the stable SMF error code, and
the diagnostic message—but never include credentials. Report suspected
security problems privately as described in the [security guide](security.md).
