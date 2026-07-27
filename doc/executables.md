# Package executable reference

The package executables and GitHub Action call the same Dart implementation.
Use the Action for the turnkey lifecycle; use these executables when operating
locally or composing a custom workflow.

Install SMF as a development dependency of the Flutter app:

```bash
dart pub add --dev smf
```

Run each executable through the app's resolved package graph with
`dart run smf:<executable>`. SMF does not provide a separate command router or
global installation.

Run from the Dart or Flutter package that declares the `smf` development
dependency. Every executable accepts `--smf-path` to select a specific nested
`app/smf` directory below that package when the working tree contains multiple
apps. Operations that inspect history need a full checkout with tags.
Successful executions write one JSON value to stdout and diagnostics to stderr.

| Executable | Runner and branch | Credentials | Side effects |
| --- | --- | --- | --- |
| `smf:init` | Any OS; run from the Flutter app | None | Creates `smf/config.yaml` and the repository workflow |
| `smf:validate` | Any OS; any branch | None | Read-only repository/configuration checks |
| `smf:plan` | Any OS; any branch | None | Read-only next-version calculation; it does not choose the Action's workflow phase |
| `smf:open_pr` / `smf:release` | Any OS; target branch, clean tree | GitHub token and `owner/repo` | Creates/updates the release branch, commits state, pushes, and opens/updates the PR |
| `smf:candidate` / `smf:testflight` | macOS; release branch, clean tree | Apple API key and signing assets; optional GitHub context | Builds/signs/uploads, waits for Apple, writes and normally commits/pushes the candidate receipt |
| `smf:promote` / `smf:app_store` | Any OS; target branch, clean tree | Apple API key and GitHub token | Verifies the exact receipt/build, optionally submits it, then creates the platform GitHub Release |

GitHub commands read `GITHUB_REPOSITORY=owner/name` and
`SMF_GITHUB_TOKEN` (or `GITHUB_TOKEN`). `--repository` and
`--github-token-file` are the non-environment alternatives. Apple and signing
variables are listed in the main README.

`dart run smf:candidate --no-commit-receipt` writes the receipt without committing or
pushing it. This is an advanced custom-workflow option: the exact receipt still
must reach the release PR before merge.

When candidate receipt commits are enabled, GitHub context supplies an
authenticated HTTPS push. Without it, SMF uses the checkout's ambient Git
authentication, such as SSH or a configured credential helper.

`plan` evaluates the history reachable from the current checkout. Run it from
the configured target branch when you want a release-equivalent preview;
running it from a feature branch can include that branch's unmerged commits.

Before running `smf:candidate` or `smf:testflight`, install the project
toolchain. When `build_command` is omitted, the executable selects
`fvm flutter build ipa --release` for repositories
where the selected app or an ancestor up to the Git root declares FVM, and
`flutter build ipa --release` otherwise. SMF does not install Flutter, FVM,
Melos, or project dependencies. Optional preparation belongs in
`smf/hooks/before_build.dart`.

`dart run smf:init --force` replaces the generated config and workflow. It preserves
manifest, changelog, store notes, and candidate receipts. Commit or back up
configuration changes first; do not use it as a routine update command.

Use `dart run smf:init --workflow-only` from the existing Flutter app directory
to refresh only `.github/workflows/smf.yml` after upgrading SMF. It preserves
`smf/config.yaml` and every release-state file. Review and commit the workflow
diff before running a release.

Run any executable with `--help` for its options, for example
`dart run smf:init --help`. Raw secret arguments are intentionally unsupported.
