# Release operations and recovery

Use this guide when an SMF release PR is open, a workflow failed, or a release
must be abandoned.

## Before merging

Do not merge the release PR until all of these are true:

1. the `release-candidate` job succeeded;
2. the PR contains
   `<flutter-app>/smf/candidates/ios-<version>.json`;
3. App Store Connect shows the same version and build number as valid;
4. the exact TestFlight build has been installed and tested;
5. localized beta/store notes are correct; and
6. the authorized release owner approved delivery.

The candidate receipt is machine-owned. Never edit it to make a check pass.

### Find the exact candidate

In GitHub:

1. Open the release PR.
2. Confirm the candidate receipt is present in **Files changed**.
3. Open the receipt and record `version`, `buildNumber`, and `buildId`.
4. Open the successful `release-candidate` workflow job and confirm its outputs
   match.

In App Store Connect:

1. Open **Apps → your app → TestFlight**.
2. Select the version and build number from the receipt.
3. Confirm processing is valid.
4. Confirm the configured internal TestFlight group has access, if applicable.
5. Install that build through TestFlight and complete the app's release test.

If any identity differs, stop and use the recovery section below.

## Choose what merge will do

Check `platforms.ios.app_store.mode` in `smf/config.yaml`:

- `upload` verifies the build and creates the GitHub Release without submitting
  App Review;
- `review` submits the build and waits for a person to release it after Apple
  approval;
- `auto` submits the build and can make it public automatically after Apple
  approval.

The default is `upload`.

To change the mode:

1. update it on the target branch;
2. commit and push the change;
3. wait for the release PR to synchronize;
4. wait for its candidate job to finish again; and
5. recheck the receipt and TestFlight build before merging.

SMF can reuse the existing candidate when only delivery settings or release
notes changed. Any tracked app or build-input change requires a new candidate
and another test.

## While the release PR is open

New target-branch commits update the existing release PR.

- `feat(ios)` and `fix(ios)` change the iOS release.
- An unscoped commit or a feature scope such as `feat(auth)` also applies to
  iOS.
- A recognized different platform scope such as `fix(android)` does not change
  the iOS version or changelog.

A non-iOS commit can still rebuild the candidate if it changes a tracked input
used by the iOS build. That is intentional: the tested IPA must match the
source that will be merged.

## Merge strategy

Conventional Commit messages on the target branch determine the release. When
squashing a feature PR, use a final title such as:

```text
feat(ios): add offline mode
```

A non-conventional squash title produces no version bump.

Merge the generated release PR only after the exact candidate is approved.
Merge commit, squash merge, and rebase merge are supported as long as the
target branch receives the complete release PR contents, including the
candidate receipt. Use the repository's normal allowed method; never edit or
drop machine-owned files while resolving conflicts.

After merge, watch the `ship` job and verify the expected `ios-vX.Y.Z` GitHub
Release appears.

## GitHub checks on the generated PR

GitHub does not start new workflow runs for events created by the default
`GITHUB_TOKEN`. SMF's own candidate job still runs in the workflow that created
the release PR, but separate repository `pull_request` workflows might not.

If those independent checks are required, configure the pull-request phase
with a GitHub App installation token or narrowly scoped fine-grained personal
access token. See [GitHub permissions](security.md#github-permissions).

Regardless of branch-protection status, always require the receipt, valid
TestFlight build, release test, and human approval described above.

Use a GitHub ruleset or branch protection on the target branch to require pull
requests and release-owner review. If GitHub exposes `release-candidate` on the
release PR as a required status check, require it too. Do not add a rule to
`smf/ios` that blocks the Action from pushing the candidate receipt. The
generated workflow cannot prevent an authorized user or ruleset bypass from
merging early, so the before-merge checklist remains mandatory.

## TestFlight groups

Group names in `smf/config.yaml` must already exist under the same app in App
Store Connect and match exactly.

An empty list uploads and processes the build without assigning a group:

```yaml
testflight:
  groups: []
```

Use an internal group for the first release. External groups require manual
TestFlight App Review setup; see [Apple setup](apple-bootstrap.md#8-optionally-create-an-internal-testflight-group).

## Retry and recovery

### No release PR opened

1. Open the failed `pull-request` job.
2. Fix the reported configuration, permission, or commit-message problem on the
   target branch.
3. Run `smf validate` locally.
4. Push the fix or rerun the failed workflow.

If the workflow reports `noop`, verify that the pushed commit qualifies for iOS
and that the workflow is running on the configured target branch.

### Candidate build or upload failed

Fix the source, Flutter/Xcode toolchain, signing asset, profile, App Store
record, or Apple permission named by the failure. Commit source/configuration
fixes to the target branch. The release PR updates and creates a new candidate
when a tracked build input changes.

Do not merge a PR without a valid receipt merely because the IPA uploaded.

### Upload succeeded but receipt commit failed

First confirm that the job has `contents: write`, the `smf/ios` branch still
exists, and repository rules allow the workflow token to update that branch.
Fix the permission or ruleset exemption, then rerun the `release-candidate`
job. SMF reuses the valid Apple build when its source and identity still
match. Do not upload manually and do not invent or edit a receipt.

### TestFlight group was not found

Open **App Store Connect → Apps → your app → TestFlight** and copy the existing
group name exactly into `testflight.groups`. Confirm the API key has at least
App Manager access for group assignment, then rerun the candidate job.

### Apple rejected or invalidated the build

Open the build in App Store Connect and read Apple's processing or compliance
message. Fix the named source, signing, entitlement, metadata, or export
compliance issue on the target branch. A corrected binary needs a new build
number and a new candidate.

### Fingerprint or app identity mismatch

Do not bypass the error and do not edit the receipt.

Confirm:

- the target branch contains the expected app source;
- the bundle ID still names the same App Store Connect app;
- the release PR contains the candidate that was actually tested; and
- no tracked build input changed after candidate creation.

Restore the expected source or produce and test a new candidate.

### Ship failed after the release PR merged

Keep the merged receipt and tag state intact. Fix the reported Apple permission,
metadata, or GitHub permission problem, then rerun the failed `ship` job. SMF
reuses existing App Store and GitHub resources when their identities match.

Do not create a manual tag or GitHub Release to hide a failed ship.

### Abandon a release

Close the release PR and delete its `smf/ios` branch. The next qualifying
target-branch push creates a fresh release PR from current state.

Closing the PR does not delete an already uploaded TestFlight build. Remove its
group access or expire it in App Store Connect if the team no longer wants it
tested.

## What to preserve while investigating

Keep the release branch, workflow logs, candidate receipt, exact commit SHA,
and App Store Connect version/build number until the incident is understood.
They are the audit trail connecting source to the uploaded build.

Never copy API keys, certificate passwords, Base64 credentials, or raw signing
files into an issue. Follow the [security guide](security.md) after any possible
exposure.
