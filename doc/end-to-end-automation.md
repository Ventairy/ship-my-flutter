# End-to-end release automation

This guide turns an already initialized and proven SMF installation into the
normal release path from a qualifying code change to public store delivery.
It does not repeat account, credential, signing, tester, or store-listing
setup.

GitHub Actions is an automation wrapper, not a runtime requirement for SMF.
The generated jobs invoke the CLI's release planning, candidate creation, and
ship operations with runner-specific platform selection. The equivalent manual
flow is documented in [Run a release from the CLI](cli.md#run-a-release-from-the-cli).

Use it only after:

- `smf validate` succeeds;
- the generated GitHub Actions workflow is committed;
- every enabled platform has completed one candidate-only release;
- the exact TestFlight or Google Play candidate was installed and tested;
- store metadata, policy declarations, agreements, and review information are
  complete; and
- the configured automation identities already have the required permissions.

For missing prerequisites, return to
[Getting Started](getting-started.md), [Apple setup](apple-bootstrap.md), or
[Android setup](android-bootstrap.md).

## What end-to-end means

SMF automates the release machinery around one explicit approval point:

```text
qualifying change reaches target branch
                 |
                 v
       SMF opens/updates release PR
                 |
                 v
        exact store candidates built
                 |
                 v
       people test, approve, and merge
                 |
                 v
       SMF ships without rebuilding
                 |
                 v
          store review and approval
                 |
                 v
          automatic public release
```

SMF does not auto-merge the release PR, replace release-owner approval, bypass
App Review or Google Play review, or guarantee when a store will approve a
submission. “Automatic production” means no additional release command or
artifact rebuild is required after the approved release PR is merged and the
store approves the submission.

## 1. Confirm what starts a release

Open `smf/config.yaml` and verify:

```yaml
schema_version: 1
app_id: my_app
target_branch: main
```

A release starts when a qualifying Conventional Commit reaches
`target_branch`:

```text
fix: prevent startup crash
feat(search): add saved filters
feat!: replace the account model
```

For a nested Flutter app, commits must change that app or one of its configured
shared paths:

```yaml
release_trigger_paths:
  - packages/shared_models/**
  - packages/design_system/**
```

Use `fix(ios):` or `fix(android):` when a change should release only one
platform. Unscoped and feature-scoped changes apply to every enabled platform.
The resulting versions remain independent. SMF calculates them automatically
when the change reaches the target branch and records them in the release pull
request.

## 2. Configure the candidate destinations

Keep a real testing destination before production. A production ship target
does not replace candidate testing.

For a common two-platform setup:

```yaml
platforms:
  ios:
    enabled: true
    initial_version: 2.4.0
    bundle_id: com.example.myapp
    app_store:
      release_candidate:
        target: internal-testing
        groups:
          - Internal
        wait_timeout_minutes: 45

  android:
    enabled: true
    initial_version: 2.3.1
    package_name: com.example.myapp
    google_play:
      release_candidate:
        target: internal-testing
```

The named TestFlight groups and Google Play tracks must already exist. SMF
assigns candidates to those destinations; it does not create audiences or add
testers.

## 3. Enable automatic production after merge

Add `ship.target: production` independently for each platform that is ready:

```yaml
platforms:
  ios:
    enabled: true
    initial_version: 2.4.0
    bundle_id: com.example.myapp
    app_store:
      release_candidate:
        target: internal-testing
        groups:
          - Internal
        wait_timeout_minutes: 45
      ship:
        target: production

  android:
    enabled: true
    initial_version: 2.3.1
    package_name: com.example.myapp
    google_play:
      release_candidate:
        target: internal-testing
      ship:
        target: production
```

The two production targets have different store effects:

| Platform | After the release PR is merged                                                                                                                  |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| iOS      | SMF attaches the tested build to the App Store version, applies notes, submits it to App Review, and requests automatic release after approval. |
| Android  | SMF moves the tested `versionCode` to production and sends the Play change for review.                                                          |

For Google Play, open Play Console and turn **Managed publishing off** if the
approved production change must publish without a later manual Play Console
action. Managed publishing is an app-wide setting:

- off: Google publishes an approved change automatically;
- on: the approved change waits until a person publishes it; and
- SMF cannot read, change, or bypass the setting through the Developer API.

If the team needs a manual post-review hold, keep Managed publishing on. That is
still automated submission, but it is not automatic public delivery.

Use `submit-for-review` instead of `production` on iOS when App Store approval
must end in **Pending Developer Release** for a person to release manually.

## 4. Configure store release notes

Create and validate localized notes before candidate approval:

```text
<flutter-app>/smf/store-release-notes.json
```

```json
{
  "ios": {
    "2.5.0": {
      "en-US": "Search is faster, and saved items are easier to organize."
    }
  },
  "android": {
    "2.4.0": {
      "en-US": "Search is faster, with smoother back navigation."
    }
  }
}
```

The version keys must equal the versions in the SMF release pull request.
SMF applies the notes to candidates and the configured ship destinations. A
`before_create_pr` hook can generate correctly keyed notes from SMF's internal
release context before candidate creation.

For manual maintenance, deterministic generation from Conventional Commits,
localization, validation, and AI-assisted drafting, follow
[Store release notes](store-release-notes.md).

## 5. Remove unintended GitHub pauses

The generated workflow already runs on pushes and chooses the correct phase:

- target-branch change: open or update the release PR;
- release-branch state: create missing candidates; and
- merged release PR on the target branch: ship pending platforms.

Do not replace it with hand-written Action snippets. If it is missing, recreate
only the workflow from the Flutter app:

```bash
smf init --github-actions
```

Check the GitHub Environment named `smf-<app-id>`. Required reviewers,
deployment-branch restrictions, or wait timers on that environment pause both
candidate and ship jobs. Keep those controls when they are intentional. Remove
only an unintended environment pause; the release PR review should remain the
explicit production approval.

Protect `target_branch` with the team's required checks and review policy.
Also confirm repository or organization settings allow GitHub Actions to create
pull requests. If the SMF-created PR must trigger independent
`pull_request` workflows, use the approved GitHub App or fine-grained token
setup described in [GitHub permissions](security.md#github-permissions).

## 6. Validate the production configuration

Run from the Flutter app:

```bash
smf validate
git diff -- smf/config.yaml smf/store-release-notes.json
```

Open a normal configuration PR. Review:

1. only intended platforms gained a production ship target;
2. iOS uses `production`, not `submit-for-review`, when automatic release is
   intended;
3. Android Managed publishing matches the desired post-approval behavior;
4. store-note generation uses the versions supplied by SMF's release context;
5. no store contains an unfinished release that SMF would need to replace; and
6. no signing, service-account, API-key, or password value entered Git.

Merge the configuration PR before the application change that should use this
behavior, or include both changes in the same normal PR.

## 7. Run the normal release path

### A. Land a release-worthy application change

Merge a normal code PR into `target_branch` with an accurate Conventional
Commit title. The SMF workflow opens or refreshes
`smf/<app-id>/release`.

### B. Wait for candidates

For every planned platform, require:

- `release-candidate (<platform>)` succeeded;
- the candidate receipt exists under `smf/candidates/`;
- the receipt matches the version and artifact shown by the store;
- the exact artifact was installed from its testing destination;
- the release test passed; and
- localized notes are correct.

Do not enable auto-merge on the release PR in a way that can merge before those
checks and the release-owner approval are complete.

### C. Merge the release PR

Merge using a strategy that preserves every release-PR file, including
candidate receipts. The push to `target_branch` starts the generated workflow
again. It recognizes the pending merged releases and runs
`ship (<platform>)`.

The ship jobs:

1. create an isolated checkout of the remote `target_branch`;
2. load the committed manifest and receipt from that checkout;
3. query remote release tags directly;
4. revalidate source, identity, and the exact store artifact;
5. apply the configured production target;
6. create `<app-id>/<platform>-v<version>`; and
7. create the platform GitHub Release from the machine-owned changelog.

SMF does not rebuild after merge. The workflow checkout and any local branch,
manifest, receipt, or tag cache do not decide what ships.

### D. Let the stores complete review

The GitHub ship job proves that SMF submitted the exact approved artifact. It
does not mean the store has approved or published it.

Confirm:

| Platform | Expected progression                                                                        |
| -------- | ------------------------------------------------------------------------------------------- |
| iOS      | App Review submission -> approval -> automatic App Store release                            |
| Android  | Production change sent for review -> approval -> publication when Managed publishing is off |

Store policy, account status, agreements, rollout availability, and review
decisions remain external gates.

## 8. Verify every release

After merge, check:

- `ship (ios)` and/or `ship (android)` succeeded;
- the expected platform tag exists;
- the GitHub Release points at the merged target-branch commit;
- App Store Connect or Play Console shows the receipt's exact build;
- every locale shows the approved release notes;
- the store review completed; and
- the public listing serves the new version.

A successful GitHub job is not evidence of final store publication. Keep store
status monitoring in the team's release checklist.

## Safe changes after automation is enabled

The production settings remain independent:

- omit one platform's `ship` section to keep that platform candidate-only;
- use `external-testing` or `submit-for-review` on iOS for a non-production or
  manual-release path;
- use `closed-testing` or `open-testing` on Android instead of production; or
- turn Android Managed publishing on when a manual post-approval hold is
  required.

Changing a candidate or ship target on the target branch refreshes the release
PR. Recheck the receipt and destination before merging.

## Recovery

Do not manually rebuild, invent a receipt, reuse a different store artifact, or
edit machine-owned release state.

For failures:

- candidate or receipt problem: keep the release PR open;
- identity or fingerprint mismatch: stop and repair the tracked source/config;
- App Store or Play rejection: correct the named metadata, policy, permission,
  or store state;
- unfinished Play production release: finish or halt it in Play Console;
- unexpected automatic Play publication: stop further merges and review
  Managed publishing; and
- ship job failure after merge: preserve the receipt and rerun only after the
  reported cause is fixed.

Follow [Release operations and recovery](operations.md#retry-and-recovery) for
the exact recovery path.
