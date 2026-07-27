# How releases work

SMF separates “prepare and test a release” from “deliver the approved build.”
The release pull request is the boundary between those decisions.

## The release flow

```text
qualifying commit
      |
      v
release PR updated
      |
      v
exact IPA built and uploaded
      |
      v
candidate recorded and tested
      |
      v
human merges release PR
      |
      v
same App Store Connect build verified and delivered
```

## 1. Commits decide whether iOS changes

SMF reads Conventional Commits on the configured target branch:

| Commit | iOS result |
| --- | --- |
| `fix(ios): repair sign in` | Patch release |
| `feat(ios): add offline mode` | Minor release |
| `feat(ios)!: replace local storage` | Major release |
| `feat(auth): add passkeys` | Minor release because `auth` is a feature scope |
| `fix: prevent crash` | Patch release |
| `fix(android): repair back button` | No iOS release |

`Release-As-ios: X.Y.Z` in a commit body explicitly chooses the next stable iOS
version.

## 2. SMF maintains one iOS release PR

When iOS has a release-worthy change, SMF creates or updates:

- branch `smf/ios`;
- one release PR into the configured target branch;
- the planned iOS version and changelog; and
- optional user-owned store notes.

New target-branch commits keep the same PR current. Review the version,
changelog, store notes, machine-owned state, and linked application commits
like any other release. The application commits have already landed on the
target branch, so they are not necessarily repeated in the release PR diff.

## 3. The release PR produces the candidate

The macOS candidate job:

1. runs the optional project preparation hook;
2. installs the supplied signing assets temporarily;
3. builds the IPA with the planned marketing version and next Apple build
   number;
4. records the tracked build inputs;
5. uploads the IPA to App Store Connect;
6. waits for Apple to mark it valid;
7. applies user-provided beta notes and configured TestFlight groups; and
8. commits `<flutter-app>/smf/candidates/ios-<version>.json` to the release PR.

The candidate receipt connects the source in the PR to the exact App Store
Connect build. Do not edit it manually.

## 4. A person approves the exact build

Before merging:

- confirm the candidate job succeeded;
- compare the release PR version/build with App Store Connect;
- install that exact TestFlight build;
- test it;
- review localized notes; and
- obtain the team's release approval.

The PR being mergeable is not enough. The processed build and candidate
receipt are the release gate.

## 5. Merge delivers the same build

After the release PR merges, SMF:

1. reloads the committed candidate receipt;
2. verifies the current app identity and tracked build inputs;
3. confirms that the recorded Apple build is still valid;
4. applies the configured App Store behavior; and
5. creates the `ios-vX.Y.Z` GitHub tag and Release.

SMF does not rebuild after approval.

The App Store behavior is:

- `upload`: leave the tested build uploaded without submitting App Review;
- `review`: submit the tested build and wait for manual release after approval;
- `auto`: submit the tested build and release automatically after Apple
  approval.

The initializer uses `upload` so the first successful flow cannot publish the
app.

## Files in the app repository

All release files live under the Flutter app's `smf/` directory:

| File | Owner | What to do |
| --- | --- | --- |
| `config.yaml` | User | Review and edit supported settings |
| `store-release-notes.json` | User or hook | Optionally provide localized notes |
| `manifest.json` | SMF | Review in the PR; do not edit manually |
| `changelog.json` | SMF | Review in the PR; do not edit manually |
| `candidates/ios-<version>.json` | SMF | Verify it exists; do not edit manually |

Secrets never belong in these files.

## Why some changes rebuild the candidate

The fingerprint includes:

- every Git-tracked file except SMF configuration, changelog, store notes, and
  candidate receipts; and
- the build-affecting configuration values `flavor`, `bundle_id`,
  `build_command`, and `ipa_output_path`.

Any change inside that boundary after candidate creation can change the
binary. SMF invalidates the old receipt and builds a new candidate. A tracked
symbolic link must resolve to another tracked file inside the repository.

Changing only delivery policy, TestFlight groups, wait timeout, or release
notes does not change the binary. SMF can revalidate and reuse the existing
build when its identity still matches. Ignored and untracked files are outside
the fingerprint and must never be required build inputs.

This is why release copy can be corrected without producing a needless IPA,
while source changes always require another tested candidate.

## Retries are safe

SMF reuses existing release branches, valid matching candidates, App Store
versions, localizations, and GitHub Releases when safe. A rerun should not
create a different delivery merely because the previous attempt stopped
halfway.

Never bypass an identity or fingerprint error. Follow the
[recovery guide](operations.md#retry-and-recovery) and produce a new candidate
when build inputs changed.
