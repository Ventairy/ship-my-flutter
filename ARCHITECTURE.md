# Maintainer architecture

SMF keeps shared release behavior and platform delivery organized as separate
libraries inside one release engine.

## Packages and repositories

- `smf_hooks`: lightweight typed SDK for repository-owned hooks.
- `smf_engine`: the complete release implementation:
  - `smf_engine.dart` exposes shared planning, state, fingerprints, Git/GitHub
    orchestration, shared-branch management, and release contracts;
  - `apple.dart` exposes Apple credentials/signing, IPA build, App Store
    Connect, TestFlight, and App Store delivery from `lib/src/ios`;
  - `android.dart` exposes Google credentials, upload-key signing, AAB build,
    Android Publisher edits/tracks, and Google Play delivery from
    `lib/src/android`.
- `smf_cli`: the only executable; composes the three engine libraries.
- `Ventairy/smf-action`: vendored deployment adapter over the public phased
  CLI that delegates to the same prepare, release candidate, and ship operations used
  manually.

Dependency direction:

```text
smf_cli -> smf_engine -> smf_hooks
```

Shared engine code can understand supported platforms and their configuration,
but store clients, signing, builds, credentials, and platform-specific delivery
must remain under the corresponding Apple or Android source tree. The platform
libraries do not import one another.

The Action handles GitHub-native input/output, masking, toolchain isolation, and
process invocation only. Release decisions and store side effects remain Dart.
The public CLI composes the same operations sequentially so neither release candidate
creation nor shipping depends on an Action runner.

## App-owned state

| File                                      | Purpose                                    |
| ----------------------------------------- | ------------------------------------------ |
| `config.yaml`                             | Schema-linked user choices                 |
| `manifest.json`                           | Independent platform version/pending state |
| `changelog.json`                          | Independent platform release history       |
| `store-release-notes.json`                | Optional user/hook-owned localized copy    |
| `release_candidates/<platform>-X.Y.Z.intent.json` | Durable pre-upload release candidate identity      |
| `release_candidates/ios-X.Y.Z.json`               | Exact Apple release candidate evidence             |
| `release_candidates/android-X.Y.Z.json`           | Exact Google Play release candidate evidence       |

Initialization creates configuration and, unless disabled, the optional
workflow wrapper. Release state remains lazy. No secret is valid in app-owned
state.

## Shared release PR

Planning treats the configured remote target branch as authoritative. The CLI
fetches it into an isolated temporary checkout, plans and updates the release
branch there, and removes the checkout afterward. The caller's branch,
uncommitted files, unpushed commits, and local release-branch state do not
participate.

Planning runs for every enabled platform on that remote target branch:

1. Resolve the platform’s latest tag/baseline.
2. Parse Conventional Commits for that platform.
3. Select the highest platform-applicable Conventional Commit bump.
4. Apply all pending plans to the app's `smf/<app-id>/release` branch.
5. Run one typed `before_create_pr` hook containing all plans.
6. Create or update one PR.

The branch is merged with the latest target branch rather than recreated, so
user-owned notes and release candidate receipts survive refreshes.

On `smf/<app-id>/release`, orchestration emits a deterministic release candidate
matrix. The
workflow uses `max-parallel: 1` because each platform commits a receipt to the
same branch.

## Release candidate contract

Release candidate creation treats the remote app release branch as authoritative. The
CLI fetches that branch into an isolated temporary checkout, runs the adapter
there, and removes the checkout afterward. The caller's branch, uncommitted
files, and local release-branch state do not participate in release candidate creation.

Both adapters:

1. require the shared branch and clean worktree;
2. run the typed platform `before_build` hook;
3. resolve immutable app identity;
4. compute the generic source fingerprint;
5. reuse only exact store-validated receipts;
6. build and sign one artifact;
7. commit a schema-v1 `ReleaseCandidateIntent` with its build identity and digest;
8. upload and verify local/store evidence;
9. place it in a promotable testing destination; and
10. atomically replace the intent with a schema-v1 `ReleaseCandidateReceipt`.

Generic receipt fields include platform, version/build number, artifact/app
identifiers, source commit hash/fingerprint, artifact SHA-256, upload time, processing
state, and testing destinations.

Apple uses a temporary keychain/profiles and App Store Connect build IDs.
Android uses a private temporary upload keystore, strips any local/template JAR
signature, signs the AAB with `jarsigner`, verifies the signature/certificate,
uploads through an Edit, and records Play `versionCode`.

Fingerprinting excludes delivery-only policy, notes, changelog, and receipts,
while hashing platform build-affecting configuration.

## Ship contract

Ship treats the remote repository as authoritative. It reads the committed
configuration from the remote default branch, creates an isolated checkout of
the configured remote target branch, and queries remote tags directly. The
caller's checkout, uncommitted files, local branches, and local tags never
participate in a ship decision.

In that isolated target-branch checkout, each pending remotely untagged
platform:

1. loads its receipt;
2. recomputes source/app identity;
3. validates the exact store artifact/testing destination;
4. applies the platform's optional ship target without rebuilding; and
5. creates/reuses `<platform>-v<version>` GitHub Release.

Apple reuses the exact processed build. Android reuses the exact AAB
`versionCode` from the testing track. Google Play production updates refuse to
replace unfinished releases and commits use `ERROR_IF_IN_REVIEW`.

## Retry model

Operations are idempotent where store contracts permit. Exact valid
release candidates, App Store versions/localizations, Play track state, tags, and
GitHub Releases are reused. A remotely committed release candidate intent lets a fresh
runner recover only its exact Apple build number or Android
`versionCode`/digest after upload or receipt-push interruption. Uncommitted Play
edits are best-effort deleted and otherwise expire. Cleanup failures must not
hide the originating error.
