# Typed hooks

Hooks let your Flutter repository prepare deterministic project files at
specific points during an SMF release. Most applications do not need them. Use
a hook only when the standard workflow must generate or validate something
specific to your project.

## Before you start

You need:

- a Flutter app already initialized with `smf init`;
- Dart 3.10 or newer in the app;
- permission to change the app's `pubspec.yaml`;
- the hook committed and pushed to the remote target branch before SMF runs;
  and
- an understanding that hook code runs as trusted repository code in the
  release workflow.

Hooks do not receive SMF's Apple, Google Play, signing, or GitHub credentials.
They receive only project secrets explicitly configured for their phase. A
hook may create an ignored build input containing a secret, but must never put
that value in a tracked or unignored file.

## 1. Add the hook SDK

Run this from the Flutter app directory:

```bash
dart pub add --dev smf_hooks
```

Expected result: `smf_hooks` appears under `dev_dependencies`, and the app's
lockfile is updated. Applications without hooks do not add this package.

## 2. Choose a phase

SMF recognizes exactly these committed files:

| File                              | When it runs                                                                    | Typed context              |
| --------------------------------- | ------------------------------------------------------------------------------- | -------------------------- |
| `smf/hooks/before_create_pr.dart` | After SMF prepares the platform plans and before it pushes the app's release PR | `SmfBeforeCreatePrContext` |
| `smf/hooks/before_build.dart`     | Once for each platform release candidate, before fingerprinting and building            | `SmfBeforeBuildContext`    |

Use `before_create_pr` for files shared by the release PR, such as generated
store notes. Use `before_build` only for platform-specific inputs that must be
created immediately before that platform is built.

The hook file must be a regular committed file. SMF rejects an untracked hook
or a symbolic link.

## 3. Configure hook secrets

Declare each required secret environment name under the phase that consumes
it:

```yaml
hooks:
  before_create_pr:
    secrets:
      - RELEASE_NOTES_API_TOKEN
  before_build:
    secrets:
      - GOOGLE_MAPS_API_KEY
```

Names must use uppercase letters, numbers, and underscores. SMF reserves its
own names and GitHub/runner names. Every declared value is required when that
phase runs and must contain at least eight characters.

Read a configured value from the typed hook context:

```dart
final apiKey = context.secrets['GOOGLE_MAPS_API_KEY']!;
```

`context.secrets` is immutable and contains only names configured for the
current phase. It does not expose ordinary environment variables or SMF's own
credentials.

Regenerate the app-scoped workflow after changing the configuration:

```bash
smf init --github-actions
```

The generated workflow maps each name from GitHub Actions secrets only onto
the matching SMF step. Store `before_create_pr` values as repository secrets.
Store `before_build` values in the existing `smf-<app-id>` GitHub Environment;
an Environment secret overrides the same repository secret.

The runtime contract is provider-neutral. If another step fetches values from
Vault, Infisical, or another secret manager, replace the generated mapping with
that step's output while keeping the configured environment name. Regenerating
the workflow overwrites this customization, so review and reapply it afterward.

For a CLI run, export the same name before the phase that invokes the hook.
SMF does not load `.env` files:

```bash
export GOOGLE_MAPS_API_KEY="<value>"
smf release --phase release-candidate --platform android
unset GOOGLE_MAPS_API_KEY
```

In PowerShell:

```powershell
$env:GOOGLE_MAPS_API_KEY = "<value>"
smf release --phase release-candidate --platform android
Remove-Item Env:GOOGLE_MAPS_API_KEY
```

For a non-sensitive value, map the matching repository or Environment Actions
variable onto the hook step manually. The generated workflow manages only the
secret names declared under `hooks`.

SMF strips its GitHub, store, and signing credential variables, plus generic
GitHub token aliases, before starting repository-owned commands. It redacts
configured hook secret values from captured output and failures. The hook still
must not print secrets or expose transformed values that exact redaction cannot
recognize.

## 4. Create a hook

This `smf/hooks/before_create_pr.dart` example writes deterministic store notes
that SMF commits to the release PR:

```dart
import 'package:smf_hooks/smf_hooks.dart';

final class WriteStoreReleaseNotes extends SmfHook {
  @override
  Future<void> run(SmfBeforeCreatePrContext context) async {
    final ios = context.release.ios;

    if (ios != null) {
      ios.storeReleaseNotes.write(
        locale: 'pt-BR',
        message: ios.changes
            .map((change) => '- ${change.description}')
            .join('\n'),
      );
    }

    final android = context.release.android;

    if (android != null) {
      android.storeReleaseNotes.write(
        locale: 'pt-BR',
        message: android.changes
            .map((change) => '- ${change.description}')
            .join('\n'),
      );
    }
  }
}

Future<void> main() => runSmfHook(WriteStoreReleaseNotes());
```

