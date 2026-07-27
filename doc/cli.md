# CLI reference

Most users run `smf init` once and let the generated GitHub Actions workflow
operate releases. Use the other commands for read-only previews, local
diagnosis, or a deliberately custom workflow.

## Install

```bash
dart install smf_cli
```

Verify the executable:

```bash
smf --help
```

Normally, run commands from the Flutter app directory:

```bash
smf validate
```

From the repository root, use `--smf-path` for a nested app:

```bash
smf validate --smf-path apps/mobile/smf
```

The path is relative to the current working directory and must point directly
to the app's `smf/` directory. From `apps/mobile`, the equivalent explicit path
is `--smf-path smf`.
Operations that inspect history need a full Git checkout with tags.

## Output contract

On operational success, every command writes exactly one JSON value to stdout.
Help requests write plain text. Diagnostics and errors go to stderr. This
makes commands safe to compose in scripts without mixing logs into the result.

Exit status `0` means success, `64` means invalid command usage, and `1` means
SMF could not complete a valid operation. Operational errors include a stable
uppercase code on stderr, for example:

```text
smf validate [INVALID_CONFIG]: platforms.ios.bundle_id is required.
```

Run any command with `--help` to see its current options:

```bash
smf init --help
```

## Commands

| Command | Where to run | Credentials | Result and side effects |
| --- | --- | --- | --- |
| `smf init` | Flutter app; any OS | None | Creates `smf/config.yaml` and the repository workflow |
| `smf validate` | Any branch; any OS | None | Read-only configuration and repository checks |
| `smf plan` | Normally the target branch; any OS | None | Read-only next-version and changelog preview |
| `smf open-pr` | Target branch; clean tree | GitHub | Creates or updates the release branch and PR |
| `smf candidate` | Release branch; clean tree; macOS | Apple signing/API; optionally GitHub | Builds, uploads, waits for Apple, writes the receipt, and by default commits and pushes it |
| `smf promote` | Target branch; clean tree | Apple API and GitHub | Verifies the candidate, applies delivery mode, and creates the GitHub Release |

Lifecycle aliases are available:

| Primary command | Alias |
| --- | --- |
| `smf open-pr` | `smf release` |
| `smf candidate` | `smf testflight` |
| `smf promote` | `smf app-store` |

Aliases accept the same options and produce the same JSON as their primary
commands.

## Options

All commands support `--help`. These are the automation-facing options:

| Command | Options |
| --- | --- |
| `init` | `--smf-path`, `--current-version`, `--bundle-id`, `--force`, `--workflow-only` |
| `validate` | `--smf-path` |
| `plan` | `--smf-path` |
| `open-pr` | `--smf-path`, `--repository`, `--github-token-file` |
| `candidate` | `--smf-path`, `--repository`, `--github-token-file`, `--[no-]commit-receipt` |
| `promote` | `--smf-path`, `--repository`, `--github-token-file` |

`--repository` is the GitHub `owner/name`. The generated workflow supplies
these values automatically; standard users do not need to assemble lifecycle
commands by hand.

## `smf init`

Initialize with an explicit current version and production bundle ID:

```bash
smf init \
  --current-version 0.0.0 \
  --bundle-id com.example.myapp
```

Use `0.0.0` only for a never-released app. Existing apps use the latest
marketing version already shipped on the App Store.

After upgrading the CLI, refresh only the generated workflow:

```bash
smf init --workflow-only
```

This preserves configuration and release state.

`smf init --force` replaces the generated configuration and workflow. Commit or
back up intentional configuration changes first; do not use `--force` for a
routine upgrade.

See [Getting started](getting-started.md) for the complete setup path.

## `smf validate`

Validation is read-only:

```bash
smf validate
```

Run it after configuration changes and before investigating CI. It checks
configuration combinations, paths, repository state, and custom build/hook
requirements without contacting Apple or GitHub.

## `smf plan`

Preview the release calculated from current Git history:

```bash
smf plan
```

Run it from the configured target branch for a release-equivalent preview.
Running it from a feature branch can include that branch's unmerged commits.
The command does not create a branch, PR, build, tag, or release.

## Custom lifecycle commands

The standard generated workflow already calls the lifecycle in the correct
order. When building custom automation, observe these constraints:

- `open-pr` runs from the target branch and changes GitHub/Git state.
- `candidate` runs from the release branch on macOS with the app's
  Flutter/Xcode toolchain installed.
- `promote` runs from the target branch after the approved release PR merges.
- `candidate --no-commit-receipt` writes a receipt without committing it. The
  custom workflow must still place that exact receipt on the release PR before
  merge.

