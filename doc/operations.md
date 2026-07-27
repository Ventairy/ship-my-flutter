# Release operations and recovery

Use this guide whenever `smf/release` is open, a workflow failed, or a release
must be abandoned.

## Before merging

For every platform listed in the PR:

1. `release-candidate (<platform>)` succeeded;
2. `smf/candidates/<platform>-<version>.json` is committed;
3. the store shows the same `version`, `buildNumber`, and `artifactId`;
4. the exact candidate was installed from the store testing destination;
5. the release test passed;
6. localized notes are correct; and
7. the authorized release owner approved it.

Do not merge if one included platform is unapproved. If it should not be in the
release, fix the target-branch commit/configuration and let SMF update the PR.

## Find the exact candidate

In GitHub:

1. Open the shared release PR.
2. Open the platform receipt under `smf/candidates/`.
3. Record `version`, `buildNumber`, `artifactId`, `artifactSha256`, and
   `testingDestinations`.
4. Confirm the successful job outputs match.

For iOS:

1. Open App Store Connect → Apps → app → TestFlight.
2. Find the receipt’s version/build number.
3. Confirm processing is valid and intended groups have access.
4. Install through TestFlight.

For Android:

1. Open Play Console → app → Testing → the configured track.
2. Find the receipt’s `artifactId` as the Play `versionCode`.
3. Confirm the release is available to the intended tester list.
4. Install through the opt-in link.

Any mismatch is a hard stop.

## Choose what merge will do

Check each platform mode in `smf/config.yaml`.

### iOS `platforms.ios.app_store.mode`

- `upload`: verify only.
- `review`: submit and wait for manual release after Apple approval.
- `auto`: submit and release automatically after Apple approval.

### Android `platforms.android.google_play.mode`

- `upload`: verify only; leave production untouched.
- `review`: move the exact `versionCode` to production review; requires Managed
  Publishing for manual final publication.
- `auto`: move the exact `versionCode` to production and allow normal
  publication after review.

Changing a mode on the target branch refreshes the release PR. Wait for the
candidate jobs and recheck every receipt before merge.

## While the release PR is open

New target-branch commits update the same `smf/release` PR.

- Unscoped/feature commits apply to all enabled platforms.
- `ios` and `android` scopes apply selectively.
- A change scoped away from one platform can still invalidate its candidate if
  it modifies a tracked build input used by that platform.

Candidate jobs are serialized when both platforms release so their receipt
commits do not race.

## Merge strategy

Conventional Commit messages on the target branch determine release versions.
When squashing a feature PR, give the final commit a qualifying title.

Merge commit, squash, and rebase are supported if the target branch receives
all release PR contents, including every candidate receipt. Never discard or
hand-edit machine-owned files while resolving conflicts.

After merge:

- watch `ship (ios)` and/or `ship (android)`;
- confirm `ios-vX.Y.Z` and/or `android-vX.Y.Z`;
- confirm the store status matches the configured mode.

## GitHub checks and branch protection

The default `GITHUB_TOKEN` can update the shared branch and start candidate
jobs in the same workflow. It may not trigger unrelated `pull_request`
workflows for the PR it created.

Use a GitHub App installation token or narrowly scoped fine-grained token when
independent PR checks must trigger. See
[GitHub permissions](security.md#github-permissions).

Protect the target branch with normal reviews/checks. Do not create a ruleset
that prevents the workflow from updating `smf/release`; the candidate receipt
must be committed there.

## Test audiences

SMF assigns artifacts to existing destinations; it does not decide who the
testers are.

- TestFlight group names must already exist and match exactly.
- The Google Play testing track and tester list must already exist/be
  configured.
- An empty iOS group list leaves the build unassigned.
- Google Play `internal` uses the Play testing opt-in URL.

## Retry and recovery

### No release PR opened

1. Open the failed `pull-request` job.
2. Fix the reported config, permission, or commit-message issue on the target
   branch.
3. Run `smf validate`.
4. Push or rerun.

If the result is `noop`, confirm the commit qualifies for at least one enabled
platform and the workflow ran on the configured target branch.

### Candidate build failed

Fix the named source/toolchain/build/signing issue on the target branch. SMF
updates the PR and generates a new candidate when tracked inputs change.

Do not manually invent a receipt.

### Store upload succeeded but receipt commit failed

Confirm:

- the job has `contents: write`;
- `smf/release` still exists;
- repository rules allow the workflow identity to update it; and
- the store artifact still matches the source/identity.

Fix the GitHub permission/ruleset and rerun. SMF can reuse a valid matching
artifact.

### iOS processing or TestFlight failed

- Copy group names exactly from App Store Connect.
- Confirm API-key role and app access.
- Read Apple’s processing/compliance message.
- Fix certificate, profile, entitlement, metadata, or source issues.

A corrected IPA needs a new build number/candidate.

### Google Play authentication or permission failed

Confirm:

- the Android Publisher API is enabled in the service account’s Cloud project;
- the JSON is for the invited service account;
- the service-account email is an active Play Console user for this app;
- it has **View app information** and **Release apps to testing tracks**; and
- production permission exists only when `review`/`auto` needs it.

Replace the GitHub secret after creating a new service-account key.

### Google Play rejected the upload key

Do not create a new app or change the package name.

1. Open Play Console → App integrity / Play App Signing.
2. Compare the registered upload certificate with the keystore used by GitHub.
3. Restore the correct keystore, alias, and passwords.
4. If the key is lost/compromised, ask the account owner to follow Google’s
   upload-key reset process.
5. Replace secrets and rerun.

### Android versionCode already used

SMF reads all bundles visible to Google Play and chooses the next integer.
This error usually means another release uploaded concurrently or a stale edit.
Rerun after the other upload finishes. Never reuse a `versionCode`.

### Android production release already in progress

SMF refuses to replace a production track containing an unfinished release.
Open Play Console and finish or halt that release, obtain release-owner
approval, then rerun `ship`.

### Android `review` published automatically

`review` depends on Play Console Managed Publishing. If it was not enabled,
Google can publish after approval. Stop further releases, verify the current
store state, enable Managed Publishing if the team requires a manual hold, and
review [Android setup](android-bootstrap.md#10-decide-how-production-will-work-later).

### Fingerprint or app identity mismatch

Never bypass it and never edit the receipt.

Confirm:

- target branch contains the tested source;
- bundle/package ID names the same store app;
- the release PR receipt is the one actually tested; and
- no tracked build input changed afterward.

Restore the expected source or produce and retest a new candidate.

### Ship failed after merge

Preserve the merged receipt and tag state. Fix the named store/GitHub
permission or external metadata issue and rerun the failed platform job. SMF
reuses matching store and GitHub resources.

Do not create a manual tag/Release to hide a failed ship.

### Abandon a release

1. Close the shared release PR.
2. Delete branch `smf/release`.
3. Decide what to do with already uploaded TestFlight/Play testing artifacts.

The next qualifying target-branch push creates a fresh PR from current state.
Deleting the branch does not remove store artifacts or tester access.

## Preserve the audit trail

While investigating, keep:

- `smf/release`;
- workflow logs;
- candidate receipts;
- exact commit SHAs;
- Apple build ID/build number; and
- Google Play `versionCode` and track.

Never paste API private keys, service-account JSON, keystores, passwords,
Base64 credentials, certificates, or provisioning profiles into an issue.
