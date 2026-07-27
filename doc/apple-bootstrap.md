# Set up Apple delivery

This guide takes a Flutter app from “it builds locally” to “SMF can upload an
exact, signed build to App Store Connect and TestFlight from GitHub Actions.”
It assumes no previous App Store experience.

The first live run uses SMF's safe default, `app_store.mode: upload`. That mode
uploads and records the build, but does **not** submit it to App Review or make
it public. Do not switch to `review` or `auto` until the upload-only flow works,
the exact build has been tested, and the app's store and compliance information
is complete.

> [!IMPORTANT]
> Apple setup changes a real developer account and creates credentials for the
> whole team. Never guess the Apple team, bundle ID, capability, role, or legal
> answer. Stop and ask the Account Holder, an Admin, or the product/legal owner
> when this guide identifies one of those decisions.

## What this setup creates

By the end, you will have:

1. one Apple App ID for the main app and each embedded extension;
2. one App Store Connect app record for the main app;
3. one App Store Connect API key used by GitHub Actions;
4. one Apple Distribution identity exported as a password-protected `.p12`;
5. one App Store Connect provisioning profile for each signed bundle ID;
6. optionally, one internal TestFlight group;
7. six GitHub Actions secrets.

None of the `.p8`, `.p12`, `.mobileprovision`, or password values belong in
Git, YAML, an issue, a pull request, or a build log.

## Apple terms used in this guide

- **Apple Account:** the email/account a person uses to sign in.
- **Apple Developer Program team:** the organization or individual membership
  that owns identifiers, certificates, and profiles.
- **App Store Connect:** Apple's site for app records, uploaded builds,
  TestFlight, store information, and App Review.
- **Bundle ID:** the reverse-domain identifier built into one target, such as
  `com.example.myapp`.
- **App ID:** the Apple Developer portal record that authorizes one bundle ID
  and its capabilities.
- **App Store Connect app record:** the store-side record that uploaded builds
  are attached to. Apple also displays a numeric **Apple ID** for this record;
  that is different from a person's Apple Account.
- **Target:** one independently signed app or extension inside the Xcode
  project. The main app, share extension, notification extension, and widgets
  are separate targets with separate bundle IDs.
- **Certificate and private key:** together these form the signing identity.
  The downloaded `.cer` alone is not enough for CI; the exported `.p12` must
  contain the private key.
- **Provisioning profile:** an Apple-signed file connecting one App ID to one
  distribution certificate and its allowed entitlements.

## Before you begin

You need:

- an active Apple Developer Program membership for the correct team;
- two-factor authentication enabled on the Apple Account;
- the latest Apple agreements accepted by the Account Holder;
- a Mac with Xcode and Keychain Access;
- the Flutter app's Git repository and working iOS project;
- permission to add GitHub Actions repository secrets and change Actions
  settings;
- an organization-approved password manager or secret manager; and
- access to the people who own product metadata, privacy answers, export
  compliance, pricing, and review information.

Apple splits the setup across roles. The role required to create Apple assets
is not always the same as the role assigned to the automation key.

| Task                                                                 | Minimum Apple role                                          |
| -------------------------------------------------------------------- | ----------------------------------------------------------- |
| Accept agreements and initially request App Store Connect API access | Account Holder                                              |
| Register App IDs                                                     | Account Holder or Admin                                     |
| Create an Apple Distribution certificate                             | Account Holder or Admin                                     |
| Create App Store Connect provisioning profiles                       | Account Holder or Admin                                     |
| Create the App Store Connect app record                              | Account Holder, Admin, or App Manager                       |
| Create a team API key                                                | Account Holder or Admin                                     |
| Create an internal TestFlight group manually                         | Account Holder, Admin, App Manager, Developer, or Marketing |
| Upload through SMF without assigning TestFlight groups               | API key with Developer role                                 |
| Assign builds to groups or submit an app version through SMF         | API key with App Manager role                               |

