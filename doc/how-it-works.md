# How releases work

SMF uses one reviewable lifecycle for iOS and Android:

```text
qualifying commits on target branch
                |
                v
app-scoped release pull request
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

The `pull-request` phase reads the configured remote target branch in an
isolated checkout. From there, SMF reads Conventional Commits since each
platform’s own baseline. For a nested Flutter app, it includes commits that
change:

- the app directory; or
- a repository path listed in that app's `release_trigger_paths`.

Commits that only change a sibling app do not apply. A shared-path commit
applies to every app that lists that path.

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

`fix`, `perf`, and `deps` produce a patch; `feat` produces a minor; any
breaking commit produces a major. Unknown/domain scopes such as `auth` apply
to all enabled platforms. Known non-mobile scopes (`macos`, `windows`, `linux`,
and `web`) do not release iOS or Android. If a scope list contains any
recognized platform name, only `ios` and/or `android` explicitly present in
that list are selected.

Each platform calculates its own next version. One may release while the other
remains unchanged.

## 2. One PR contains every pending platform

For each initialized app, SMF creates or updates:

- branch `smf/<app-id>/release`;
- one pull request into the configured target branch;
- a separate version/changelog plan for each pending platform; and
- optional localized store notes.

When both platforms need release, both plans appear in this PR. Their versions
do not need to match.

New target-branch commits refresh the same PR. Review versions, changelogs,
store notes, and platform selection like any other production change.

## 3. Candidate jobs run per platform

The optional GitHub Actions wrapper uses one matrix entry for every platform in
the PR. The CLI can perform the same candidate operations sequentially with
`smf release --phase release-candidate`, or one platform at a time with
`--platform`. Each candidate reads the remote release branch in an isolated
checkout. Candidate jobs are serialized because each commits its receipt to
that same remote branch.

### iOS candidate

SMF:

1. runs the optional `before_build` hook;
2. temporarily installs Apple signing assets;
3. builds the IPA with the planned version and next Apple build number;
4. commits the exact pending build identity before upload;
5. uploads to App Store Connect;
6. waits for a valid processed build;
7. applies TestFlight notes/groups; and
8. replaces the pending state with
   `smf/candidates/ios-<version>.json`.

### Android candidate

SMF:

1. runs the optional `before_build` hook;
2. chooses the next available Google Play `versionCode`;
3. builds an AAB with the planned version and that build number;
4. signs the AAB with the configured upload key and verifies its certificate;
5. commits the exact pending build identity before upload;
6. uploads through a Google Play edit;
7. assigns the exact `versionCode` to the configured testing track;
8. validates and commits the edit; and
9. replaces the pending state with
   `smf/candidates/android-<version>.json`.

The Android candidate uses a testing track, not Internal App Sharing, because
the track artifact can be promoted without rebuilding.

## 4. Receipts bind source to store artifacts

Both receipt types record:

- platform and marketing version;
- store build number/artifact ID;
- application identity;
- source commit and tracked-input fingerprint;
- artifact SHA-256;
- pre-upload preparation time and processing state; and
- testing destination.

For iOS, `artifactId` is the App Store Connect build ID. For Android, it is the
Google Play `versionCode`.

Receipts are machine-owned. Editing one destroys the evidence and does not make
an untested artifact safe.

While an upload is unfinished, SMF may commit
`candidates/<platform>-<version>.intent.json`. This temporary, machine-owned
file binds the source, app identity, build number, and artifact digest before
the store operation starts. A fresh runner uses it to find only that exact
artifact, finish the testing destination, and replace the intent with the final
receipt. If nothing was uploaded, SMF can retry the same reserved build
identity.

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
4. confirms the exact store artifact is still valid and available;
5. for Android, confirms the exact `versionCode` remains completed on every
   configured candidate testing track;
6. applies the configured ship target, when present; and
7. creates the platform tag and GitHub Release.

Tags are independent:

```text
<app-id>/ios-vX.Y.Z
<app-id>/android-vX.Y.Z
```

SMF never rebuilds after approval.

## Delivery after merge

Each platform's optional `ship` target controls what SMF does with its tested
artifact after the release PR is merged. See
[Apple targets](configuration.md#apple-targets) and
[Google Play targets](configuration.md#google-play-targets) for the canonical
store-specific behavior.

The `ship` phase reads the configured remote target branch in an isolated
checkout. It does not use a local branch, manifest, receipt, or uncommitted
file.

## What changes invalidate a candidate

The fingerprint includes Git-tracked app/build inputs and binary-affecting
configuration such as flavor, app identity, build command, and artifact path.

A tracked source or build-input change requires a new candidate. Ignored or
untracked build outputs are outside the fingerprint and must not be required
source inputs.

Delivery-only changes such as ship targets, TestFlight groups, processing
timeout, or release notes do not change the source fingerprint. SMF can reuse
a valid candidate and reapply its configured metadata or TestFlight groups.

Changing an Android candidate testing track reuses the receipt only when the
exact recorded `versionCode` is already a completed release on every newly
configured track. Otherwise, SMF creates a new candidate.

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
