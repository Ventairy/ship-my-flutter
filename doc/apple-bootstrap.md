# Apple bootstrap

Apple requires a small amount of one-time account setup before any CI system can ship an app.

## 1. Create the app record

Create the app in App Store Connect with the same bundle ID as the Xcode target. Apple’s API can manage an existing app but cannot create the app record.

Complete the stable product metadata required for submission: app name, categories, privacy, age rating, pricing/availability, screenshots, review contact information, and any account-specific agreements. ship-my-flutter owns version-specific “What’s New” text; it does not guess product or compliance metadata.

Declare the app’s export-compliance status as well. For apps that qualify, set `ITSAppUsesNonExemptEncryption` accurately in `Info.plist`; otherwise complete the applicable encryption declaration in App Store Connect. This is a legal/product fact that the tool cannot infer.

## 2. Create an App Store Connect API key

The Account Holder must first enable App Store Connect API access. Create a team key with the least role that can upload builds and perform the configured submission mode.

Record:

- issuer ID;
- key ID;
- the downloaded `.p8` private key.

Apple permits downloading the `.p8` only once.

## 3. Export an Apple Distribution certificate

Export the signing identity and private key from Keychain Access as a password-protected `.p12`. CI needs the private key, not only the public certificate.

## 4. Download App Store provisioning profiles

Download an App Store distribution profile for the main bundle ID and each embedded extension. The profile must include the entitlements used by the target.

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