If you do not have the required human role, ask someone with that role to
perform the named portal step. Do not solve a permissions error by granting
`Admin` to the automation key. See Apple's
[roles and access reference](https://developer.apple.com/help/account/access/roles)
for the current permission matrix.

## 1. Inventory the iOS targets

Do this before creating anything in Apple. Every bundle ID and capability must
come from the Xcode project, not from memory.

1. From the Flutter app, open `ios/Runner.xcworkspace` in Xcode.
2. In Xcode's left sidebar, select the blue project icon.
3. Under **Targets**, select `Runner`.
4. Open **Signing & Capabilities**.
5. Record the selected **Team**, **Bundle Identifier**, and every listed
   capability.
6. Repeat for every app extension, widget, notification service, App Clip, or
   other embedded target.
7. Confirm the Release configuration or production flavor uses the same team
   and the intended production bundle IDs.

For a simple Flutter app with no extensions, the inventory normally contains
only `Runner`.

Write down a table like this outside the repository:

| Xcode target   | Bundle ID                          | Capabilities                           |
| -------------- | ---------------------------------- | -------------------------------------- |
| Runner         | `com.example.myapp`                | Sign in with Apple, Push Notifications |
| ShareExtension | `com.example.myapp.ShareExtension` | App Groups                             |

Do not continue until:

- every signed target has a unique explicit bundle ID;
- every target belongs to the same Apple team;
- the main app bundle ID is final; and
- you know which capabilities each target actually uses.

If the app does not compile yet, fix that before testing CI:

```bash
flutter pub get
flutter build ios --release --no-codesign
```

Use the project's normal FVM command instead when the repository uses FVM.

## 2. Confirm the existing SMF configuration

Complete steps 1–4 of [Getting started](getting-started.md) before continuing.
Those steps install and run `smf init` exactly once. Do not initialize again
when you return to this page.

Open `<flutter-app>/smf/config.yaml` and confirm that `bundle_id` is the main
`Runner` bundle ID recorded in step 1:

```yaml
platforms:
  ios:
    enabled: true
    bundle_id: com.example.myapp
    testflight:
      groups: []
      wait_timeout_minutes: 45
    app_store:
      mode: upload
```

The empty group list means “upload and process the build without assigning it
to testers.” You can add an internal group in step 8.

See the [configuration reference](configuration.md) for every supported field.
This page now covers only the Apple-side setup. Step 10 sends you back to
Getting Started for GitHub permissions, validation, commit, and the first
release.

## 3. Register every App ID

Required human role: **Account Holder or Admin**.

Sign in to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list)
and confirm the correct team is selected.

For each bundle ID from step 1:

1. Open **Identifiers**.
2. Search for the exact bundle ID.
3. If it already exists on this team, open it and verify its capabilities.
   Reuse it; do not create a duplicate.
4. If it does not exist, click the add button (**+**).
5. Select **App IDs**, then **App**, and click **Continue**.
6. Enter a recognizable description.
7. Select **Explicit App ID**.
8. Enter the exact Xcode bundle ID.
9. Enable only the capabilities used by that target.
10. Click **Continue**, review the values, then click **Register**.

