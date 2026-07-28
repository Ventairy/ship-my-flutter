# Security guide

SMF handles store API credentials and signing material. Protect every secret
and encoded value exactly like the original credential.

## Credential setup

The platform setup guides are the canonical source for credential names,
values, phase requirements, and CLI/GitHub Actions instructions:

- [Apple credential variables](apple-bootstrap.md#8-provide-the-five-apple-credential-variables)
- [Android credential variables](android-bootstrap.md#8-provide-the-five-android-credential-variables)

Base64 used for binary signing files is encoding, not encryption.

For CLI operation, export the variables in the shell that starts SMF. For
GitHub Actions, store them as Environment secrets under
`Settings → Environments → smf-<app-id>`. Each initialized app has a separate
environment, so sibling apps can use the same names without sharing
credentials. The generated candidate and ship jobs declare only the selected
app's environment.

The generated cross-platform Action step lists both Apple and Android input
names so one workflow can run either matrix platform. Configure credentials
only for platforms the app enables. At runtime SMF loads the selected
platform's credential set, masks supplied secrets, and removes store/signing
values before repository hooks and project commands.

## How SMF handles secrets

- Standard workflows receive secrets only through Action inputs.
- Sensitive values are masked before execution.
- API/signing values are removed before repository hooks, Git, and unrelated
  project commands.
- Signing files live in private temporary directories outside the repository.
- iOS matches the exact `.p12` certificate and signed bundle IDs against the
  Apple team, resolves profiles through Apple's API, and uses a temporary
  keychain/profile installation.
- Android signs the AAB with the upload keystore, verifies the JAR signature,
  and compares the exact certificate SHA-256.
- Temporary files are removed after the candidate operation.
- Generated automation keeps credentials out of command arguments. The CLI
  accepts direct credential options for local convenience, but process
  arguments may be observable; use `SMF_*` environment variables in
  production.
- Generated checkouts do not leave Git credentials available to builds.
- Receipts contain identifiers and hashes, never private keys/passwords.

Do not move a credential to a job-level environment variable. That would expose
it to setup and project steps that do not need it.

## CLI update checks

Interactive CLI commands request public `smf_cli` package metadata from
pub.dev and print a notice when a newer version exists. The request identifies
the installed SMF version in its user agent but does not include repository or
store credentials. SMF skips this check in CI and in its GitHub Action.

Set `SMF_NO_UPDATE_CHECK=true` to disable advisory checks on another machine.
The explicit `smf upgrade` command still contacts pub.dev and invokes Dart's
package installer.

## Apple key separation

The App Store Connect API key authorizes store operations. The Distribution
certificate/private key signs the IPA. Keep both limited to the correct team
and rotate them according to organization policy.

## Android key separation

With Play App Signing:

- Google holds the app-signing key used for APKs delivered to customers.
- Your team holds the separate upload key used for submitted AABs.

SMF needs only the upload keystore. Do not export or store Google’s app-signing
private key for SMF. If the upload key is compromised, follow Google’s reset
process and replace all four signing secrets.

The Google service account is separate again. Give it app-scoped Play
permissions and no unnecessary Google Cloud or financial access.

## Trusted project code

These repository files can execute during a release:

- `.github/workflows/smf-<app-id>.yml`;
- `smf/hooks/before_create_pr.dart`;
- `smf/hooks/before_build.dart`;
- custom `build_command` values;
- Flutter/Gradle/Xcode build files, plugins, and dependencies; and
- scripts called by any of them.

Treat changes to them as deployment-code changes. Require release-owner review
before they run with release credentials.

Never give store secrets to untrusted fork code. Fork pull requests should run
checks without release credentials.

Prefer ephemeral hosted runners. A persistent self-hosted runner can retain
project/tool state unless it is deliberately reset.

## GitHub permissions

Generated jobs request:

- pull request: Contents, Pull requests, and Issues write;
- candidate: Contents write for pre-upload intents and final receipts;
- ship: Contents write for tags/GitHub Releases.

Enable:

**Settings → Actions → General → Workflow permissions → Allow GitHub Actions to
create and approve pull requests**

The default `GITHUB_TOKEN` is sufficient when repository policy permits those
writes. The Action passes GitHub's token to SMF as `SMF_GITHUB_TOKEN`; the CLI
does not read `GITHUB_TOKEN` directly.

GitHub may not trigger unrelated `pull_request` workflows for a PR created by
the default token. If those checks must run, use a GitHub App installation
token (preferred) or a fine-grained personal access token limited to one
repository with:

- Contents: read/write;
- Pull requests: read/write;
- Issues: read/write.

Pass the alternative token consistently to every SMF Action step when the same
identity must push receipts/create Releases.

For a GitHub App, create an installation token in each job before checkout:

```yaml
- name: Create SMF GitHub App token
  id: smf-token
  uses: actions/create-github-app-token@<reviewed-commit>
  with:
    app-id: ${{ vars.SMF_GITHUB_APP_ID }}
    private-key: ${{ secrets.SMF_GITHUB_APP_PRIVATE_KEY }}
    permission-contents: write
    permission-issues: write
    permission-pull-requests: write
```

Then pass it to that job's SMF step:

```yaml
with:
  github-token: ${{ steps.smf-token.outputs.token }}
```

The pull-request job needs Contents, Issues, and Pull requests write. Candidate
and ship jobs need Contents write. If the installed App lacks one requested
repository permission, token creation fails before SMF runs.

`smf init --github-actions` regenerates the workflow and may replace manual
token edits. Review/reapply intentional customization.

## Action version pinning

The generated workflow uses:

```yaml
- uses: Ventairy/smf-action@v1
```

`v1` receives compatible updates. Repositories requiring immutable review can
replace every SMF Action/sub-action reference with the same audited full commit
SHA. Do not mix versions between:

```text
Ventairy/smf-action
Ventairy/smf-action/resolve-project
Ventairy/smf-action/setup-flutter
```

Regenerate from `smf init`; do not copy an incomplete workflow fragment.

## Candidate integrity

Receipts record:

- platform/version/build number;
- store artifact ID and app identity;
- source SHA/fingerprint;
- artifact SHA-256;
- processing state; and
- testing destinations.

Before shipping, SMF checks:

- merged tracked inputs match;
- bundle/package identity names the same store app;
- the store still has the exact artifact/hash; and
- the testing destination still contains it.

Android promotion reuses the same `versionCode`; Apple promotion reuses the same
App Store Connect build. Identity/fingerprint mismatch is a hard stop.

Ignored/untracked files are outside this boundary and must not be required
build inputs.

## Production controls

- Keep `ship` omitted for both platforms until the candidate-only flow works.
- Before adding either `ship` section, read the exact store effects and
  prerequisites in the [configuration reference](configuration.md#ios).
- Protect the target branch and require human release approval.

GitHub approval does not replace store-account production gates, policy
declarations, metadata, App Review/Play review, or tester requirements.

## If a credential is exposed

Deleting a file or force-pushing does not remove it from clones, caches, logs,
or notifications.

Immediately:

1. Stop release workflows.
2. Identify exactly which secret was exposed.
3. Revoke/delete/reset it at Apple, Google Cloud, Google Play, or GitHub.
4. Create a replacement.
5. Regenerate dependent assets:
   - Apple profiles after replacing a Distribution certificate;
   - GitHub Android signing secrets after resetting the upload key.
6. Replace the value in every active credential source, such as the GitHub
   Environment or the CLI secret manager.
7. Review audit and workflow logs.
8. Produce/test a new candidate if artifact identity or signing material
   changed.

Never paste the exposed value into an issue.

## Reporting a vulnerability

Do not open a public issue for a suspected SMF vulnerability. Follow
[SECURITY.md](../SECURITY.md) for private reporting.
