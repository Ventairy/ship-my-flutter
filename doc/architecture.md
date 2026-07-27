# Architecture

ship-my-flutter separates release planning from irreversible delivery.

## Repositories

- `Ventairy/ship-my-flutter` is the Dart package. It contains the public library
  API, CLI, schemas, release planner, GitHub orchestration, signing
  implementation, and App Store Connect client.
- `Ventairy/ship-my-flutter-action` vendors the exact Dart package source,
  generates and commits a deployment lockfile, records the source commit in
  `vendor/ship-my-flutter/CORE_COMMIT`, and exposes the three workflow phases
  as one GitHub Action.

TypeScript in the Action is intentionally limited to GitHub-native concerns:
inputs, secret masking, repository context, process execution, failures, and
outputs. Every release decision and side effect lives in Dart, so local CLI,
custom workflows, and the turnkey Action cannot drift into separate products.
The Action installs a pinned Dart SDK and resolves the vendored package with
its enforced lockfile. The consumer owns the Flutter/FVM toolchain used for
project hooks and IPA creation. A consumer does not install Fastlane or a Node
package.

## State owned by the app repository

| File                        | Purpose                                                       |
| --------------------------- | ------------------------------------------------------------- |
| `config.yaml`               | Required schema-linked user choices and platform configuration |
| `manifest.json`             | Lazily generated independent platform release state            |
| `changelog.json`            | Lazily generated release history and Conventional Commit data  |
| `store-release-notes.json`  | Optional user-owned localized store copy                        |
| `candidates/ios-X.Y.Z.json` | Lazily generated receipt for the processed TestFlight build     |

No secret is valid in any of these files.

Initialization creates only `config.yaml` and the GitHub workflow. The first
release PR generates the manifest and changelog. Candidate delivery creates its
receipt directory when needed. Store notes are never generated as an empty
placeholder; the file exists only when a maintainer or hook supplies notes.

## State machine

### 1. Pull request

On a push to the target branch, the planner:

1. Finds the latest `ios-vX.Y.Z` tag, or derives the initial baseline from the
   commit that introduced `config.yaml`.
2. Parses commits in chronological order.
3. Applies unscoped and non-platform-scoped commits to iOS.
4. Applies `ios` commits only to iOS and excludes other recognized platform scopes.
5. Chooses the highest SemVer bump or a valid `Release-As` override.
6. Updates the stable platform branch and opens or refreshes its release PR.

The release branch is merged with the latest target branch instead of being recreated, which preserves human edits to store notes.

### 2. Release candidate

The `release-candidate` job:

1. Runs the optional repository-owned `before_build` preparation hook.
2. By default commits and pushes everything left by the hook; with
   `commit: false`, requires the hook to leave a clean worktree.
3. Resolves the bundle ID and App Store Connect app.
4. Computes a fingerprint over tracked build inputs.
5. Reuses an existing valid receipt when the fingerprint matches.
6. Queries Apple for the next build number.
7. Creates a temporary keychain and installs every supplied provisioning
   profile.
8. Resolves the explicit build command or automatically selects FVM from
   repository configuration, then appends the immutable iOS version, build
   number, export options, and configured flavor.
9. Resolves `ipa_output_path` and rejects path/symlink escapes.
10. Refuses upload if the build changed tracked or unignored repository inputs.
11. Uploads through Apple’s `altool` API-key flow and waits for `VALID`.
12. Applies TestFlight “What’s New” localizations and beta groups.
13. Commits a receipt to the release PR.

The fingerprint deliberately ignores the changelog, store notes, candidate
receipts, and delivery-only settings such as TestFlight groups or App Store
release mode. It hashes the build-relevant iOS configuration separately and
rejects tracked symlinks to external or untracked inputs. Editing release copy
or promotion policy does not rebuild an identical app; editing an actual build
input does.

### 3. Ship

When the release PR reaches the target branch, `pendingRelease` is true and the matching platform tag does not yet exist. The `ship` job:

1. Loads the committed receipt.
2. recomputes the build-input fingerprint.
3. verifies the exact Apple build is still `VALID`.
4. optionally creates/reuses the App Store version, attaches the build, writes notes, and submits the current review-submission workflow.
5. creates the platform-prefixed GitHub Release and tag.

Every operation is designed to be retryable. Existing App Store versions, localizations, candidate builds, and GitHub Releases are reused when safe.

## Future Android support

Platform is already a first-class key across configuration, manifests, changelogs, release notes, tags, branches, and commit routing. Android adds a delivery adapter and manifest member; it does not require a shared version or a new release model.
