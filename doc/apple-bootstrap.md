# Set up Apple delivery

This guide takes a Flutter app from “it builds locally” to “SMF can upload an
exact, signed build to App Store Connect and TestFlight,” either from GitHub
Actions or through the CLI. It assumes no previous App Store experience.

Keep the generated `release_candidate` configuration and leave
`app_store.ship` omitted for the first live run. Do not add `ship` until the
release-candidate-only flow works, the exact build has been tested, and the app's store
and compliance information is complete. Read
[Apple targets](configuration.md#apple-targets) before choosing what happens
after merge.

> [!IMPORTANT]
> Apple setup changes a real developer account and creates credentials for the
> whole team. Never guess the Apple team, bundle ID, capability, role, or legal
> answer. Stop and ask the Account Holder, an Admin, or the product/legal owner
> when this guide identifies one of those decisions.

## What this setup creates

By the end, you will have:

1. one Apple App ID for the main app and each embedded extension;
2. one App Store Connect app record for the main app;
3. one App Store Connect API key used by SMF;
4. one Apple Distribution identity exported as a password-protected `.p12`;
5. one internal TestFlight group for the documented install-and-test
   acceptance run; and
6. five credential values ready for CLI environment variables or GitHub
   Actions Environment secrets.

None of the `.p8`, `.p12`, or password values belong in Git, YAML, an issue, a
pull request, or a build log.

## Apple terms used in this guide

- **Apple Account:** the email/account a person uses to sign in.
- **Apple Developer Program team:** the organization or individual membership
  that owns identifiers and certificates.
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

## Before you begin

You need:

- an active Apple Developer Program membership for the correct team;
- two-factor authentication enabled on the Apple Account;
- the latest Apple agreements accepted by the Account Holder;
- a Mac with Xcode and Keychain Access;
- the Flutter app's Git repository and working iOS project;
- for GitHub Actions, permission to create a GitHub Environment, add its
  secrets, and change Actions settings;
- a password manager or secret manager; and
- access to the people who own product metadata, privacy answers, export
  compliance, pricing, and review information.

Apple splits the setup across roles. The role required to create Apple assets
is not always the same as the role assigned to the automation key.

| Task                                                                 | Minimum Apple role                                          |
| -------------------------------------------------------------------- | ----------------------------------------------------------- |
| Accept agreements and initially request App Store Connect API access | Account Holder                                              |
| Register App IDs                                                     | Account Holder or Admin                                     |
| Create an Apple Distribution certificate                             | Account Holder or Admin                                     |
| Create the App Store Connect app record                              | Account Holder, Admin, or App Manager                       |
| Create a team API key                                                | Account Holder or Admin                                     |
| Create an internal TestFlight group manually                         | Account Holder, Admin, App Manager, Developer, or Marketing |
| Build and upload through SMF                                         | Team API key with App Manager access and provisioning access |
| Assign builds to groups or submit an app version through SMF         | Team API key with App Manager access                         |

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

Complete steps 1–4 of your selected setup before continuing:
[GitHub Actions setup](github-actions-setup.md) or
[CLI setup](cli-setup.md). Those steps install and run `smf init` exactly
once. Do not initialize again when you return to this page.

Open `<flutter-app>/smf/config.yaml` and confirm that `bundle_id` is the main
`Runner` bundle ID recorded in step 1:

```yaml
platforms:
  ios:
    enabled: true
    bundle_id: com.example.myapp
    app_store:
      release_candidate:
        target: internal-testing
        groups: []
        wait_timeout_minutes: 45
```

The empty group list means “upload and process the build without assigning it
to testers.” You can add an internal group in step 7.

See the [configuration reference](configuration.md) for every supported field.
This page now covers only the Apple-side setup. Step 9 sends you back to
Getting Started for GitHub permissions, validation, commit, and the first
release.

## 3. Register every App ID

Required human role: **Account Holder or Admin**.

Sign in to the [Apple Developer account](https://developer.apple.com/account/resources/identifiers/list)
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
running the first release candidate. Use Apple's
[supported iOS capabilities](https://developer.apple.com/help/account/reference/supported-capabilities-ios)
as the starting index; if a capability has a **Configure** button, do not
continue until its referenced resources match the Xcode target.

Success means every Xcode target has one matching identifier on the same team.
If you later add a capability, update the App ID before running another
release candidate.

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

The release-candidate-only first run does not require a finished store listing, but Apple
may require enough app and compliance information to process the build.
Before adding a [ship target](configuration.md#apple-targets) that submits the
app to App Review, the product owners must complete all current submission
fields, including:

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
7. Choose **App Manager** and ensure the key can access Certificates,
   Identifiers & Profiles. SMF uses the same key to inspect certificates,
   bundle IDs, and provisioning profiles, prepare and upload release candidates,
   manage configured TestFlight groups, and perform an Apple
   [ship action](configuration.md#apple-targets). If your organization's
   access model cannot grant those provisioning operations to this key, ask
   the Account Holder or Admin to create an appropriately authorized team key
   under the organization's policy.
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
does not authenticate to Apple; the first release candidate verifies the Key ID,
Issuer ID, private key, role, and app access together.

Apple documents these controls in
[App Store Connect API](https://developer.apple.com/help/app-store-connect/get-started/app-store-connect-api).

Use a **team key**, not an individual API key. Individual keys cannot access
all developer-account operations required by the release workflow.

Team keys apply across the App Store Connect account; they cannot be limited
to one app. A key's access level cannot be edited after creation. If the role
is wrong, or the `.p8` is lost or exposed, revoke the key and create a new one.

Do not Base64-encode the key yet. Step 8 does that immediately before adding
the GitHub Environment secret.

## 6. Create and export the distribution identity

Required human role: **Account Holder or Admin**.

First ask whether the team already has an Apple Distribution identity intended
for CI. Distribution certificates belong to the team. Do not revoke an
existing certificate merely to create another; revocation can invalidate
other release systems.

SMF needs a local Apple Distribution certificate together with its private key.
A cloud-managed certificate by itself cannot be exported as the `.p12` used by
the generated workflow.

If the Developer portal shows a certificate whose type is **Distribution
Managed**, that is a cloud-managed signing certificate. Apple manages it
remotely for cloud signing; it is not the local certificate/private-key
identity this workflow imports. Leave it alone. Reuse or create an **Apple
Distribution** identity that appears with its private key in Keychain Access.
See Apple's
[Cloud-managed certificates](https://developer.apple.com/help/account/certificates/cloud-managed-certificates/).

- If the team already stores an approved `.p12` and its password, obtain them
  through the approved secret manager, run the verification below, and skip
  the CSR and certificate-creation subsections.
- If a certificate exists but no authorized person has its private key, it
  cannot be exported as a working `.p12`. Ask an Account Holder or Admin to
  authorize a replacement.
- If no CI distribution identity exists, use the recommended Xcode path below.

### Recommended: create and export the identity with Xcode

This path creates the certificate and its private key together on the trusted
Mac, then exports both in the `.p12` format SMF needs.

1. Open Xcode.
2. In the macOS menu bar at the top of the screen, choose **Xcode → Settings**.
3. Open **Accounts**.
4. Select the Apple Account used for the correct Developer Program team.
5. Select that team in the right-hand list.
6. Click **Manage Certificates**.
7. In the lower-left corner of the certificates sheet, click the add button
   (**+**) and choose **Apple Distribution**.
8. Wait for `Apple Distribution` to appear.
9. Control-click that certificate and choose **Export Certificate**.
10. Save it as `smf-distribution.p12`.
11. Protect it with a strong, unique password.
12. Store the `.p12` and password in the approved secret manager.

If **Manage Certificates**, the add button, or **Apple Distribution** is
missing, stop and check:

- Xcode is signed in to the intended Apple Account;
- the correct team is selected;
- the person is the Account Holder or an Admin; and
- the team has not reached Apple's distribution-certificate limit.

Do not revoke another team's certificate to make the button appear. Ask the
Account Holder which existing identity should be reused or replaced.

Apple documents this flow in
[Synchronizing code signing identities](https://developer.apple.com/documentation/xcode/sharing-your-teams-signing-certificates).

Continue at [Verify the exported identity](#verify-the-exported-identity).

### Manual fallback: create the identity through the Developer portal

Use this path only when the team deliberately manages certificates through
the Apple Developer account.

#### Create the certificate signing request

On the trusted Mac that will retain the private key:

1. Open **Keychain Access**, not the Passwords app. It is located at
   `/Applications/Utilities/Keychain Access.app`.
2. Click the Keychain Access window so **Keychain Access** is the active app.
3. In the macOS menu bar at the very top of the screen, choose
   **Keychain Access → Certificate Assistant → Request a Certificate From a
   Certificate Authority**.
4. Enter the team member's email address under **User Email Address**.
5. Enter a recognizable **Common Name**, such as `SMF Distribution 2026`.
6. Leave **CA Email Address** empty.
7. Select **Saved to disk** and click **Continue**.
8. Save the `.certSigningRequest` file.

**Certificate Assistant is a macOS menu-bar command.** It does not appear in
the Keychain Access sidebar or toolbar. If the menu bar says **Finder**,
**Passwords**, or another app name, click Keychain Access again and repeat
step 3.

See Apple's
[Create a certificate signing request](https://developer.apple.com/help/account/certificates/create-a-certificate-signing-request/)
for the current Keychain procedure.

#### Create and install Apple Distribution

1. Open the Developer portal's
   [Certificates list](https://developer.apple.com/account/resources/certificates/list)
   and confirm the intended team is selected.
2. Confirm the page heading is **Certificates**. Do not use App Store Connect's
   **Users and Access → Integrations** page; that page creates API keys, not
   signing certificates.
3. Click the add button (**+**) beside the **Certificates** heading.
4. Under **Software**, select **Apple Distribution** and click **Continue**.
5. Click **Choose File** and select the `.certSigningRequest` created on this
   Mac.
6. Click **Continue**, then **Download**.
7. Double-click the downloaded `.cer` to install it in Keychain Access.
8. In Keychain Access, open **My Certificates**.
9. Find `Apple Distribution: <team name>`.
10. Expand its disclosure arrow. A private key must appear beneath it.

If the add button or **Apple Distribution** is unavailable, confirm the role,
team, membership, and certificate limit. Do not revoke an existing certificate
without the release owner's approval.

If the installed certificate does not expand to a private key, stop. The
private key is on the Mac that created the CSR, or the wrong CSR/certificate
pair was used. Downloading the `.cer` again does not recreate the private key.

#### Export the `.p12` from Keychain Access

1. Select the Apple Distribution identity in **My Certificates**.
2. Right-click and choose **Export**, or use **File → Export Items**.
3. Choose the Personal Information Exchange format (`.p12`).
4. Save it with a recognizable name such as `smf-distribution.p12`.
5. Protect it with a strong, unique password.
6. Store the `.p12` and its password in the approved secret manager.

### Verify the exported identity

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

If OpenSSL prints `Can't read Password`, it could not read from the current
terminal. That message does not mean the password itself was rejected. Export
the value in the current shell and pass it through an environment variable
instead:

```bash
export SMF_P12_PASSWORD="<p12-password>"

openssl pkcs12 \
  -in "/absolute/path/smf-distribution.p12" \
  -info \
  -noout \
  -passin env:SMF_P12_PASSWORD
```

This keeps the value out of process arguments and shell history. If the
command instead reports a MAC-verification or decryption failure, the supplied
password does not open that `.p12`; verify that the file and password came
from the same export.

When you created the identity on this Mac, also confirm that Keychain sees it:

```bash
security find-identity -v -p codesigning
```

The output must list the Apple Distribution identity. Apple's
[Certificates overview](https://developer.apple.com/help/account/certificates/certificates-overview/)
explains the role and lifecycle restrictions.

## 7. Create an internal TestFlight group for the acceptance run

An internal group is the simplest and safest way to prove tester assignment.
Its testers must already be App Store Connect users with access to the app.
Create one when the release owner must install and test the release candidate before
merging, as required by SMF's documented acceptance path.

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
app_store:
  release_candidate:
    target: internal-testing
    groups:
      - Internal
    wait_timeout_minutes: 45
```

Use `groups: []` only for an upload-and-processing diagnostic. With no group,
SMF does not assign the build to testers, so that run cannot complete the
install-and-test acceptance gate and its release PR must not be merged.

> [!NOTE]
> Do not use an external group for the first acceptance run. External testing
> requires beta metadata and Beta App Review. With
> `release_candidate.target: external-testing`, SMF updates beta notes, verifies
> that every named group is external, associates the build, and submits that
> exact build to Beta App Review. Follow Apple's
> [external testing procedure](https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers/).

## 8. Provide the five Apple credential variables

Base64 is transport encoding, not encryption. Anyone who obtains the encoded
value can recover the credential.

Use these same names whether you run SMF from the CLI or GitHub Actions:

| Variable                                    | Value                                     | Used by        |
| ------------------------------------------- | ----------------------------------------- | -------------- |
| `SMF_APP_STORE_CONNECT_KEY_ID`              | Key ID recorded in step 5                 | release candidate, ship |
| `SMF_APP_STORE_CONNECT_ISSUER_ID`           | Issuer ID recorded in step 5              | release candidate, ship |
| `SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64`     | Base64 of the `AuthKey_*.p8`              | release candidate, ship |
| `SMF_IOS_CERTIFICATE_BASE64`                | Base64 of the `.p12`                      | release candidate only |
| `SMF_IOS_CERTIFICATE_PASSWORD`              | Password chosen when exporting the `.p12` | release candidate only |

### CLI environment variables

On macOS or Linux, export the values in the shell that will run SMF:

```bash
export SMF_APP_STORE_CONNECT_KEY_ID="<key-id>"
export SMF_APP_STORE_CONNECT_ISSUER_ID="<issuer-id>"
export SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64="$(base64 <"/secure/AuthKey_ABC123.p8" | tr -d '\n')"
export SMF_IOS_CERTIFICATE_BASE64="$(base64 <"/secure/smf-distribution.p12" | tr -d '\n')"
export SMF_IOS_CERTIFICATE_PASSWORD="<p12-password>"
```

In Windows PowerShell:

```powershell
$env:SMF_APP_STORE_CONNECT_KEY_ID = "<key-id>"
$env:SMF_APP_STORE_CONNECT_ISSUER_ID = "<issuer-id>"
$env:SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\secure\AuthKey_ABC123.p8"))
$env:SMF_IOS_CERTIFICATE_BASE64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\secure\smf-distribution.p12"))
$env:SMF_IOS_CERTIFICATE_PASSWORD = "<p12-password>"
```

PowerShell can supply the App Store Connect variables to the pull-request and
ship phases. iOS release candidate builds require macOS; the certificate variables are
used there.

These variables exist only in that shell session and are inherited by the SMF
process. SMF strips credential variables before running repository hooks and
does not automatically load `.env` files.

### GitHub Actions Environment secrets

Read `app_id` from the Flutter app's `smf/config.yaml`. In the GitHub
repository:

1. Open **Settings**.
2. Open **Environments**.
3. Create or open environment `smf-<app-id>`, replacing `<app-id>` with the
   exact configured value.
4. Under **Environment secrets**, click **Add environment secret** for each
   variable in the table above.

The generated workflow declares this environment for release candidate and ship jobs.
Do not place one app's signing credentials in a sibling app's environment.

On a trusted Mac, each command copies one encoded file to the clipboard:

```bash
base64 -i "/absolute/path/AuthKey_ABC123.p8" | pbcopy
base64 -i "/absolute/path/smf-distribution.p12" | pbcopy
```

Run one command, immediately paste the clipboard into the matching environment
secret, save it, and then continue with the next credential. Clear the
clipboard when finished:

```bash
pbcopy < /dev/null
```

Universal Clipboard and clipboard-manager history can retain copied values;
disable or clear them according to team policy. On Linux, use
`base64 -w 0 "/absolute/path/FILE"`.

## 9. Return to your selected setup

Apple setup is complete when:

- every signed target has the correct explicit App ID and supporting
  capability resources;
- the App Store Connect record identifies the main app;
- the team has recorded the API Issuer ID and Key ID and protected the valid
  `.p8`;
- the exported `.p12` and password pass the local check;
- every signed target has a registered App ID on the same team;
- an internal TestFlight group exists for the documented install-and-test
  acceptance run; and either
- for GitHub Actions, all five names appear as secrets under GitHub Environment
  `smf-<app-id>`; or
- for CLI operation, all five values remain protected outside the repository
  and are ready to export as environment variables.

For the automated path, continue at
[Allow the workflow to open release PRs](github-actions-setup.md#6-allow-actions-to-create-the-release-pr).
For manual operation, continue at
[Add an optional preparation hook](cli-setup.md#6-add-an-optional-preparation-hook).
Do not trigger or merge a release from this Apple setup page.

## Troubleshooting and credential maintenance

- **Wrong Apple team or bundle ID:** stop before uploading. Correct Xcode,
  identifiers, the app record, and configuration as needed. Never bypass SMF's
  identity checks.
- **API key controls are missing:** confirm the correct App Store Connect team,
  required human role, and whether API access is still pending.
- **`.p8` is lost or exposed:** revoke the API key and create a replacement.
- **Certificate has no private key:** return to the Mac that created the CSR,
  or create an authorized replacement identity. A `.cer` download alone cannot
  restore the key.
- **Certificate expired or was revoked:** create an authorized replacement,
  replace the certificate secrets, and run a new release candidate.
- **Apple signing access is forbidden:** confirm the team API key has App
  Manager access and belongs to the same team as the `.p12` and App IDs.
- **TestFlight group is not found:** copy the existing group name exactly and
  confirm it belongs to the same app.
- **Build uploaded but receipt was not committed:** do not merge. Rerun the
  release-candidate job; SMF reuses a matching valid build.
- **Fingerprint or Apple identity mismatch:** do not edit the receipt or
  bypass the check. Produce and test a new release candidate from the corrected source.
- **Credential reached Git or logs:** revoke and rotate it. Removing one line
  does not remove copies from history or external systems.

Apple agreements, certificates, API keys, compliance answers, and store
information are not permanently “done.” Review them before releases and rotate
expiring or compromised assets deliberately.
