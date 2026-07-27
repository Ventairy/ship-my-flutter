# How releases work

SMF uses one reviewable lifecycle for iOS and Android:

```text
qualifying commits on target branch
                |
                v
shared smf/release pull request
                |
        +-------+-------+
        |               |
        v               v
 iOS candidate     Android candidate
   TestFlight      Play testing track
        |               |
        +-------+-------+
                |
     people test exact artifacts
                |
                v
       merge release pull request
                |
        +-------+-------+
        |               |
        v               v
 same Apple build   same versionCode
 verified/shipped   verified/shipped
```

## 1. Commits create platform plans

SMF reads Conventional Commits since each platform’s own baseline.

Unscoped and feature-scoped changes apply to all enabled platforms:

```text
fix: prevent startup crash
feat(auth): add passkeys
```

Platform scopes apply selectively:

```text
fix(ios): repair entitlement
fix(android): repair back navigation
```

Each platform calculates its own next version. One may release while the other
remains unchanged.

## 2. One PR contains every pending platform

SMF creates or updates:

- branch `smf/release`;
- one pull request into the configured target branch;
- a separate version/changelog plan for each pending platform; and
- optional localized store notes.

When both platforms need release, both plans appear in this PR. Their versions
do not need to match.

New target-branch commits refresh the same PR. Review versions, changelogs,
store notes, and platform selection like any other production change.

## 3. Candidate jobs run per platform

The workflow uses one matrix entry for every platform in the PR. Candidate jobs
are serialized because each commits its receipt to the same branch.

### iOS candidate

SMF:

1. runs the optional `before_build` hook;
2. temporarily installs Apple signing assets;
3. builds the IPA with the planned version and next Apple build number;
4. uploads to App Store Connect;
5. waits for a valid processed build;
6. applies TestFlight notes/groups; and
7. commits `smf/candidates/ios-<version>.json`.

### Android candidate

SMF:

1. runs the optional `before_build` hook;
2. chooses the next available Google Play `versionCode`;
3. builds an AAB with the planned version and that build number;
4. signs the AAB with the configured upload key and verifies its certificate;
5. uploads through a Google Play edit;
6. assigns the exact `versionCode` to the configured testing track;
7. validates and commits the edit; and
8. commits `smf/candidates/android-<version>.json`.

The Android candidate uses a testing track, not Internal App Sharing, because
the track artifact can be promoted without rebuilding.

## 4. Receipts bind source to store artifacts

Both receipt types record:

- platform and marketing version;
- store build number/artifact ID;
- application identity;
- source commit and tracked-input fingerprint;
- artifact SHA-256;
- upload time and processing state; and
- testing destination.

For iOS, `artifactId` is the App Store Connect build ID. For Android, it is the
Google Play `versionCode`.

Receipts are machine-owned. Editing one destroys the evidence and does not make
an untested artifact safe.

## 5. People approve exact candidates

Before merge, a release owner must:

- confirm every candidate job succeeded;
- match the receipt to the store;
- install from TestFlight or the Play testing opt-in link;
- complete the release test;
- review localized notes; and
- approve each platform included in the PR.

A green PR is not enough. The exact processed store artifact is the release
gate.

## 6. Merge ships without rebuilding

After merge, each platform ship job:

1. loads its committed receipt;
2. verifies the merged tracked inputs still match;
3. verifies application identity;
4. confirms the exact store artifact still exists in the testing destination;
5. applies the configured delivery mode; and
6. creates the platform tag and GitHub Release.

Tags are independent:

```text
ios-vX.Y.Z
android-vX.Y.Z
```

SMF never rebuilds after approval.

## Delivery modes

### iOS

- `upload`: leave the tested build uploaded.
- `review`: submit for App Review with manual release.
- `auto`: submit for App Review with automatic release after approval.

### Android

- `upload`: leave the tested `versionCode` on the testing track.
- `review`: update production with the same `versionCode`; Managed Publishing
  must hold the approved change for manual publication.
- `auto`: update production with the same `versionCode` and allow normal
  publication after review.

The initializer uses `upload` for both platforms.

## What changes invalidate a candidate

The fingerprint includes Git-tracked app/build inputs and binary-affecting
configuration such as flavor, app identity, build command, and artifact path.

A tracked source or build-input change requires a new candidate. Ignored or
untracked build outputs are outside the fingerprint and must not be required
source inputs.

Delivery-only changes—such as TestFlight groups, Play tracks/mode, processing
timeout, or release notes—can reuse a candidate after SMF revalidates it.

Tracked symbolic links must resolve to tracked files inside the repository.

## Retries and concurrency

- The shared branch is reused.
- Candidate jobs commit receipts serially to avoid overwriting one another.
- Ship jobs can verify/promote platforms independently.
- Existing valid store artifacts and GitHub Releases are reused when their
  identity matches.
- Google Play edits are isolated and abandoned edits expire automatically.
- SMF refuses to replace a production track containing an unfinished release.

Never bypass an identity/fingerprint error. Follow
[Release operations and recovery](operations.md#retry-and-recovery).
