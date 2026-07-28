# Releasing SMF packages

The Dart workspace contains five independently versioned pub.dev packages:
`smf_hooks`, `smf_engine`, `smf_apple`, `smf_android`, and `smf_cli`.

Release Please owns their package versions, package changelogs, immutable
component tags, and GitHub Releases. It opens one combined manifest release PR
but releases only the packages with relevant Conventional Commits under that
package's directory.

| Package | Immutable tag |
| --- | --- |
| `smf_hooks` | `smf_hooks-vX.Y.Z` |
| `smf_engine` | `smf_engine-vX.Y.Z` |
| `smf_apple` | `smf_apple-vX.Y.Z` |
| `smf_android` | `smf_android-vX.Y.Z` |
| `smf_cli` | `smf_cli-vX.Y.Z` |

## Release PR

After CI passes for a push to `main`, `.github/workflows/release-please.yml`
runs. Add a repository secret named `RELEASE_PLEASE_TOKEN` before enabling
releases. Use a GitHub App installation token or a narrowly scoped fine-grained
personal access token that can read metadata and write contents, issues, and
pull requests.

The release PR updates the affected package `pubspec.yaml`, its
`CHANGELOG.md`, and `.release-please-manifest.json`. Release Please has no Dart
workspace dependency-cascade plugin, so review internal constraints explicitly:

- a new `smf_hooks` API may require compatible `smf_engine`, adapters, and
  `smf_cli` releases;
- a new `smf_engine` API may require compatible adapter and CLI releases;
- a new adapter API may require a compatible CLI release.

The initial `>=0.1.0 <2.0.0` internal ranges are intentional: the unpublished
workspace versions and first stable `1.x` packages expose the same reviewed
APIs. Before any `2.0.0` internal package release, update every affected
dependent constraint and implementation in the same change so those dependent
packages receive their own release.

Before merging:

1. Review every proposed version and package changelog.
2. Confirm internal dependency constraints admit the proposed versions.
3. Run the complete gate from `CONTRIBUTING.md`.
4. Run `pana --exit-code-threshold 0 packages/<package>` for each releasable
   package whose internal SMF dependencies already exist on pub.dev.
5. Test `smf_cli` from a clean Flutter fixture and test affected libraries
   through hosted or path dependencies.
6. Confirm the exact release branch passed all hosted gates.

Merging creates one immutable component tag and GitHub Release per affected
package. Never create, reuse, or move those tags manually.

## pub.dev bootstrap and trusted publishing

Automated publishing cannot create a new pub.dev package. Bootstrap each
package manually from its exact immutable component tag, in dependency order:
`smf_hooks`, `smf_engine`, `smf_apple`/`smf_android`, then `smf_cli`.

1. Check out the tag in a clean worktree.
2. Repeat the complete gate and inspect that package's archive.
3. Run `pana --exit-code-threshold 0 packages/<package>`. During first
   bootstrap, do this only after every internal dependency is visible on
   pub.dev.
4. Run `dart pub publish` from `packages/<package>`.
5. Verify the published version, archive, analysis, and documentation on
   pub.dev before continuing to a dependent package.
6. Verify a clean consumer can install the intended surface:
   `dart install smf_cli`, `dart pub add --dev smf_hooks`, or the relevant
   custom-automation library.

After the first version exists, configure trusted publishing for that pub.dev
package:

1. In its pub.dev **Admin** tab, allow GitHub Actions from `Ventairy/smf` with
   the package's component tag pattern.
2. Use the protected GitHub environment `pub.dev`, with the desired tag
   restrictions and reviewers.

Future component tags call Dart's reusable OIDC publisher with the matching
package working directory. Publication stays separate from Release Please so a
pub.dev failure cannot rewrite release history.

When a release raises an internal package's minimum version, publish in
dependency order: `smf_hooks`, `smf_engine`, `smf_apple`/`smf_android`, then
`smf_cli`.
Component-tag workflows are independently retryable, so retry a dependent
package only after its new dependency is visible on pub.dev.

## Companion GitHub Action

1. Run the workspace gate and `pnpm run vendor-smf` in the adjacent Action
   checkout.
2. Run `pnpm install --frozen-lockfile` and `pnpm run check` in `smf-action`.
3. Confirm `vendor/smf/SMF_COMMIT` names the reviewed workspace commit.
4. Regenerate `dist`, then verify a second build leaves no diff.
5. Test plan, candidate dispatch, and merged-release dispatch against a
   disposable Flutter repository.
6. Complete the separately tracked live Apple and Google Play acceptance
   gates.
7. Follow the Action repository's Release Please procedure; never create or
   move its tags manually.

Do not tag, publish, upload, or move `v1` from an unvalidated working tree.
