# Apple bootstrap

Apple requires a small amount of one-time account setup before any CI system can ship an app.

## 1. Create the app record

In Certificates, Identifiers & Profiles, [register an explicit App
ID](https://developer.apple.com/help/account/identifiers/register-an-app-id/)
for the main app and every embedded extension. Each ID must match its Xcode
bundle ID and enable the capabilities used by that target.

Create the app in App Store Connect with the main app's bundle ID. Apple’s API
can manage an existing app but cannot create the app record.

Complete the stable product metadata required for submission: app name, categories, privacy, age rating, pricing/availability, screenshots, review contact information, and any account-specific agreements. ship-my-flutter owns version-specific “What’s New” text; it does not guess product or compliance metadata.

Declare the app’s export-compliance status as well. For apps that qualify, set `ITSAppUsesNonExemptEncryption` accurately in `Info.plist`; otherwise complete the applicable encryption declaration in App Store Connect. This is a legal/product fact that the tool cannot infer.

## 2. Create an App Store Connect API key

The Account Holder must first enable App Store Connect API access. The Account
Holder or an Admin then creates a team key whose role covers the configured
workflow:

- `Developer` is sufficient for an `upload-only` workflow that does not assign
  the build to TestFlight groups.
- `App Manager` is the minimum role for the complete workflow: assigning
  testers to builds and submitting an app version for review. `Admin` and
  `Account Holder` also have those permissions.

Do not grant `Admin` or `Account Holder` merely to make automation work. If
`testflight.groups` is non-empty or `app_store.mode` is `submit-for-review`, use
at least `App Manager`.

Record:

- issuer ID;
- key ID;
- the downloaded `.p8` private key.

Apple permits downloading the `.p8` only once.

## 3. Export an Apple Distribution certificate

Create a [certificate signing
request](https://developer.apple.com/help/account/certificates/create-a-certificate-signing-request/)
on the Mac that will retain the private key, then create and install an Apple
Distribution certificate for the team. In Keychain Access, verify the
certificate expands to show its private key, and export that identity as a
password-protected `.p12`. CI needs the private key, not only the public
certificate.

## 4. Download App Store provisioning profiles

[Create an App Store Connect provisioning
profile](https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile/)
for the main App ID and each embedded extension App ID. Select the same
distribution certificate exported above, then download and install each
profile. Every profile must belong to the same team and include the
capabilities/entitlements used by its Xcode target.

## 5. Create TestFlight groups

Create internal or external groups before adding their exact names to
`config.yaml`. Internal testers must be eligible App Store Connect users.
External builds can require Beta App Review and beta metadata.

## 6. Add GitHub secrets

Encode the `.p8`, `.p12`, and profiles as Base64 without adding them to the repository. The generated workflow maps the six expected secret names into the action.

> [!WARNING]
> Never paste a signing key into an issue, workflow, JSON config, release PR, or build log. If a credential reaches Git history, revoke and replace it; deleting the visible line is not sufficient.

## Validation boundary

The local test suite validates request contracts with mock Apple responses. A real organization must still exercise certificate import, its entitlements/profiles, build processing, metadata completeness, and API-key permissions before treating production delivery as proven.

Use a disposable test app/repository—not a production app—for the first live
acceptance run. Let ship-my-flutter create its normal configured release branch
in that repository. Verify all of the following before publishing the core
package or the `v1` Action tag:

1. the macOS candidate job imports the real certificate and every required
   provisioning profile;
2. Xcode exports an IPA with the expected application and extension bundle
   identifiers;
3. App Store Connect accepts and finishes processing that exact build;
4. configured TestFlight groups receive the build and localized beta notes;
5. the committed candidate receipt names the processed App Store Connect build;
6. after merging the release PR, promotion selects that same build and the
   configured upload-only or review-submission behavior succeeds;
7. the immutable `ios-vX.Y.Z` GitHub Release points at the promoted source.

The first live run uses real Apple credentials and can create a TestFlight
build or review submission. Keep it as an explicitly authorized release
operation rather than a CI smoke test.
