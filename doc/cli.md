# CLI reference

The CLI and GitHub Action call the same Dart implementation. Use the Action for
the turnkey lifecycle; use these commands when operating locally or composing a
custom workflow.

Every command accepts `--root` (`-r`) to identify the Git repository root.
Commands that inspect history need a full checkout with tags. Successful
commands write one JSON value to stdout and diagnostics to stderr.

| Command | Runner and branch | Credentials | Side effects |
| --- | --- | --- | --- |
| `init` | Any OS; run against the Git root | None | Creates `config.yaml` and the starter workflow |
| `validate` | Any OS; any branch | None | Read-only repository/configuration checks |
| `plan` | Any OS; any branch | None | Read-only next-version calculation; it does not choose the Action's workflow phase |
| `open-pr` / `release` | Any OS; target branch, clean tree | GitHub token and `owner/repo` | Creates/updates the release branch, commits state, pushes, and opens/updates the PR |
| `candidate` / `testflight` | macOS; release branch, clean tree | Apple API key, signing assets; GitHub token when committing | Builds/signs/uploads, waits for Apple, writes and normally commits/pushes the candidate receipt |
| `promote` / `app-store` | Any OS; target branch, clean tree | Apple API key and GitHub token | Verifies the exact receipt/build, optionally submits it, then creates the platform GitHub Release |

GitHub commands read `GITHUB_REPOSITORY=owner/name` and
`SHIP_MY_FLUTTER_GITHUB_TOKEN` (or `GITHUB_TOKEN`). `--repository` and
`--github-token-file` are the non-environment alternatives. Apple and signing
variables are listed in the main README.

`candidate --no-commit-receipt` writes the receipt without committing or
pushing it. This is an advanced custom-workflow option: the exact receipt still
must reach the release PR before merge.

Before `candidate`, install the project toolchain. When `build_command` is
omitted, the CLI selects `fvm flutter build ipa --release` for repositories
with FVM configuration and `flutter build ipa --release` otherwise. The CLI
does not install Flutter, FVM, Melos, or project dependencies. Optional
preparation belongs in `hooks.before_build.run`.

`init --force` replaces the generated config and workflow. It preserves
manifest, changelog, store notes, and candidate receipts. Commit or back up
configuration changes first; do not use it as a routine update command.

Run `dart run ship_my_flutter <command> --help` for parser options. Raw secret
arguments are intentionally unsupported.
