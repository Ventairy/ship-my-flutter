# SMF

Release Flutter apps through one reviewable GitHub pull request.

SMF plans iOS and Android versions independently, builds store candidates from
the release PR, records the exact uploaded artifacts, and refuses to ship a
different source or binary after approval.

> [!WARNING]
> SMF is in pre-release validation. The Dart packages are not published yet and
> `Ventairy/smf-action@v1` does not exist yet. The commands below describe the
> intended stable interface.

The [SMF user guide](doc/README.md) is the definitive manual. It includes
beginner setup for [Apple](doc/apple-bootstrap.md) and
[Google Play](doc/android-bootstrap.md), complete configuration, normal release
operation, recovery, CLI use, and security.

## Release flow

1. Merge normal Conventional Commits into `main`.
2. SMF opens or updates the shared `smf/release` PR.
3. Each planned platform publishes its own candidate:
   - iOS uploads an IPA to TestFlight.
   - Android uploads an AAB to the configured Google Play testing track.
4. Test and approve each exact candidate.
5. Merge the release PR.
6. SMF verifies and ships those same store artifacts without rebuilding.

iOS and Android can release together through one PR or independently. Each
platform owns its version, candidate receipt, store behavior, tag, and GitHub
Release.

## Quick start

Install the CLI:

```bash
dart install smf_cli
```

From the Flutter app directory:

```bash
smf init \
  --current-version 1.0.0 \
  --bundle-id com.example.myapp \
  --package-name com.example.myapp
```

Omit `--bundle-id` when the app has no iOS directory. Omit `--package-name`
when it has no Android directory. Initialization creates:

```text
<flutter-app>/smf/config.yaml
<repository>/.github/workflows/smf.yml
```

Then complete [Getting started](doc/getting-started.md). Do not trigger the
first live workflow until the store account, signing assets, service account,
GitHub secrets, and tester access are ready.

## Commit routing

| Commit | Result |
| --- | --- |
| `feat: add saved searches` | Minor release for every enabled platform |
| `fix(auth): repair sign in` | Patch release for every enabled platform |
| `fix(ios): repair camera permission` | iOS patch only |
| `fix(android): repair back navigation` | Android patch only |
| `feat(ios,android)!: replace storage` | Major release for both |
| `chore: update docs` | No release |

Use `Release-As-ios: X.Y.Z` or `Release-As-android: X.Y.Z` in a commit body to
set one platform’s next stable version explicitly.

## Packages

Normal users install only `smf_cli`. The generated Action contains the runtime
packages.

Add a package as a development dependency only when customizing SMF:

| Need | Package |
| --- | --- |
| Typed repository hooks | `smf_hooks` |
| Custom platform-neutral planning/state | `smf_engine` |
| Custom Apple delivery code | `smf_apple` |
| Custom Android/Google Play delivery code | `smf_android` |

```bash
dart pub add --dev smf_hooks
```

## Safety properties

- The initializer defaults both stores to upload-only behavior.
- Secrets are supplied through environment values and temporary files, never
  command arguments or repository state.
- Candidate receipts connect tracked source, app identity, artifact digest,
  store artifact ID, and testing destination.
- Shipping reuses the recorded App Store Connect build or Google Play
  `versionCode`; it does not rebuild.
- A tracked build-input change invalidates the old candidate.
- The Android upload keystore signs the AAB; Google Play App Signing keeps the
  separate app-signing key used for customer APKs.

## Development

Contributor architecture, validation, and release instructions live in
[AGENTS.md](AGENTS.md), [CONTRIBUTING.md](CONTRIBUTING.md),
[ARCHITECTURE.md](ARCHITECTURE.md), and [RELEASING.md](RELEASING.md). Those
maintainer documents are intentionally outside `doc/`; everything under
`doc/` is written for SMF users.

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
