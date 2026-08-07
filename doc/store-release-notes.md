# Store release notes

SMF can attach localized customer-facing notes to the exact iOS and Android
versions in a release pull request. Notes are optional, live in Git, and remain
reviewable before release.

## Choose how to create notes

Use the simplest approach that fits your team:

| Approach                                                       | Use it when                                                    | Who writes the text          |
| -------------------------------------------------------------- | -------------------------------------------------------------- | ---------------------------- |
| [Manual](#write-notes-manually)                                | A release owner writes each release                            | A person                     |
| [Deterministic hook](#generate-notes-from-commit-descriptions) | Conventional Commit descriptions are already customer-friendly | Repository code              |
| [AI-assisted hook](#draft-notes-with-ai)                       | Commit descriptions need to be rewritten or translated         | AI drafts; a person approves |

AI drafting is not built into SMF. Your repository-owned `before_create_pr`
hook calls the approved AI provider, validates its response, and writes the
draft through SMF's typed notes helper.

## What SMF publishes

Store release notes are different from SMF's machine-owned changelog and the
GitHub Release body:

| Content             | Source                         | Audience                       |
| ------------------- | ------------------------------ | ------------------------------ |
| Store release notes | `smf/store-release-notes.json` | TestFlight and store customers |
| Changelog           | `smf/changelog.json`           | Release-PR reviewers and SMF   |
| GitHub Release body | Generated from the changelog   | Repository users               |

For iOS, SMF applies the notes to the TestFlight build. When the ship target
submits an App Store version, SMF also applies them as **What's New in This
Version**.

For Android, SMF applies the notes to the testing-track release and to the
destination track selected by `google_play.ship`.

Only notes under the exact platform and marketing version are used. Older
version entries remain as history.

## Understand the notes file

The file lives at:

```text
<flutter-app>/smf/store-release-notes.json
```

Its structure is:

```text
platform -> marketing version -> store locale -> customer-facing text
```

For example:

```json
{
  "ios": {
    "2.5.0": {
      "en-US": "Search is faster, and saved items are easier to organize.",
      "pt-BR": "A busca está mais rápida e ficou mais fácil organizar itens salvos."
    }
  },
  "android": {
    "2.4.0": {
      "en-US": "Search is faster, with smoother back navigation.",
      "pt-BR": "A busca está mais rápida, com uma navegação de retorno mais fluida."
    }
  }
}
```

Use only `ios` and `android` as platform keys. iOS and Android versions are
independent and may differ.

Do not guess the version. SMF calculates it from qualifying Conventional
Commits and displays it in the release pull request. A hook receives that exact
version directly.

Locale keys must be supported by the corresponding store, such as `en-US` or
`pt-BR`. The locale must already exist for the relevant App Store version
before SMF can update it. Google Play accepts BCP-47 language tags.

SMF rejects empty notes and enforces the store limits:

- Google Play: at most 500 characters per locale.
- App Store: at most 4,000 characters per locale.

Keep notes concise because individual stores may enforce narrower rules.

References:

- [Apple platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information)
- [Google Play track release notes](https://developers.google.com/android-publisher/api-ref/rest/v3/edits.tracks)

## Write customer-facing text

Describe the result customers can notice:

```text
Finding nearby jobs is faster, and filters now remain selected.
```

Do not describe implementation work:

```text
Refactored FeedBloc, upgraded dependencies, and fixed SMF-184.
```

For every locale:

- mention only behavior supported by the included changes;
- translate meaning rather than word order;
- omit commit hashes, ticket IDs, package names, and implementation details;
- avoid unverified performance, security, or availability claims;
- use plain text and short sentences; and
- exclude secrets, private issue text, customer data, and unreleased plans.

## Write notes manually

Use this workflow when a release owner writes the notes:

1. Wait for SMF to open or update the release pull request.
2. Copy the exact iOS and Android versions shown in that PR.
3. Add those version entries to `smf/store-release-notes.json` on the target
   branch through a normal reviewed pull request.
4. Merge the notes PR.
5. Let SMF refresh the existing release pull request.
6. Review the notes displayed by the release candidate before approving the release.

Finish the notes before allowing release candidate creation to start. With the CLI,
wait to run `smf release --phase release-candidate`. With GitHub Actions, use
the app's protected environment to hold release candidate jobs for approval. If that
pause is not part of your workflow, use a hook so the notes are present when
SMF first creates the release pull request.

Do not edit the SMF release branch by hand. Adding the notes through the target
branch keeps the source of truth and release history reviewable.

## Generate notes from commit descriptions

Use a deterministic `before_create_pr` hook when Conventional Commit
descriptions are already suitable for customers.

Add the hook SDK from the Flutter app:

```bash
dart pub add --dev smf_hooks
```

Create `smf/hooks/before_create_pr.dart`:

```dart
import 'package:smf_hooks/smf_hooks.dart';

final class WriteStoreReleaseNotes extends SmfHook {
  @override
  Future<void> run(SmfBeforeCreatePrContext context) async {
    final ios = context.release.ios;
    if (ios != null) {
      ios.storeReleaseNotes.write(
        locale: 'en-US',
        message: ios.changes
            .map((change) => '- ${change.description}')
            .join('\n'),
      );
    }

    final android = context.release.android;
    if (android != null) {
      android.storeReleaseNotes.write(
        locale: 'en-US',
        message: android.changes
            .map((change) => '- ${change.description}')
            .join('\n'),
      );
    }
  }
}

Future<void> main() => runSmfHook(WriteStoreReleaseNotes());
```

Format, analyze, and commit the hook:

```bash
dart format smf/hooks
dart analyze smf/hooks
git add pubspec.yaml pubspec.lock smf/hooks/before_create_pr.dart
git commit -m "chore: generate store release notes"
```

SMF runs the hook after calculating the next versions. The typed
`storeReleaseNotes.write(...)` helper selects the correct platform and version,
checks the platform's character limit, and preserves existing versions and
locales.

Do not use this transformation unchanged when commit descriptions contain
developer jargon. Write better commit descriptions or use AI only as the
reviewed drafting step described next.

Read [Typed hooks](hooks.md) for the complete hook lifecycle and recovery
rules.

## Draft notes with AI

The AI integration belongs to your hook, not to SMF:

```text
SMF calculates the platform version and included changes
                         |
                         v
before_create_pr sends those changes to your AI provider
                         |
                         v
the hook validates the draft and writes it with the typed helper
                         |
                         v
SMF commits the draft to the release pull request
                         |
                         v
people review the text and test the release candidate
```

The model drafts text only. It does not choose versions, select platforms,
publish to a store, approve a release candidate, or merge the release pull request.

### 1. Decide the input and output

For each non-null platform release, the hook receives:

- `nextVersion`;
- the Conventional Commit type, scope, description, and body; and
- a typed writer already bound to that platform and version.

The hook does not receive commit hashes, issue contents, customer data, or SMF's
Apple, Google Play, GitHub, and signing credentials.

Send only the change descriptions needed to write the notes. Ask the provider
to return a locale-to-message JSON object:

```json
{
  "en-US": "Selected search filters now stay in place.",
  "pt-BR": "Os filtros de busca selecionados agora permanecem ativos."
}
```

Do not ask the model to return a platform or version. The typed SMF context
already provides both, so the model cannot accidentally write notes under an
invented release.

### 2. Use a bounded prompt

Keep the reviewed prompt in repository code. For example:

```text
Draft customer-facing mobile store release notes from the supplied change
descriptions.

Return JSON only as an object whose keys are the requested store locales and
whose values are plain-text release notes.

Describe only customer-visible outcomes supported by the input. Do not invent
features, fixes, measurements, security claims, or availability. Omit commit
hashes, ticket IDs, code names, and release-process details.

Keep every locale at or below the supplied character limit. If the changes do
not support a truthful customer-facing note, return an empty object.
```

Use structured output or a JSON-schema response when the provider supports it.
Still decode and validate the complete response locally before changing the
notes file.

### 3. Give only the pull-request phase access to the AI token

Create a dedicated, least-privilege provider or gateway token. Do not reuse a
store, signing, or broad organization credential.

For a CLI-operated release on macOS or Linux:

```bash
export RELEASE_NOTES_AI_TOKEN="<token>"
smf release --phase pull-request
```

In Windows PowerShell:

```powershell
$env:RELEASE_NOTES_AI_TOKEN = "<token>"
smf release --phase pull-request
```

The hook reads the configured value from its typed context:

```dart
final token = context.secrets['RELEASE_NOTES_AI_TOKEN']!;
```

SMF does not load `.env` files. Declare the custom token for the hook phase in
`smf/config.yaml`:

```yaml
hooks:
  before_create_pr:
    secrets:
      - RELEASE_NOTES_AI_TOKEN
```

Run `smf init --github-actions`, then save `RELEASE_NOTES_AI_TOKEN` as a
repository Actions secret. SMF removes its own Apple, Google Play, GitHub, and
signing credentials before the hook runs. See [Typed hooks](hooks.md) for local
and external-provider injection.

### 4. Validate before writing

Your hook should:

1. call the provider before changing `store-release-notes.json`;
2. reject non-JSON responses, unexpected locales, non-string values, and empty
   messages;
3. validate every message against
   `release.storeReleaseNotes.characterLimit`;
4. write only after the complete response is valid; and
5. throw when the provider or validation fails so SMF stops the release.

After validation, write each locale:

```dart
for (final entry in draft.entries) {
  release.storeReleaseNotes.write(
    locale: entry.key,
    message: entry.value,
  );
}
```

Never print the token. Avoid logging prompts or responses when change
descriptions may contain private information.

### 5. Review the result

The AI output is a draft. In the SMF release pull request, verify:

- every statement is supported by an included change;
- translations have the same meaning;
- the correct platform versions and locales were updated;
- no internal information appears; and
- the release candidate displays the expected text.

Do not approve the release candidate until the notes are correct. Teams that do not
allow network access from repository hooks can generate the draft in a
separate trusted workflow and submit it through the
[manual notes process](#write-notes-manually).

## Validate and recover

Run:

```bash
smf validate
git diff -- smf/store-release-notes.json
```

If validation fails:

1. confirm the file contains valid JSON;
2. keep only `ios` and `android` as root keys;
3. confirm every version contains a locale-to-string object;
4. remove empty notes;
5. shorten Android notes over 500 characters and iOS notes over 4,000; and
6. rerun `smf validate`.

If a store rejects a locale, add that localization in the store or remove it
from the version entry. If displayed notes are wrong, stop the release, correct
the file on the target branch, and let SMF update the release pull request.
Never edit a release candidate receipt to force the change.

Continue with
[End-to-end release automation](end-to-end-automation.md) when the notes
process is ready.
