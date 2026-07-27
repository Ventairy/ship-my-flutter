# Releasing smf

Release Please owns the core package version, changelog, immutable `vX.Y.Z`
tag, and GitHub Release. The first pub.dev publication remains a separately
authorized manual step. Later immutable tags use trusted publishing after the
maintainer explicitly enables it.

## Release PR

After CI passes for a push to `main`, `.github/workflows/release-please.yml`
runs. Release Please reads Conventional Commits after the current release
baseline and opens or updates one release PR.

Add a repository secret named `RELEASE_PLEASE_TOKEN` before enabling releases.
Use a GitHub App installation token or a narrowly scoped fine-grained personal
access token that can read repository metadata and write contents, issues,
and pull requests. The default `GITHUB_TOKEN` is deliberately not used: GitHub
otherwise requires approval before CI runs on an automation-created release
pull request. A missing or invalid secret fails the workflow so broken release
automation cannot appear healthy.

The release PR updates these synchronized version surfaces:

- `pubspec.yaml`;
- `CHANGELOG.md`;
- `.release-please-manifest.json`.

The external release credential lets the generated pull request trigger the
normal `pull_request` CI workflow without manual approval. Do not merge the
release PR until that exact branch passes the complete hosted gate.

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
must be published manually from the exact immutable Release Please tag. Leave
the `PUB_DEV_AUTOMATION_ENABLED` repository variable unset during this
bootstrap release so `.github/workflows/publish.yml` safely skips publication:

1. Check out the immutable tag in a clean worktree.
2. Repeat the complete gate and inspect the package archive.
3. Run `dart pub publish` and complete pub.dev authentication.
4. Verify the published version and archive on pub.dev.
5. In a clean Flutter consumer, verify `dart pub add --dev smf` and invoke the
   installed package with `dart run smf:init --help`.

Only after the first version exists, configure trusted publishing:

1. In the package's pub.dev **Admin** tab, enable publishing from GitHub
   Actions for repository `Ventairy/smf` with tag pattern `v{{version}}`.
2. Create a protected GitHub environment named `pub.dev`. Restrict deployment
   branches and tags to the release policy and add required reviewers.
3. Add the repository variable `PUB_DEV_AUTOMATION_ENABLED` with value `true`.

Future Release Please tags then invoke the Dart-maintained reusable publishing
workflow with a short-lived GitHub OIDC identity. The workflow requires the
protected `pub.dev` environment, validates the package archive again, and
publishes the exact immutable tag without a long-lived pub.dev credential.
Keep publication separate from Release Please so a publication failure cannot
rewrite release history.

## GitHub Action

1. Run the core gate and `pnpm run vendor-core` in the adjacent Action checkout.
2. In `smf-action`, run `pnpm install --frozen-lockfile`, resolve
   the vendored Dart lockfile, and run `pnpm run check`.
3. Confirm `vendor/smf/CORE_COMMIT` names the reviewed immutable
   core commit. Regenerate `dist`, then verify a second build produces no diff
   in `dist` or `vendor`.
4. Test `plan`, candidate dispatch, and merged-release dispatch against a
   disposable Flutter repository. Do not use production Apple credentials.
5. Complete the separately tracked live Apple acceptance gate.
6. Follow the Action repository's Release Please procedure; do not create or
   move its release tags manually.
7. Confirm a clean external repository can use
   `Ventairy/smf-action@v1`.

Do not tag, publish, or move `v1` from an unvalidated working tree.