`context.release.ios` and `context.release.android` are nullable because either
platform may be absent from a release PR. When present, each exposes only the
next version, the change type, scope, description and body, plus
`storeReleaseNotes.write(...)`. SMF's machine-owned changelog remains an
internal release record.

For a hook that runs before each build, create `smf/hooks/before_build.dart`:

```dart
import 'package:smf_hooks/smf_hooks.dart';

final class PreparePlatformBuild extends SmfHook {
  @override
  Future<void> run(SmfBeforeBuildContext context) async {
    await context.runCommand(
      'dart run tool/prepare_build.dart',
      shouldRunFromRepositoryRoot: true,
    );
  }
}

Future<void> main() => runSmfHook(PreparePlatformBuild());
```

`runCommand(...)` streams command output to the hook log and throws when the
command exits unsuccessfully. It runs from the hook process's current directory
by default. Pass `shouldRunFromRepositoryRoot: true` to run from the Git
repository root.

### Google Maps native files

Commit ignore rules for the local native secret files before creating them:

```gitignore
android/secrets.properties
ios/Flutter/Secrets.xcconfig
```

Then a `before_build` hook can prepare both platform builds from the configured
`GOOGLE_MAPS_API_KEY`:

```dart
import 'dart:io';

import 'package:smf_hooks/smf_hooks.dart';

final class PrepareGoogleMaps extends SmfHook {
  @override
  Future<void> run(SmfBeforeBuildContext context) async {
    final apiKey = context.secrets['GOOGLE_MAPS_API_KEY']!;

    await File('android/secrets.properties').writeAsString(
      'GOOGLE_MAPS_API_KEY=$apiKey\n',
    );
    await File('ios/Flutter/Secrets.xcconfig').writeAsString(
      'GOOGLE_MAPS_API_KEY=$apiKey\n',
    );
  }
}

Future<void> main() => runSmfHook(PrepareGoogleMaps());
```

Keep only the paths relevant to the platforms in the app. Ignored files remain
available to the current build but are not staged or included in SMF's source
fingerprint.

## 5. Understand hook commits

SMF stages and commits tracked or unignored files left by a successful hook:

- `before_create_pr` changes enter the app's release PR;
- `before_build` changes enter the release branch before the source
  fingerprint and release candidate build.

Hooks do not configure commit behavior. If a hook produces no changes, the
commit step is a no-op.

When configured secrets are present, SMF scans every tracked modification and
unignored new file, filename, and symbolic-link target before the commit. If an
exact secret value appears, the phase fails with `HOOK_SECRET_LEAK`. Ignored
files are excluded intentionally. Encoding or otherwise transforming a secret
can evade exact matching and remains prohibited.

## 6. Verify before pushing

Format and analyze the hook from the Flutter app:

```bash
dart format smf/hooks
dart analyze smf/hooks
git status --short
```

Review every generated file. Run the hook through the SMF workflow only after
committing it:

```bash
git add pubspec.yaml pubspec.lock smf/hooks
git commit -m "chore: add smf release hook"
git push
```

That commit is not release-worthy by itself. The next qualifying Conventional
Commit runs the hook. In the Actions log, verify the hook completed and inspect
its files in `smf/<app-id>/release` before testing a release candidate.

Do not run the hook file directly with `dart run`; `runSmfHook` needs the
context files that SMF supplies during the workflow.

## Failure and recovery

If the hook fails, SMF stops before the next release operation.

1. Read the hook's error and stable SMF error code in the Actions log.
2. Reproduce ordinary Dart errors with `dart analyze smf/hooks`.
3. Make the output deterministic and idempotent: retrying the same release
   must produce the same content.
4. Ensure output paths stay inside the repository and do not contain secrets.
5. Commit and push the fix to the target branch, then rerun the workflow.

If the hook is no longer needed, delete its file and remove `smf_hooks` from
`dev_dependencies` when no other hook imports it. Commit those changes before
rerunning the release workflow.

For a release branch already containing unwanted hook output, follow
[Retry and recovery](operations.md#retry-and-recovery) instead of editing
machine-owned SMF manifests or release candidate receipts by hand.

Next, review [Configuration](configuration.md) for store and build settings and
[Security](security.md) for trusted project code and credential handling.
