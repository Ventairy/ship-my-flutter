# Operating release PRs

ship-my-flutter keeps release state in Git, but a release PR still needs a
maintainer decision. Use this page for routine operation and recovery.

## Before merging

Do not merge a release PR until:

1. its candidate job has committed
   `.ship-my-flutter/candidates/ios/<version>.json`;
2. the recorded build is visible and valid in TestFlight;
3. the exact candidate has been tested;
4. the localized store notes in the PR are correct.

The PR checkboxes are a human review aid; GitHub does not complete them
automatically. Branch protection should require the candidate job and any
project-specific checks you depend on.

The initializer defaults to `upload-only`. After the first end-to-end candidate
works and App Store metadata is complete, opt in to `submit-for-review` in
`config.yaml`.

## Commit routing while a PR is open

`feat(ios)` and `fix(ios)` update the iOS release. A known different platform
scope such as `fix(android)` does not change the iOS version or changelog.
Unscoped commits and feature scopes such as `feat(auth)` apply to iOS.

The release branch is also kept current with the target branch. A commit that
does not affect the iOS changelog can therefore still invalidate and rebuild
the candidate if it changes a tracked build input. This is intentional: the
tested binary must match the merged source.

The workflow starts on every push so it can observe both the target and release
branches; unrelated branches exit as `noop`.

## Merge strategy

Conventional Commit messages on the target branch determine the release. If a
feature PR contains noisy commits, squash it with a final Conventional Commit
title such as `feat(ios): add offline mode`. A non-conventional squash title
does not produce a release bump.

Merge the generated release PR only after the candidate is approved. Do not
edit its manifest or candidate receipt by hand.

## TestFlight groups

Group names must already exist in App Store Connect and match exactly. An empty
`testflight.groups` array uploads and processes the build but does not grant any
group access.

## Retry and recovery

- **Plan failed before opening a PR:** fix the reported permission or
  configuration error and rerun the failed job.
- **Candidate build/upload failed:** fix the source, signing, or Apple account
  issue on the target branch. The release PR updates and produces a new
  candidate when tracked inputs change.
- **Upload succeeded but receipt commit failed:** do not merge. Rerun the
  candidate job; the valid Apple build is reused when the fingerprint matches.
- **Promotion refused a fingerprint or Apple identity mismatch:** do not bypass
  the check or edit the receipt. Restore the release PR, produce and test a new
  candidate, then merge that exact state.
- **Abandon a release:** close the release PR and delete its release branch.
  The next qualifying target-branch push recreates it from current state.

If a failure is unclear, preserve the release branch and candidate receipt
while investigating; they are the audit trail connecting source to the Apple
build.
