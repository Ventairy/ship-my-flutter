# Store release notes

SMF can attach localized customer-facing notes to the exact iOS and Android
versions in a release pull request. Notes are optional, live in Git, and are
reviewed before the candidate is shipped.

This guide explains how to write notes manually, generate them deterministically
from Conventional Commits, and use AI to draft them for review.

## What SMF publishes

Store release notes are different from the machine-owned changelog and the
GitHub Release body:

| Content             | Source                         | Audience                       |
| ------------------- | ------------------------------ | ------------------------------ |
| Store release notes | `smf/store-release-notes.json` | TestFlight and store customers |
| Changelog           | `smf/changelog.json`           | Release-PR reviewers and SMF   |
| GitHub Release body | Generated from the changelog   | Repository users               |

For iOS, SMF applies the configured notes to the TestFlight build. When the
ship target submits an App Store version, it also applies them as **What's New
in This Version**.

For Android, SMF applies the notes to the testing-track release and to the
destination track selected by `google_play.ship`.

Only the notes under the exact platform and marketing version are used. Notes
for other versions remain as history and do not affect the release.

## 1. Let SMF select the versions

Users do not choose or calculate the next versions. When a qualifying change
reaches the target branch, SMF calculates each platform's version and records
it in the release pull request. iOS and Android versions are independent and
may differ.

Store notes must use those exact versions. There are two supported ways to
provide them:

- Recommended for automation: a `before_create_pr` hook receives the versions
  and changes directly from SMF and writes the correctly keyed notes file.
- For manually written notes: wait for the SMF release pull request, copy the
  versions shown there, and add the notes through a normal reviewed pull
  request into the target branch. SMF then refreshes the release pull request.

Do not invent a version entry to force a release. If SMF does not open or
update the release pull request, first check that a real `fix:`, `feat:`, or
breaking Conventional Commit changed the app or one of its configured shared
paths.

## 2. Create or update the notes file

Create `<flutter-app>/smf/store-release-notes.json`:

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

The structure is:

```text
platform -> marketing version -> store locale -> customer-facing text
```

Use only `ios` and `android` as platform keys. Locale keys must be identifiers
supported by the corresponding store, such as `en-US` or `pt-BR`. A locale must
already exist for the relevant App Store version before SMF can update it.
Google Play accepts BCP-47 language tags for localized release notes.

SMF requires every note to be nonempty and enforces the corresponding store
limit before any store operation:

- Google Play: at most 500 characters per locale.
- App Store: at most 4,000 characters per locale.

Store rules can become narrower, so keep notes concise and verify every
configured locale in the store.

References:

