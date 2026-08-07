# Releasing SMF packages

This runbook covers repeat releases of SMF's coordinated pub.dev packages. It
assumes Release Please and trusted publishing are configured.

| Package      | Release tag         |
| ------------ | ------------------- |
| `smf_hooks`  | `smf_hooks-vX.Y.Z`  |
| `smf_engine` | `smf_engine-vX.Y.Z` |
| `smf_cli`    | `smf_cli-vX.Y.Z`    |

Release Please maintains package versions, changelogs, component tags, and
GitHub Releases. The packages use one linked version: a releasable change to
any package updates and publishes all three. Each component retains its own tag
and pub.dev publication.

## 1. Prepare the release

Merge releasable changes to `main` through normal reviewed pull requests using
Conventional Commits. After `main` passes CI, wait for Release Please to create
or update the combined release pull request.

If an expected package is missing, verify that the commit type is releasable,
the change is under that package's directory, and the Release Please workflow
succeeded. Fix the source change or release configuration; do not create a
manual version commit or tag.

## 2. Review the release pull request

For every package:

1. Confirm all three packages propose the same version and that its bump is at
   least as large as the strongest Conventional Commit in the release.
2. Review the changelog as user-facing release notes.
3. Confirm `pubspec.yaml`, `CHANGELOG.md`, and the release manifest agree.
4. Confirm internal dependency constraints admit the released versions.
5. Run the [contributor validation gate](CONTRIBUTING.md#validate-the-change).
6. Inspect the package's `dart pub publish --dry-run` archive.
7. Confirm the exact release pull-request commit passed CI.

Package dependencies remain hosted semver constraints so published packages
work outside this repository. During development, `resolution: workspace`
selects the local workspace packages. Do not replace publishable dependencies
with `path:` dependencies.

The linked release policy keeps this dependency chain on one release version:

`smf_hooks` → `smf_engine` → `smf_cli`

## 3. Merge and publish

Merge only the reviewed release pull request whose exact head commit passed all
required checks.

The merge causes Release Please to create immutable component tags and GitHub
Releases. Each tag then starts the pub.dev publication workflow. Do not create,
reuse, delete, or move component tags manually.

When internal minimum versions change, verify publication in dependency order:

1. `smf_hooks`;
2. `smf_engine`;
3. `smf_cli`.

Publication jobs are independent. If a dependent package runs before its new
dependency is visible on pub.dev, wait for the dependency and rerun the failed
job from its existing tag.

## 4. Verify

For every released package, confirm:

- the component tag points to the release commit;
- the GitHub Release contains the expected notes;
- the pub.dev publication workflow succeeded;
- pub.dev shows the expected version, archive, analysis, and API docs;
- a clean consumer resolves the hosted package without path, Git, workspace,
  or dependency overrides.

For `smf_cli`, install the published command in a clean environment and exercise
the affected command surface. Record live Apple or Google Play validation
separately; package publication does not prove store acceptance.

## Recovery

- Before merge, fix `main`, wait for CI, and let Release Please update the
  release pull request.
- After tags exist, repair workflow configuration or wait for dependencies,
  then retry publication from the same immutable tag.
- If published code is incorrect, prepare a new corrective release. Never
  replace a pub.dev version or move its tag.
- Stop before releasing dependents if the release commit, tag, GitHub Release,
  workflow result, and pub.dev archive do not agree.

The adjacent `smf-action` repository checks hourly for the newest stable
`smf_cli` GitHub Release. When its recorded CLI version differs, it opens or
updates a reviewed synchronization pull request. The Action is not merged or
published automatically.
