# Security model

ship-my-flutter handles high-value signing material. Its defaults are intentionally narrow.

## Secret lifecycle

- Secrets enter only through GitHub Action inputs/environment variables.
- The `.p12`, `.p8`, provisioning profiles, keychain password, and temporary export options are never written inside the repository.
- Files are created with owner-only permissions where the platform supports them.
- Signing uses a dedicated temporary keychain.
- Action credential inputs are exposed only to the execution step. The action
  masks them, consumes them into memory, and clears the credential environment
  before repository hooks, Flutter, Git, or Xcode subprocesses run. Vendored
  Dart dependencies are resolved in an earlier step that receives no credential
  inputs. Do not expose release credentials as job-level environment variables,
  because GitHub would then make them available to every setup step.
- Installed profiles created by the action, private API key, keychain, and temporary directory are removed in `finally` cleanup. A matching profile that existed before the action is retained.
- Child-process failures omit command arguments so passwords cannot be copied into error messages. The action never intentionally logs secret values.
- Generated checkouts do not persist a Git credential. The action supplies its token only to the individual Git fetch or push that needs it.
- Hooks are arbitrary repository-owned POSIX shell code. `build_command` is one
  repository-owned shell invocation with managed release arguments appended.
  Both are trusted at the same boundary as the workflow and application source.
  Credential variables are removed before they run, but maintainers must still
  review command changes before exposing release secrets.
- `ipa_output_path` must stay under `app_path`; resolved symlinks are
  checked again after the build.

GitHub should restrict release environments, secret access, and workflow modification to trusted maintainers. Do not run the candidate phase for untrusted fork code with secrets.
Prefer a dedicated ephemeral macOS runner when using self-hosted infrastructure.

## Supply chain

- The action vendors the reviewed Dart core source, then generates and commits
  its deployment lockfile from that source's `pubspec.yaml`.
- The Action's Dart setup and the generated workflow's Flutter setup are pinned
  to full commit SHAs.
- The Action resolves the vendored package with `--enforce-lockfile`, which
  checks the locked hosted-package content hashes before execution.
- The core's strict analyzer, tests, and pub dry run plus the Action's locked
  install and full format/lint/typecheck/test/build gate are expected before
  release.

The consumer references `Ventairy/ship-my-flutter-action@v1` for stable updates. High-assurance repositories can pin the action to a reviewed full release commit.

## GitHub permissions

The generated workflow grants each job only what its phase uses:

- Plan: `contents: write` to maintain the release branch, `pull-requests: write` to open/update the release PR, and `issues: write` to apply its lifecycle label.
- Candidate: `contents: write` only, to commit the TestFlight receipt.
- Promote: `contents: write` only, to create the platform tag and GitHub Release.

All other permissions default to read or none. No organization-wide token is
required when the repository or organization allows GitHub Actions to create
pull requests. The default repository `GITHUB_TOKEN` is otherwise sufficient
because candidate delivery runs in the same workflow that creates the PR; the
design does not depend on a token-generated push triggering another workflow.

If repository or organization policy disables PR creation for `GITHUB_TOKEN`,
pass a GitHub App installation token or narrowly scoped personal access token
to the plan action's `github-token` input. Grant Contents, Pull requests, and
Issues read/write access; the alternative token performs both the API
operations and release-branch push.

GitHub does not create new workflow runs for events produced by the default
`GITHUB_TOKEN`. ship-my-flutter's candidate still runs because the generated
workflow dispatches it from the plan job's outputs, but unrelated
`pull_request` workflows will not run for the generated release PR.
Repositories that require those independent checks must use a GitHub App
installation token (preferred) or narrowly scoped personal access token as the
plan action's `github-token` input. Treat that credential as a release secret
and grant only the repository permissions used by the plan phase.

## Promotion integrity

The candidate receipt records:

- marketing version and Apple build number;
- opaque App Store Connect app/build IDs;
- source commit and deterministic tracked-file fingerprint;
- IPA SHA-256;
- processing status and upload time;
- assigned TestFlight groups.

The fingerprint covers files tracked by Git. Ignored and untracked files are
outside this integrity boundary and must not be required build inputs. A
tracked symlink is accepted only when it resolves inside the repository to
another tracked file; external and hidden targets are rejected.

Promotion recomputes the fingerprint, resolves the current bundle identifier,
looks up its App Store Connect app, and verifies that the recorded build belongs
to that app and marketing version. A mismatch is a hard failure, not a warning.

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability. Follow [`SECURITY.md`](../SECURITY.md).