Apple's current procedure is documented in
[Register an App ID](https://developer.apple.com/help/account/identifiers/register-an-app-id/).

Some capabilities require supporting resources or additional configuration,
such as App Groups, iCloud containers, merchant IDs, or Sign in with Apple
grouping. Complete the Apple setup for every enabled capability before
creating provisioning profiles. Use Apple's
[supported iOS capabilities](https://developer.apple.com/help/account/reference/supported-capabilities-ios)
as the starting index; if a capability has a **Configure** button, do not
continue until its referenced resources match the Xcode target.

Success means every Xcode target has one matching identifier on the same team.
If you later add a capability, update the App ID and regenerate that target's
provisioning profile.

If an identifier exists under a different Apple team, stop. An identifier from
another team cannot sign this team's app.

## 4. Create or verify the App Store Connect app

Required human role: **Account Holder, Admin, or App Manager**.

1. Sign in to [App Store Connect](https://appstoreconnect.apple.com/).
2. Open **Apps**.
3. Search for an existing app with the main bundle ID.
4. If it exists, open it, verify the bundle ID, and confirm your team has
   permission to manage it. Do not create another record.
5. If it does not exist, click the add button (**+**) and select **New App**.
6. Complete:
   - **Platforms:** normally iOS;
   - **Name:** the customer-facing App Store name;
   - **Primary Language:** the language used when a localization is missing;
   - **Bundle ID:** the main App ID registered in step 3;
   - **SKU:** a private identifier used by your organization that cannot be
     changed after app creation; and
   - **User Access:** who inside the App Store Connect team can access the app.
7. Click **Create**.

The Account Holder must accept any current agreement before Apple allows app
creation. Apple's complete field and role guidance is in
[Add a new app](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/).

Success means the app appears in **Apps**, normally with the status **Prepare
for Submission**, and shows the same main bundle ID as Xcode.

### Product metadata and compliance

An upload-only first run does not require a finished store listing, but Apple
may require enough app and compliance information to process the build.
Before changing SMF to `review` or `auto`, the product owners must complete all
current submission fields, including:

- description, keywords, categories, URLs, screenshots, and app privacy;
- age rating, content rights, pricing, and availability;
- review contact information, instructions, and demo credentials when needed;
- applicable business agreements; and
- export-compliance information.

Use Apple's
[required-property reference](https://developer.apple.com/help/app-store-connect/reference/app-information/required-localizable-and-editable-properties/)
as the final submission checklist because required fields can change.

SMF can apply user-written, version-specific “What's New” notes from
`smf/store-release-notes.json`. It does not invent product, privacy, legal, or
compliance text.

The product or legal owner must determine the app's encryption status. Follow
Apple's [export-compliance questions](https://developer.apple.com/help/app-store-connect/manage-app-information/determine-and-upload-app-encryption-documentation/).
If the correct determination is that the app does not use non-exempt
encryption, the built app should contain:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

Do not assume `ios/Runner/Info.plist` is the file used by every flavor. In
Xcode, select each signed target and Release configuration, then inspect
**Build Settings → Packaging → Info.plist File** (`INFOPLIST_FILE`) or the
generated Info.plist settings. Put the approved value in the configuration
that produces the archive. After building, inspect the archived app's final
`Info.plist` to confirm the key has the intended value.

Do not copy that answer blindly. Apps requiring documentation must complete
Apple's process and use the approved compliance information. SMF cannot make
this legal determination.

## 5. Create the App Store Connect API key

The **Account Holder** must request initial API access. An **Account Holder or
Admin** then creates the team key.

Before generating the key, decide where the `.p8` will be stored. Apple allows
it to be downloaded only once.

1. In App Store Connect, open **Users and Access**.
2. Select **Integrations**.
3. Open **App Store Connect API**.
4. If access has not been enabled, the Account Holder clicks **Request
   Access**, accepts the terms, submits the request, and waits for approval.
5. Open **Team Keys** and click the add button (**+**) or **Generate API Key**.
6. Enter a descriptive name such as `SMF GitHub Actions`.
7. Choose the automation role:
   - **Developer** only when `testflight.groups` is empty and
     `app_store.mode` is `upload`;
   - **App Manager** when SMF must associate builds with TestFlight groups or
     use `review` or `auto`.
8. Generate the key.
9. Record the **Issuer ID** and **Key ID**.
10. Click **Download API Key**, confirm the download, and immediately move the
    `.p8` into the team's approved secret manager.

Before closing the page, verify that the downloaded filename
`AuthKey_<KEY_ID>.p8` contains the Key ID shown in App Store Connect and that
the recorded Issuer ID came from the same team. On a trusted machine, verify
that the downloaded file contains a readable private key:

```bash
openssl pkey -in "/absolute/path/AuthKey_ABC123.p8" -check -noout
```

Success reports that the key is valid and exits with status 0. This local check
does not authenticate to Apple; the first candidate verifies the Key ID,
Issuer ID, private key, role, and app access together.

Apple documents these controls in
[App Store Connect API](https://developer.apple.com/help/app-store-connect/get-started/app-store-connect-api).

Team keys apply across the App Store Connect account; they cannot be limited
to one app. A key's access level cannot be edited after creation. If the role
is wrong, or the `.p8` is lost or exposed, revoke the key and create a new one.

Do not Base64-encode the key yet. Step 9 does that immediately before adding
the GitHub secret.

## 6. Create and export the distribution identity

Required human role: **Account Holder or Admin**.

First ask whether the team already has an Apple Distribution identity intended
for CI. Distribution certificates belong to the team. Do not revoke an
existing certificate merely to create another; revocation can invalidate
profiles and stop other release systems.

SMF needs a local Apple Distribution certificate together with its private key.
A cloud-managed certificate by itself cannot be exported as the `.p12` used by
the generated workflow.

- If the team already stores an approved `.p12` and its password, obtain them
  through the approved secret manager, run the verification below, and skip
  the CSR and certificate-creation subsections.
- If a certificate exists but no authorized person has its private key, it
  cannot be exported as a working `.p12`. Ask an Account Holder or Admin to
  authorize a replacement.
- If no CI distribution identity exists, continue with the CSR.

### Create the certificate signing request

On the trusted Mac that will retain the private key:

1. Open **Keychain Access** from `/Applications/Utilities`.
2. Choose **Keychain Access → Certificate Assistant → Request a Certificate
   From a Certificate Authority**.
3. Enter the team member's email address.
4. Enter a recognizable **Common Name**, such as `SMF Distribution 2026`.
5. Leave **CA Email Address** empty.
6. Select **Saved to disk** and click **Continue**.
7. Save the `.certSigningRequest` file.

See Apple's
[Create a certificate signing request](https://developer.apple.com/help/account/certificates/create-a-certificate-signing-request/)
for the current Keychain procedure.

### Create and install Apple Distribution

1. Open **Certificates** in Certificates, Identifiers & Profiles.
2. Click the add button (**+**).
3. Under **Software**, select **Apple Distribution** and click **Continue**.
4. Upload the `.certSigningRequest` created on this Mac.
5. Click **Continue**, then download the `.cer`.
6. Double-click the downloaded `.cer` to install it in Keychain Access.
7. In Keychain Access, open **My Certificates**.
8. Find `Apple Distribution: <team name>`.
9. Expand its disclosure arrow. A private key must appear beneath it.

If the certificate does not expand to a private key, stop. The private key is
on the Mac that created the CSR, or the wrong CSR/certificate pair was used.
Downloading the `.cer` again does not recreate the private key.

### Export the `.p12`

1. Select the Apple Distribution identity in **My Certificates**.
2. Right-click and choose **Export**, or use **File → Export Items**.
3. Choose the Personal Information Exchange format (`.p12`).
4. Save it with a recognizable name such as `smf-distribution.p12`.
5. Protect it with a strong, unique password.
6. Store the `.p12` and its password in the approved secret manager.

Verify that the exported file opens with the recorded password and contains a
readable identity:

```bash
openssl pkcs12 \
  -in "/absolute/path/smf-distribution.p12" \
  -info \
  -noout
```

The command prompts for the export password. Success prints certificate and
key metadata and exits with status 0 without importing the identity. Do not
put the password in the command.

When you created the identity on this Mac, also confirm that Keychain sees it:

```bash
security find-identity -v -p codesigning
```

The output must list the Apple Distribution identity. Apple's
[Certificates overview](https://developer.apple.com/help/account/certificates/certificates-overview/)
explains the role and lifecycle restrictions.

## 7. Create one provisioning profile per target

Required human role: **Account Holder or Admin**.

Repeat these steps for the main app and every embedded extension:

1. Open **Profiles** in Certificates, Identifiers & Profiles.
2. Click the add button (**+**).
3. Under **Distribution**, select **App Store Connect** and click
   **Continue**.
4. Choose the App ID matching that target's bundle ID.
5. Select the Apple Distribution certificate exported in step 6.
6. Enter a clear name such as `MyApp App Store Runner` or
   `MyApp App Store ShareExtension`.
7. Click **Generate**, then **Download**.
8. Store the `.mobileprovision` file with the other release credentials.

Apple's current portal steps are in
[Create an App Store Connect provisioning profile](https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile/).

Local installation is optional because SMF installs the supplied profiles in
the temporary CI environment. You can inspect a downloaded profile on macOS:

```bash
security cms -D -i "/absolute/path/Profile.mobileprovision" | plutil -p -
```

For each profile, verify:

- `application-identifier` ends with the intended bundle ID;
- `com.apple.developer.team-identifier` names the expected team;
- the expiration date is in the future; and
- the entitlements cover the target's Release capabilities.

If an App ID capability or distribution certificate changes, regenerate the
affected profiles and replace the GitHub secret. Do not concatenate profile
files.

## 8. Optionally create an internal TestFlight group

An internal group is the simplest and safest way to prove tester assignment.
Its testers must already be App Store Connect users with access to the app.

1. In App Store Connect, open **Apps** and select the app.
2. Open the **TestFlight** tab.
3. Click the add button (**+**) next to **Internal Testing**.
4. Enter a simple name such as `Internal`.
5. Click **Create**.
6. Open the group and click **Invite Testers**.
7. Select eligible App Store Connect users and click **Add**.

Apple's current procedure is in
[Add internal testers](https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers/).

Copy the displayed group name exactly into `<flutter-app>/smf/config.yaml`:

```yaml
testflight:
  groups:
    - Internal
  wait_timeout_minutes: 45
```

Leave `groups: []` if the first run should only upload and process the build.

To install and approve the exact candidate as part of the complete Getting
Started journey, create an internal group and put its exact name in
`testflight.groups`. An uploaded build with `groups: []` is not available to
testers until a person assigns it in App Store Connect.

> [!NOTE]
> Do not use an external group for the first acceptance run. External testing
> requires beta metadata and can require Beta App Review. SMF currently updates
> beta notes and associates builds with existing groups, but it does not submit
> Beta App Review. Complete and obtain that approval manually in App Store
> Connect before relying on an external group. Follow Apple's
> [external testing procedure](https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers/).

## 9. Add the six GitHub Actions secrets

Base64 is transport encoding, not encryption. Anyone who obtains the encoded
value can recover the credential.

In the Flutter app's GitHub repository:

1. Open **Settings**.
2. Open **Secrets and variables → Actions**.
3. Select **Repository secrets**.
4. Click **New repository secret** for each value below.

Use repository secrets for the generated workflow. It does not declare a
GitHub environment, so environment secrets are unavailable unless you
deliberately customize the workflow.

| Secret                                 | Value                                               |
| -------------------------------------- | --------------------------------------------------- |
| `APP_STORE_CONNECT_KEY_ID`             | Key ID recorded in step 5                           |
| `APP_STORE_CONNECT_ISSUER_ID`          | Issuer ID recorded in step 5                        |
| `APP_STORE_CONNECT_PRIVATE_KEY_BASE64` | Base64 of the `.p8`                                 |
| `IOS_CERTIFICATE_BASE64`               | Base64 of the `.p12`                                |
| `IOS_CERTIFICATE_PASSWORD`             | Password chosen when exporting the `.p12`           |
| `IOS_PROVISIONING_PROFILES_BASE64`     | One Base64 profile, or the JSON map described below |

On a trusted Mac, each command copies one encoded file to the clipboard:

```bash
base64 -i "/absolute/path/AuthKey_ABC123.p8" | pbcopy
base64 -i "/absolute/path/smf-distribution.p12" | pbcopy
base64 -i "/absolute/path/AppStore.mobileprovision" | pbcopy
```

Run one command, immediately paste the clipboard into the matching GitHub
secret, save it, and then continue with the next credential. Clear the
clipboard when finished:

```bash
pbcopy < /dev/null
```

Universal Clipboard and clipboard-manager history can retain copied values;
disable or clear them according to team policy. On Linux, use
`base64 -w 0 "/absolute/path/FILE"`.

For an app without extensions, paste the main profile's Base64 directly into
`IOS_PROVISIONING_PROFILES_BASE64`.

For an app with extensions, encode each profile separately and set
`IOS_PROVISIONING_PROFILES_BASE64` to a JSON object whose keys are the exact
bundle IDs:

```json
{
  "com.example.myapp": "<Base64 of the main app profile>",
  "com.example.myapp.ShareExtension": "<Base64 of the extension profile>"
}
```

The JSON object itself is the secret value. Do not Base64-encode the JSON and
do not concatenate the profiles.

Do not assemble that JSON in a repository file. If `gh` and `jq` are already
installed and authenticated on a trusted Mac, use a permission-restricted
temporary directory and send the result directly to GitHub:

```bash
SMF_SECRET_DIR="$(mktemp -d)"
chmod 700 "$SMF_SECRET_DIR"
trap 'rm -f "$SMF_SECRET_DIR/main.b64" \
  "$SMF_SECRET_DIR/extension.b64" \
  "$SMF_SECRET_DIR/profiles.json"; rmdir "$SMF_SECRET_DIR"' EXIT HUP INT TERM
base64 -i "/absolute/path/AppStore.mobileprovision" \
  > "$SMF_SECRET_DIR/main.b64"
base64 -i "/absolute/path/ShareExtension.mobileprovision" \
  > "$SMF_SECRET_DIR/extension.b64"
jq -n \
  --rawfile main "$SMF_SECRET_DIR/main.b64" \
  --rawfile extension "$SMF_SECRET_DIR/extension.b64" \
  '{
    "com.example.myapp": ($main | gsub("\\n"; "")),
    "com.example.myapp.ShareExtension": ($extension | gsub("\\n"; ""))
  }' \
  > "$SMF_SECRET_DIR/profiles.json"
gh secret set IOS_PROVISIONING_PROFILES_BASE64 \
  < "$SMF_SECRET_DIR/profiles.json"
rm -f "$SMF_SECRET_DIR/main.b64" \
  "$SMF_SECRET_DIR/extension.b64" \
  "$SMF_SECRET_DIR/profiles.json"
rmdir "$SMF_SECRET_DIR"
trap - EXIT HUP INT TERM
unset SMF_SECRET_DIR
```

Replace both bundle IDs and profile paths. If more extensions exist, add one
`--rawfile` and one JSON entry for each. If you cannot use this procedure,
assemble the value only in an approved secret-manager secure note, never in
the app repository.

GitHub never shows secret values again. Verify that all six names appear in
the repository settings. If GitHub CLI is already authenticated, you can also
list names without revealing values:

```bash
gh secret list
```

If a raw credential appears in Git, an issue, a pull request, or a log, revoke
and replace it. Deleting the visible text is not enough because Git history and
external logs may retain it.

## 10. Return to Getting Started

Apple setup is complete when:

- every signed target has the correct explicit App ID and supporting
  capability resources;
- the App Store Connect record identifies the main app;
- the team has recorded the API Issuer ID and Key ID and protected the valid
  `.p8`;
- the exported `.p12` and password pass the local check;
- every signed target has a matching, unexpired App Store profile;
- an internal TestFlight group exists when the team will install the candidate;
  and
- all six GitHub secret names appear in repository settings.

Continue at [Allow the workflow to open release
PRs](getting-started.md#7-allow-actions-to-create-the-release-pr). Getting
Started owns validation, committing the generated files, triggering the first
candidate, and routing approval through the operations checklist. Do not
trigger or merge a release from this Apple setup page.

## Troubleshooting and credential maintenance

- **Wrong Apple team or bundle ID:** stop before uploading. Correct Xcode,
  identifiers, the app record, configuration, and profiles as needed. Never
  bypass SMF's identity checks.
- **API key controls are missing:** confirm the correct App Store Connect team,
  required human role, and whether API access is still pending.
- **`.p8` is lost or exposed:** revoke the API key and create a replacement.
- **Certificate has no private key:** return to the Mac that created the CSR,
  or create an authorized replacement identity. A `.cer` download alone cannot
  restore the key.
- **Certificate expired or was revoked:** create an authorized replacement,
  regenerate every profile that used the old certificate, and replace the
  GitHub secrets.
- **Profile does not match a target:** correct the App ID/capabilities and
  generate a new profile. Do not edit a `.mobileprovision` file.
- **TestFlight group is not found:** copy the existing group name exactly and
  confirm it belongs to the same app.
- **Build uploaded but receipt was not committed:** do not merge. Rerun the
  release-candidate job; SMF reuses a matching valid build.
- **Fingerprint or Apple identity mismatch:** do not edit the receipt or
  bypass the check. Produce and test a new candidate from the corrected source.
- **Credential reached Git or logs:** revoke and rotate it. Removing one line
  does not remove copies from history or external systems.

Apple agreements, certificates, profiles, API keys, compliance answers, and
store information are not permanently “done.” Review them before releases and
rotate expiring or compromised assets deliberately.