- [Apple platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information)
- [Google Play track release notes](https://developers.google.com/android-publisher/api-ref/rest/v3/edits.tracks)

## 3. Write useful notes

Release notes should describe customer-visible outcomes, not the release
machinery that produced them.

Prefer:

```text
Finding nearby jobs is faster, and filters now remain selected.
```

Avoid:

```text
Refactored FeedBloc, upgraded dependencies, and fixed SMF-184.
```

For every locale:

- mention only behavior supported by the included changes;
- translate meaning rather than word order;
- omit commit hashes, ticket IDs, package names, and implementation details;
- avoid promises about performance, security, or availability that were not
  verified;
- use plain text and short sentences; and
- do not include secrets, private issue text, customer data, or unreleased
  business plans.

## 4. Validate and review

Run:

```bash
smf validate
git diff -- smf/store-release-notes.json
```

Commit the file through a normal reviewed PR. The SMF release PR then contains
the notes file alongside the selected version and changelog.

Finalize notes before candidate approval whenever possible. If notes change
after a candidate already exists, let SMF refresh the release PR and rerun its
jobs, then verify both the testing destination and the final destination.

Before merging the release PR, check:

1. every version key matches the PR;
2. every locale exists in its store;
3. translations describe the same verified changes;
4. the candidate's displayed notes are correct; and
5. no internal-only information appears in the file.

## 5. Generate deterministic notes from SMF's release context

Use a `before_create_pr` hook when Conventional Commit descriptions are already
written for customers and a predictable transformation is sufficient.

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
    final iosRelease = context.release.ios;

    if (iosRelease != null) {
      iosRelease.storeReleaseNotes.write(
        locale: 'en-US',
        message: iosRelease.changes
            .map((change) => '- ${change.description}')
            .join('\n'),
      );
    }

    final androidRelease = context.release.android;

    if (androidRelease != null) {
      androidRelease.storeReleaseNotes.write(
        locale: 'en-US',
        message: androidRelease.changes
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
git add smf/hooks/before_create_pr.dart
git commit -m "chore: generate store release notes"
```

SMF runs the hook after calculating the next versions and commits its output to
the release branch. The transformation is deterministic: the same release plan
produces the same notes.

`storeReleaseNotes.write(...)` preserves existing platforms, versions, and
locales in `smf/store-release-notes.json`.

Do not use this example unchanged when commit descriptions contain developer
jargon. Improve the transformation or use the AI-assisted workflow below, and
keep release-PR review as the quality gate.

Read [Typed hooks](hooks.md) for the complete hook lifecycle, commit handling,
validation, and recovery rules.

## 6. Draft notes with AI

Use AI as a drafting step before SMF creates the candidate, not as an
unreviewed publishing authority.

SMF intentionally strips its Apple, Google Play, and GitHub credentials from
repository hooks. Project-specific values explicitly supplied to the SMF
Action step remain available because hooks are trusted repository code. An
authenticated `before_create_pr` hook can therefore use a dedicated,
least-privilege AI or gateway token without receiving store signing
credentials.

The safe workflow is:

1. create a provider or gateway credential that can only generate release
   notes;
2. store it in the GitHub Environment used by the pull-request job;
3. pass it through `env` only on the `Ventairy/smf-action` pull-request step;
4. send only the non-null `context.release.ios` and
   `context.release.android` changes to the trusted generator;
5. require structured JSON with locale-to-message text for each platform;
6. write the approved text through each platform's `storeReleaseNotes` helper;
   and
7. review the generated notes in the SMF release pull request before approving
   its candidate.

Each typed platform release contains only the inputs the current generator
needs:

```json
{
  "nextVersion": "2.4.0",
  "changes": [
    {
      "type": "feat",
      "scope": "search",
      "description": "keep selected filters between searches",
      "body": null
    },
    {
      "type": "fix",
      "scope": "ios",
      "description": "preserve scroll position after returning to results",
      "body": null
    }
  ]
}
```

The hook does not receive commit SHAs, bump metadata, repository files, issue
text, or customer data. The iOS and Android objects have the same shape.

### Prompt contract

Give the generator a bounded task:

```text
Draft customer-facing mobile store release notes from the supplied SMF
changelog entries.

Return JSON only. The root keys must be "ios" and/or "android". Each platform
value must contain locale keys and customer-facing text values, for example
{"en-US":"..."}.

Describe only customer-visible outcomes supported by the supplied changes.
Do not invent features, fixes, measurements, security claims, or availability.
Omit commit hashes, ticket IDs, code identifiers, and release-process details.
Use plain text, at most 500 characters per locale. If the changes do not support
a truthful customer-facing note, return no entry for that platform.
```

Use a structured-output or JSON-schema feature when the chosen provider offers
one. Validate the response locally even when the provider guarantees its
shape.

The Action step can expose only the project-specific credential:

```yaml
- uses: Ventairy/smf-action@v1
  env:
    RELEASE_NOTES_AI_TOKEN: ${{ secrets.RELEASE_NOTES_AI_TOKEN }}
  with:
    phase: pull-request
```

The repository-owned hook may call OpenAI's
[Responses API](https://developers.openai.com/api/docs/api-reference/responses/create),
a gateway, or another approved provider, but it must:

- read its API credential from the local secret manager or CI secret;
- never print prompts containing private data or the provider response when
  either may be sensitive;
- use a pinned, reviewed prompt and output schema;
- reject unknown platforms, versions, and locales;
- enforce length limits;
- preserve previously approved version entries;
- fail without changing the notes file when the provider fails; and
- leave the generated JSON for human review.

For the sample plan above, an acceptable generated fragment is:

```json
{
  "android": {
    "2.4.0": {
      "en-US": "Selected search filters now stay in place, and returning to results preserves your scroll position."
    }
  }
}
```

### Automating the AI draft in CI

The authenticated `before_create_pr` hook writes its draft into the SMF release
PR. The release PR remains the human approval boundary:

```text
SMF calculates release -> AI hook drafts notes -> people review and test
```

Teams that do not want network access in repository hooks can instead run
generation in a separate trusted workflow and open a normal notes PR. Never
commit the provider credential, place it in a command argument, or expose it
to candidate and ship steps that do not need it.

## Recovery

If `smf validate` rejects the file:

1. confirm the file is valid JSON;
2. keep only `ios` and `android` at the root;
3. confirm every version contains a locale-to-string object;
4. remove empty notes and shorten Android notes over 500 characters or iOS
   notes over 4,000 characters; and
5. rerun `smf validate`.

If a store rejects a locale, add that localization in the store or remove the
locale from the version entry. If displayed notes are wrong, stop the release,
correct the file on the target branch, and let SMF update the release PR. Never
edit a candidate receipt to force the change.

Continue with [End-to-end release automation](end-to-end-automation.md) when
the notes process is ready.
