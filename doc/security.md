# Security guide

SMF handles App Store Connect credentials and Apple signing material. This
guide explains what users must protect, which project code is trusted, and how
to respond to exposure.

## Credentials used by the workflow

The generated workflow reads six GitHub Actions repository secrets:

| Secret | Contains |
| --- | --- |
| `APP_STORE_CONNECT_KEY_ID` | App Store Connect key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect issuer ID |
| `APP_STORE_CONNECT_PRIVATE_KEY_BASE64` | Base64 `.p8` private key |
| `IOS_CERTIFICATE_BASE64` | Base64 Apple Distribution `.p12` |
| `IOS_CERTIFICATE_PASSWORD` | `.p12` export password |
| `IOS_PROVISIONING_PROFILES_BASE64` | One profile or a bundle-ID JSON map |

Base64 is encoding, not encryption. Protect an encoded credential exactly like
the original file.

Follow [Apple setup](apple-bootstrap.md#9-add-the-six-github-actions-secrets)
for creation and encoding instructions.

## How SMF handles secrets

- Credentials enter the standard workflow only through Action inputs backed by
  GitHub secrets.
- Signing files are created outside the repository with restrictive
  permissions.
- iOS signing uses a temporary keychain.
- Credentials are removed from the environment before project hooks, Flutter,
  Xcode, and Git commands run.
- Temporary API-key, certificate, keychain, profile, and export files are
  removed after the candidate job.
- A provisioning profile that existed before SMF started is not deleted.
- Error diagnostics omit command arguments that could contain credentials.
- Generated checkouts do not leave a Git credential available to the Flutter
  build.

Do not promote a credential to a job-level environment variable. GitHub would
then expose it to setup and project steps that do not need it.

## Trusted project code

The following repository content can execute during a release:

- `.github/workflows/smf.yml`;
- `smf/hooks/before_create_pr.dart`;
- `smf/hooks/before_build.dart`;
- a custom `build_command`;
- Flutter build scripts, plugins, and project dependencies; and
- scripts called by any of the above.

Treat changes to those files like changes to production deployment code.
Require review from a trusted release owner before allowing them to run with
release credentials.

Never run the candidate phase with secrets for untrusted fork code. Pull
requests from forks should use checks that do not receive Apple credentials.

For self-hosted infrastructure, prefer a dedicated ephemeral macOS runner.
Assume a persistent runner can retain project or tool state unless the runner
is deliberately reset between jobs.

## GitHub permissions

The generated workflow grants each phase only the repository permissions it
uses:

- pull request: write contents, pull requests, and issues;
- release candidate: write contents so it can commit the candidate receipt;
- ship: write contents so it can create the platform tag and GitHub Release.

The repository or organization must allow GitHub Actions to create pull
requests:

1. Open **Settings → Actions → General**.
2. Find **Workflow permissions**.
3. Enable **Allow GitHub Actions to create and approve pull requests**.

The default repository `GITHUB_TOKEN` is sufficient for SMF when that setting
is enabled.

GitHub does not trigger new workflow runs for events created by the default
`GITHUB_TOKEN`. SMF's candidate still runs in the workflow that opened the
release PR, but the repository's unrelated `pull_request` workflows might not.

When those independent PR checks are required, pass a GitHub App installation
token (preferred) or a narrowly scoped fine-grained personal access token to
the Action's `github-token` input. Limit it to the one repository and grant
only:

- Contents: read and write;
- Pull requests: read and write; and
- Issues: read and write.

Store the alternative token as a GitHub secret.

For a fine-grained personal access token, use a repository secret such as
`SMF_GITHUB_TOKEN`, then add this input to every SMF Action step in the
generated workflow:

```yaml
github-token: ${{ secrets.SMF_GITHUB_TOKEN }}
```

For a GitHub App, generate a short-lived installation token in each job and
pass that step's output instead. Supplying the token only to `pull-request`
changes PR-event behavior but leaves candidate receipt pushes and the GitHub
Release on the default token; use it consistently when repository policy
requires the alternative identity for all writes.

`smf init --workflow-only` regenerates the workflow and can replace manual
token edits. Review the diff and reapply intentional customization after an
upgrade.

## Action version pinning

After the stable Action is published, the generated workflow references:

```yaml
- uses: Ventairy/smf-action@v1
```

`v1` receives compatible stable updates. Repositories that require review of
every Action update can replace it with a reviewed full commit SHA. Apply the
same pin consistently to every SMF phase and review upgrades deliberately.

Do not copy a shortened workflow fragment from documentation. `smf init`
generates the complete supported workflow, including permissions, checkout,
toolchain setup, runner selection, secrets, and phase routing.

## Candidate integrity

The candidate receipt records the source, app identity, marketing version,
Apple build ID/number, IPA hash, processing state, and assigned TestFlight
groups.

Before delivery, SMF verifies:

- the receipt still matches the tracked app/build inputs;
- the current bundle ID resolves to the same App Store Connect app;
- the recorded build belongs to that app and marketing version; and
- Apple still reports the build as valid.

Tracked source changes after candidate creation require a new candidate.
Ignored or untracked files are outside this integrity boundary and must not be
required build inputs.

An identity or fingerprint mismatch is a hard stop. Never edit the receipt or
bypass the check; use the [recovery guide](operations.md#fingerprint-or-app-identity-mismatch).

## If a credential is exposed

Removing text from a file or force-pushing Git does not guarantee removal from
GitHub, clones, caches, logs, or notifications.

Respond immediately:

1. Stop release workflows that could use the credential.
2. Revoke the exposed App Store Connect API key or Apple signing certificate.
3. Create a replacement.
4. Regenerate every provisioning profile tied to a replaced certificate.
5. Replace the affected GitHub secrets.
6. Inspect workflow and audit logs for unexpected use.
7. Produce and test a new candidate when signing assets or build identity
   changed.

Do not paste the exposed value into an issue while asking for help.

## Reporting a vulnerability

Do not open a public issue for a suspected SMF vulnerability. Follow
[`SECURITY.md`](../SECURITY.md) to report it privately.
