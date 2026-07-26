# Releasing ship-my-flutter

Release Please owns the core package version, changelog, immutable `vX.Y.Z`
tag, and GitHub Release. Publishing to pub.dev remains a separately authorized
step.

## Release PR

After CI passes for a push to `main`, `.github/workflows/release-please.yml`
runs. Release Please reads Conventional Commits after the current release
baseline and opens or updates one release PR.

Add a repository secret named `RELEASE_PLEASE_TOKEN` before enabling releases.
Use a GitHub App installation token or a narrowly scoped fine-grained personal
access token that can read repository metadata and write contents, issues,
pull requests, and Actions. The default `GITHUB_TOKEN` is deliberately not
used: GitHub otherwise requires the broader repository setting that also lets
Actions approve pull requests. Without the secret, the workflow succeeds with
a warning and performs no release mutation.

The release PR updates these synchronized version surfaces:

- `pubspec.yaml`;
- `lib/src/cli.dart`;
- `CHANGELOG.md`;
- `.release-please-manifest.json`.

The CI workflow is dispatched for the generated release branch. Do not merge
the release PR until that exact branch passes the complete hosted gate.

Before merging:

1. Review the proposed semantic version and changelog.
2. Run the complete development gate from `CONTRIBUTING.md`.
3. Test the package through a path dependency in a clean Flutter fixture.
4. Confirm the release branch CI passed on Dart 3.10, stable Dart, minimum
   dependencies, and the publication dry run.

Merging the release PR makes Release Please create the immutable `vX.Y.Z` tag
and matching GitHub Release. Do not create, reuse, or move these tags manually.

## pub.dev

Automated publishing cannot create a new pub.dev package. The first release
must be published manually from the exact immutable Release Please tag:

1. Check out the immutable tag in a clean worktree.
2. Repeat the complete gate and inspect the package archive.
3. Run `dart pub publish` and complete pub.dev authentication.
4. Verify the published version and archive on pub.dev.
5. Verify both `dart pub add --dev ship_my_flutter` and
   `dart pub global activate ship_my_flutter` in separate clean consumers.

Only after the first version exists may maintainers configure pub.dev automated
publishing for `Ventairy/ship-my-flutter`. Use the tag pattern
`v{{version}}`, require a protected GitHub environment named `pub.dev`, and add
a tag-triggered OIDC publishing workflow. Keep publication separate from the
Release Please job so a publication failure cannot rewrite release history.

## GitHub Action

1. Run the core gate and `pnpm run vendor-core` in the adjacent Action checkout.
2. In `ship-my-flutter-action`, run `pnpm install --frozen-lockfile`, resolve
   the vendored Dart lockfile, and run `pnpm run check`.
3. Confirm `vendor/ship-my-flutter/CORE_COMMIT` names the reviewed immutable
   core commit. Regenerate `dist`, then verify a second build produces no diff
   in `dist` or `vendor`.
4. Test `plan`, candidate dispatch, and merged-release dispatch against a
   disposable Flutter repository. Do not use production Apple credentials.
5. Complete the separately tracked live Apple acceptance gate.
6. Create an immutable release tag such as `v1.0.0`.
7. Move the floating major tag `v1` only after the immutable release succeeds.
8. Confirm a clean external repository can use
   `Ventairy/ship-my-flutter-action@v1`.

Do not tag, publish, or move `v1` from an unvalidated working tree.
