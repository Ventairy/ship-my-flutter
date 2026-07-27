# Maintainer architecture

SMF separates generic release planning from platform delivery.

## Packages and repositories

- `smf_hooks`: lightweight typed SDK for repository-owned hooks.
- `smf_engine`: platform-neutral planning, persisted state, fingerprints,
  Git/GitHub orchestration, shared-branch management, and candidate contracts.
- `smf_apple`: Apple credentials/signing, IPA build, App Store Connect,
  TestFlight, and App Store delivery.
- `smf_android`: Google credentials, upload-key signing, AAB build, Android
  Publisher edits/tracks, and Google Play delivery.
- `smf_cli`: the only executable; composes engine and adapters.
- `Ventairy/smf-action`: vendored deployment adapter over private
  `smf action` phases.

Dependency direction:

```text
smf_cli -> smf_engine -> smf_hooks
smf_cli -> smf_apple -> smf_engine
smf_cli -> smf_android -> smf_engine
```

Core never imports an adapter. Adapters do not import one another.

The Action handles GitHub-native input/output, masking, toolchain isolation, and
process invocation only. Release decisions and store side effects remain Dart.

## App-owned state

| File | Purpose |
| --- | --- |
| `config.yaml` | Schema-linked user choices |
| `manifest.json` | Independent platform version/pending state |
| `changelog.json` | Independent platform release history |
| `store-release-notes.json` | Optional user/hook-owned localized copy |
| `candidates/ios-X.Y.Z.json` | Exact Apple candidate evidence |
| `candidates/android-X.Y.Z.json` | Exact Google Play candidate evidence |

Initialization creates configuration/workflow only. Release state remains lazy.
No secret is valid in app-owned state.

## Shared release PR

Planning runs for every enabled platform on the target branch:

1. Resolve the platform’s latest tag/baseline.
2. Parse Conventional Commits for that platform.
3. Select the highest bump or platform/global `Release-As`.
4. Apply all pending plans to one `smf/release` branch.
5. Run one typed `before_create_pr` hook containing all plans.
6. Create or update one PR.

The branch is merged with the latest target branch rather than recreated, so
user-owned notes and candidate receipts survive refreshes.

On `smf/release`, orchestration emits a deterministic candidate matrix. The
workflow uses `max-parallel: 1` because each platform commits a receipt to the
same branch.

## Candidate contract

Both adapters:

1. require the shared branch and clean worktree;
2. run the typed platform `before_build` hook;
3. resolve immutable app identity;
4. compute the generic source fingerprint;
5. reuse only exact store-validated receipts;
6. build, sign, and upload one artifact;
7. verify local/store evidence;
8. place it in a promotable testing destination; and
9. commit schema-v2 `CandidateReceipt`.

Generic receipt fields include platform, version/build number, artifact/app
identifiers, source SHA/fingerprint, artifact SHA-256, upload time, processing
state, and testing destinations.

Apple uses a temporary keychain/profiles and App Store Connect build IDs.
Android uses a private temporary upload keystore, strips any local/template JAR
signature, signs the AAB with `jarsigner`, verifies the signature/certificate,
uploads through an Edit, and records Play `versionCode`.

Fingerprinting excludes delivery-only policy, notes, changelog, and receipts,
while hashing platform build-affecting configuration.

## Ship contract

On the target branch, each pending untagged platform:

1. loads its receipt;
2. recomputes source/app identity;
3. validates the exact store artifact/testing destination;
4. applies platform delivery mode without rebuilding; and
5. creates/reuses `<platform>-v<version>` GitHub Release.

Apple reuses the exact processed build. Android reuses the exact AAB
`versionCode` from the testing track. Google Play production updates refuse to
replace unfinished releases and commits use `ERROR_IF_IN_REVIEW`.

## Retry model

Operations are idempotent where store contracts permit. Exact valid
candidates, App Store versions/localizations, Play track state, tags, and
GitHub Releases are reused. Uncommitted Play edits are best-effort deleted and
otherwise expire. Cleanup failures must not hide the originating error.
