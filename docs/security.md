# Security model

ship-my-flutter handles high-value signing material. Its defaults are intentionally narrow.

## Secret lifecycle

- Secrets enter only through GitHub Action inputs/environment variables.
- The `.p12`, `.p8`, provisioning profiles, keychain password, and temporary export options are never written inside the repository.
- Files are created with owner-only permissions where the platform supports them.
- Signing uses a dedicated temporary keychain.
- The action masks every credential input, consumes it into memory, and clears the credential environment before repository hooks, Flutter, pub, Git, or Xcode subprocesses run.
- Installed profiles, private API key, keychain, and temporary directory are removed in `finally` cleanup.
- Child-process failures omit command arguments so passwords cannot be copied into error messages. The action never intentionally logs secret values.

GitHub should restrict release environments, secret access, and workflow modification to trusted maintainers. Do not run the candidate phase for untrusted fork code with secrets.

## Supply chain

- The action ships a reviewed, bundled core snapshot; it does not download executable project code at runtime.
- The embedded Flutter setup action is pinned to a full commit SHA.
- Generated workflows pin GitHub-owned setup actions to full commit SHAs.
- npm lockfiles make development and bundling reproducible.
- `npm audit` and the full repository checks are expected before release.

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
to the plan action's `github-token` input. The alternative token performs the
GitHub API operations; the checkout credential and job-level `contents: write`
permission still push the release branch.

GitHub creates runs for other `pull_request` workflows when the release PR is
opened or updated with `GITHUB_TOKEN`, but holds those runs for a maintainer with
write access to select **Approve workflows to run**. Repositories that require
those independent checks to start automatically must use a GitHub App
installation token (preferred) or narrowly scoped personal access token for
both the checkout that pushes the release branch and the plan action's
`github-token` input. Treat that credential as a release secret and grant only
the repository permissions used by the plan phase.

## Promotion integrity

The candidate receipt records:

- marketing version and Apple build number;
- opaque App Store Connect app/build IDs;
- source commit and deterministic tracked-file fingerprint;
- IPA SHA-256;
- processing status and upload time;
- assigned TestFlight groups.

Promotion recomputes the fingerprint and queries Apple by the recorded build ID. A mismatch is a hard failure, not a warning.

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability. Follow [`SECURITY.md`](../SECURITY.md).
