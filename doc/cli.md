# CLI reference

The CLI and GitHub Action call the same Dart implementation. Use the Action for
the turnkey lifecycle; use the CLI when operating locally or composing a
custom workflow.

Install the CLI globally:

```bash
dart install smf_cli
```

Run `smf <command>` from the Flutter app. Every command accepts `--smf-path` to
select a specific nested
`app/smf` directory below that package when the working tree contains multiple
apps. Operations that inspect history need a full checkout with tags.
Successful executions write one JSON value to stdout and diagnostics to stderr.

| Command | Runner and branch | Credentials | Side effects |
| --- | --- | --- | --- |
| `smf init` | Any OS; run from the Flutter app | None | Creates `smf/config.yaml` and the repository workflow |
| `smf validate` | Any OS; any branch | None | Read-only repository/configuration checks |
| `smf plan` | Any OS; any branch | None | Read-only next-version calculation; it does not choose the Action's workflow phase |
| `smf open-pr` / `smf release` | Any OS; target branch, clean tree | GitHub token and `owner/repo` | Creates/updates the release branch, commits state, pushes, and opens/updates the PR |
| `smf candidate` / `smf testflight` | macOS; release branch, clean tree | Apple API key and signing assets; optional GitHub context | Builds/signs/uploads, waits for Apple, writes and normally commits/pushes the candidate receipt |
| `smf promote` / `smf app-store` | Any OS; target branch, clean tree | Apple API key and GitHub token | Verifies the exact receipt/build, optionally submits it, then creates the platform GitHub Release |

GitHub commands read `GITHUB_REPOSITORY=owner/name` and
`SMF_GITHUB_TOKEN` (or `GITHUB_TOKEN`). `--repository` and
`--github-token-file` are the non-environment alternatives. Apple and signing
variables are listed in the main README.

`smf candidate --no-commit-receipt` writes the receipt without committing or
pushing it. This is an advanced custom-workflow option: the exact receipt still
must reach the release PR before merge.

When candidate receipt commits are enabled, GitHub context supplies an
authenticated HTTPS push. Without it, SMF uses the checkout's ambient Git
authentication, such as SSH or a configured credential helper.

`plan` evaluates the history reachable from the current checkout. Run it from
the configured target branch when you want a release-equivalent preview;
running it from a feature branch can include that branch's unmerged commits.

Before running `smf candidate` or `smf testflight`, install the project
toolchain. When `build_command` is omitted, the executable selects
`fvm flutter build ipa --release` for repositories
where the selected app or an ancestor up to the Git root declares FVM, and
`flutter build ipa --release` otherwise. SMF does not install Flutter, FVM,
Melos, or project dependencies. Optional preparation belongs in
`smf/hooks/before_build.dart`.

`smf init --force` replaces the generated config and workflow. It preserves
manifest, changelog, store notes, and candidate receipts. Commit or back up
configuration changes first; do not use it as a routine update command.

Use `smf init --workflow-only` from the existing Flutter app directory
to refresh only `.github/workflows/smf.yml` after upgrading SMF. It preserves
`smf/config.yaml` and every release-state file. Review and commit the workflow
diff before running a release.

Run any command with `--help` for its options, for example `smf init --help`.
Raw secret arguments are intentionally unsupported.
