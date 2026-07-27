# CLI reference

The CLI and GitHub Action call the same Dart implementation. Use the Action for
the turnkey lifecycle; use these commands when operating locally or composing a
custom workflow.

Run from the Flutter app or any ancestor that contains exactly one SMF app.
Every command accepts `--smf-path` to select a specific `app/smf` directory
when the working tree contains multiple apps. Commands that inspect history
need a full checkout with tags. Successful commands write one JSON value to
stdout and diagnostics to stderr.

| Command | Runner and branch | Credentials | Side effects |
| --- | --- | --- | --- |
| `init` | Any OS; run from the Flutter app | None | Creates `smf/config.yaml` and the repository workflow |
| `validate` | Any OS; any branch | None | Read-only repository/configuration checks |
| `plan` | Any OS; any branch | None | Read-only next-version calculation; it does not choose the Action's workflow phase |
| `open-pr` / `release` | Any OS; target branch, clean tree | GitHub token and `owner/repo` | Creates/updates the release branch, commits state, pushes, and opens/updates the PR |
| `candidate` / `testflight` | macOS; release branch, clean tree | Apple API key and signing assets; optional GitHub context | Builds/signs/uploads, waits for Apple, writes and normally commits/pushes the candidate receipt |
| `promote` / `app-store` | Any OS; target branch, clean tree | Apple API key and GitHub token | Verifies the exact receipt/build, optionally submits it, then creates the platform GitHub Release |

GitHub commands read `GITHUB_REPOSITORY=owner/name` and
`SMF_GITHUB_TOKEN` (or `GITHUB_TOKEN`). `--repository` and
`--github-token-file` are the non-environment alternatives. Apple and signing
variables are listed in the main README.

`candidate --no-commit-receipt` writes the receipt without committing or
pushing it. This is an advanced custom-workflow option: the exact receipt still
must reach the release PR before merge.

When candidate receipt commits are enabled, GitHub context supplies an
authenticated HTTPS push. Without it, SMF uses the checkout's ambient Git
authentication, such as SSH or a configured credential helper.

`plan` evaluates the history reachable from the current checkout. Run it from
the configured target branch when you want a release-equivalent preview;
running it from a feature branch can include that branch's unmerged commits.

Before `candidate`, install the project toolchain. When `build_command` is
omitted, the CLI selects `fvm flutter build ipa --release` for repositories
where the selected app or an ancestor up to the Git root declares FVM, and
`flutter build ipa --release` otherwise. The CLI does not install Flutter,
FVM, Melos, or project dependencies. Optional preparation belongs in
`smf/hooks/before_build.dart`.

`init --force` replaces the generated config and workflow. It preserves
manifest, changelog, store notes, and candidate receipts. Commit or back up
configuration changes first; do not use it as a routine update command.

Use `init --workflow-only` from the existing Flutter app directory to refresh
only `.github/workflows/smf.yml` after upgrading SMF. It preserves
`smf/config.yaml` and every release-state file. Review and commit the workflow
diff before running a release.

Run `dart run smf <command> --help` for parser options. Raw secret
arguments are intentionally unsupported.
