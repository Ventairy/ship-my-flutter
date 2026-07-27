# CLI reference

Install:

```bash
dart install smf_cli
```

The package exposes one executable:

```bash
smf <command> [options]
```

Every command supports `--help`. Success prints one JSON value to stdout.
Diagnostics use stderr and include a stable error code:

```text
smf validate [INVALID_CONFIG]: platforms.android.package_name is invalid.
```

Secrets are accepted through environment values or documented file paths,
never command-line secret values.

## Commands

| Command | Purpose |
| --- | --- |
| `smf init` | Create configuration and generated workflow |
| `smf validate` | Validate config/repository invariants |
| `smf plan` | Preview every enabled pending platform plan |
| `smf open-pr` | Open/update the shared release PR |
| `smf release` | Alias for `open-pr` |
| `smf candidate` | Create one selected platform candidate |
| `smf testflight` | iOS candidate alias |
| `smf internal-testing` | Android candidate alias |
| `smf promote` | Ship one selected exact candidate |
| `smf app-store` | iOS promotion alias |
| `smf google-play` | Android promotion alias |

Standard users normally run `init`, `validate`, and `plan`; GitHub Actions runs
the release lifecycle.

## Common options

- `--smf-path <path>` selects a forward directory named `smf`, for example
  `apps/mobile/smf`.
- `--repository <owner/name>` supplies GitHub identity when environment context
  is absent.
- `--github-token-file <path>` reads a GitHub token without placing it in
  process arguments.
- `--platform ios|android` is required by candidate/promotion commands when
  both platforms are enabled.

The CLI also reads `GITHUB_REPOSITORY`, `SMF_GITHUB_TOKEN`, or `GITHUB_TOKEN`.
Do not set both a token environment value and `--github-token-file`.

## `smf init`

```bash
smf init \
  [--current-version X.Y.Z] \
  [--bundle-id com.example.app] \
  [--package-name com.example.app] \
  [--smf-path path/to/smf] \
  [--force] \
  [--workflow-only]
```

- Run from the Flutter app directory.
- Enables only platform directories that exist.
- Reads a stable `pubspec.yaml` version when `--current-version` is omitted.
- `--force` replaces existing initialization files.
- `--workflow-only` refreshes the generated workflow without touching
  configuration/release state.

Example output:

```json
{
  "smfPath": "/repo/apps/mobile/smf",
  "initialized": true
}
```

## `smf validate`

```bash
smf validate [--smf-path apps/mobile/smf]
```

Checks configuration, repository layout, app-contained paths, manifests,
changelogs, notes, and supported invariants without changing files.

```json
{
  "valid": true
}
```

## `smf plan`

```bash
smf plan [--smf-path apps/mobile/smf]
```

Read-only. Returns a JSON list because iOS and Android can both have plans:

```json
[
  {
    "platform": "ios",
    "currentVersion": "1.4.0",
    "nextVersion": "1.5.0"
  },
  {
    "platform": "android",
    "currentVersion": "1.3.2",
    "nextVersion": "1.4.0"
  }
]
```

An empty list means no enabled platform has a release-worthy change.

## `smf open-pr` / `smf release`

```bash
smf open-pr \
  [--smf-path apps/mobile/smf] \
  [--repository owner/repo] \
  [--github-token-file /secure/token]
```

Runs on the target branch. It creates/updates one `smf/release` branch and PR
containing all pending platform plans.

Possible outputs:

```json
{
  "phase": "release-candidate",
  "releases": [
    {"platform": "ios", "version": "1.5.0"},
    {"platform": "android", "version": "1.4.0"}
  ],
  "branch": "smf/release",
  "pullRequestNumber": 42
}
```

```json
{"phase": "noop"}
```

After the PR is merged, planning on the target branch can return:

```json
{
  "phase": "ship",
  "releases": [
    {"platform": "android", "version": "1.4.0"}
  ]
}
```

## Candidate commands

Generic:

```bash
smf candidate --platform ios
smf candidate --platform android
```

Aliases:

```bash
smf testflight
smf internal-testing
```

Options:

- GitHub/common options above;
- `--no-commit-receipt` for controlled local diagnostics only.

Candidate creation must run on `smf/release` with a clean checkout. Normal
release candidates should commit/push receipts; do not use
`--no-commit-receipt` as a production shortcut.

iOS output:

```json
{
  "platform": "ios",
  "version": "1.5.0",
  "artifactId": "123456789",
  "buildNumber": "17"
}
```

Android output:

```json
{
  "platform": "android",
  "version": "1.4.0",
  "artifactId": "208",
  "buildNumber": "208"
}
```

### Candidate credentials

iOS:

```text
SMF_APP_STORE_CONNECT_KEY_ID
SMF_APP_STORE_CONNECT_ISSUER_ID
SMF_APP_STORE_CONNECT_PRIVATE_KEY_BASE64 or _PATH
SMF_IOS_CERTIFICATE_BASE64 or _PATH
SMF_IOS_CERTIFICATE_PASSWORD
SMF_IOS_PROVISIONING_PROFILES_BASE64 or _PATH
```

Android:

```text
SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64 or _PATH
SMF_ANDROID_KEYSTORE_BASE64 or _PATH
SMF_ANDROID_KEY_ALIAS
SMF_ANDROID_KEYSTORE_PASSWORD
SMF_ANDROID_KEY_PASSWORD
```

The Android alias/passwords are environment-only. File variants apply to the
service-account JSON and keystore.

## Promotion commands

Generic:

```bash
smf promote --platform ios
smf promote --platform android
```

Aliases:

```bash
smf app-store
smf google-play
```

Promotion runs on the configured target branch after the release PR merge. It
requires GitHub credentials and the platform store API credential:

- iOS: App Store Connect API values;
- Android: Google Play service-account JSON.

It does not require signing credentials because it does not rebuild.

Example:

```json
{
  "platform": "android",
  "version": "1.4.0",
  "tag": "android-v1.4.0",
  "artifactId": "208",
  "buildNumber": "208",
  "testingTrack": "internal",
  "productionTrack": "production",
  "githubReleaseUrl": "https://github.com/owner/repo/releases/tag/android-v1.4.0"
}
```

## Exit codes

- `0`: successful operation, including `noop`.
- `64`: invalid command/options/help-required usage.
- `1`: validated SMF, filesystem, store, GitHub, build, or credential failure.

Automation should parse stdout JSON only after exit code `0`. Do not scrape
diagnostic prose; use the stable error code.