Before `candidate`, install project dependencies and the selected Flutter/FVM
toolchain. With no custom `build_command`, SMF uses:

- `fvm flutter build ipa --release` when the selected app or an ancestor
  declares FVM;
- `flutter build ipa --release` otherwise.

Optional project preparation belongs in
`smf/hooks/before_build.dart`.

## Success JSON examples

Paths, SHAs, IDs, versions, and URLs below are examples. Scripts should read
fields by name and allow future additive fields.

`init`:

```json
{
  "smfPath": "/workspace/app/smf",
  "initialized": true
}
```

`validate`:

```json
{
  "valid": true
}
```

`plan` returns `null` when no qualifying commit exists. Otherwise it returns a
plan such as:

```json
{
  "platform": "ios",
  "currentVersion": "1.2.3",
  "nextVersion": "1.3.0",
  "bump": "minor",
  "baseSha": "1111111111111111111111111111111111111111",
  "headSha": "2222222222222222222222222222222222222222",
  "changes": [
    {
      "sha": "2222222222222222222222222222222222222222",
      "type": "feat",
      "scope": "ios",
      "description": "add saved searches",
      "body": null,
      "breaking": false,
      "bump": "minor",
      "platforms": ["ios"]
    }
  ]
}
```

`open-pr`:

```json
{
  "phase": "release-candidate",
  "platform": "ios",
  "version": "1.3.0",
  "branch": "smf/ios",
  "pullRequestNumber": 42
}
```

`candidate`:

```json
{
  "schemaVersion": 1,
  "platform": "ios",
  "version": "1.3.0",
  "buildNumber": "108",
  "buildId": "123456789",
  "appId": "987654321",
  "bundleId": "com.example.myapp",
  "sourceSha": "3333333333333333333333333333333333333333",
  "sourceFingerprint": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "ipaSha256": "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  "uploadedAt": "2026-07-27T12:00:00.000Z",
  "processingState": "VALID",
  "testflightGroups": ["Internal"]
}
```

`promote`:

```json
{
  "version": "1.3.0",
  "tag": "ios-v1.3.0",
  "buildId": "123456789",
  "githubReleaseUrl": "https://github.com/example/app/releases/tag/ios-v1.3.0"
}
```

When `app_store.mode` submits to Apple, promotion also includes
`appStoreVersionId` and `reviewSubmissionId`.

## Credential environment

GitHub operations read:

```text
GITHUB_REPOSITORY=owner/name
SMF_GITHUB_TOKEN
```

`GITHUB_TOKEN` is accepted as the token fallback. `--repository` and
`--github-token-file` are non-environment alternatives.

Apple operations read:

```text
SMF_APP_STORE_CONNECT_KEY_ID
SMF_APP_STORE_CONNECT_ISSUER_ID
SMF_APP_STORE_CONNECT_PRIVATE_KEY_BASE64
SMF_IOS_CERTIFICATE_BASE64
SMF_IOS_CERTIFICATE_PASSWORD
SMF_IOS_PROVISIONING_PROFILES_BASE64
```

For local credential files, use the matching `_PATH` variables instead of
Base64:

```text
SMF_APP_STORE_CONNECT_PRIVATE_KEY_PATH
SMF_IOS_CERTIFICATE_PATH
SMF_IOS_PROVISIONING_PROFILES_PATH
```

Set exactly one source for each file credential. The `.p12` password remains an
environment secret. `SMF_IOS_PROVISIONING_PROFILES_PATH` accepts one profile
file. Apps with extensions must use
`SMF_IOS_PROVISIONING_PROFILES_BASE64` as the bundle-ID-to-Base64 JSON map
described in [Apple
setup](apple-bootstrap.md#7-create-one-provisioning-profile-per-target).

Raw secret command-line values are intentionally unsupported because shell
history and process listings can expose them. Follow the [security
guide](security.md) when composing custom automation.

## Troubleshooting

- **Command not found:** add Dart's global executable directory to `PATH`.
- **No configuration found:** run from the Flutter app or pass `--smf-path`.
- **Multiple configurations found:** pass the exact app-local `smf/` path.
- **History or tag result is wrong:** fetch the complete history and tags, then
  rerun from the target branch.
- **Dirty-worktree error:** preserve intentional changes, commit or stash them,
  and rerun. Release mutations require an auditable clean state.
- **Credential error:** verify the required variable exists without printing
  its value.

For workflow recovery, see [Release operations and
recovery](operations.md#retry-and-recovery).
