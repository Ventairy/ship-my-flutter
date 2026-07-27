# Set up Android and Google Play delivery

This guide takes a Flutter Android app from “it builds locally” to “SMF can
sign an App Bundle, upload it to Google Play internal testing, and later move
that exact `versionCode` toward production.”

It assumes you have never used Play Console. Complete the steps in order.

The first live run uses `google_play.mode: upload`. It uploads to the configured
testing track but does not change production.

> [!IMPORTANT]
> Store identity, declarations, signing keys, tester access, and production
> approval affect a real developer account. Do not guess. Ask the Play Console
> account owner or the app’s product/legal owner when a value is unknown.

## What this setup creates

By the end, you will have:

1. a Google Play developer account and app record;
2. Play App Signing enabled;
3. an upload keystore held by your team;
4. an internal testing tester list;
5. a Google Cloud service account with limited Play Console permissions;
6. five GitHub Actions secrets; and
7. an Android section in `smf/config.yaml` that matches the Play app.

The service-account JSON, keystore, aliases, and passwords never belong in Git,
YAML, an issue, a pull request, or a workflow log.

## Terms you need

- **Package name / application ID:** the permanent Android identifier, such as
  `com.example.myapp`. Play Console fixes it when the first artifact is
  uploaded.
- **Android App Bundle (AAB):** the `.aab` file uploaded to Google Play.
- **versionCode:** a positive integer that must increase for every new Play
  artifact. SMF chooses the next available value.
- **Marketing version:** the customer-facing `X.Y.Z` version planned by SMF.
- **Play App Signing:** Google holds the app-signing key and signs the APKs
  customers install.
- **Upload key:** your separate key used to sign the AAB submitted to Google.
  Google checks it before accepting the bundle.
- **Track:** a delivery channel such as `internal`, a closed test, or
  `production`.
- **Service account:** a non-human Google identity used by GitHub Actions to
  call the Google Play Developer API.

## Before you begin

You need:

- a verified Google Play developer account for the correct owner;
- permission to create/manage the app and invite users;
- access to Google Cloud Console;
- permission to add GitHub Actions repository secrets;
- the production package name;
- a working Flutter Android project; and
- an approved password manager or secret manager.

New personal developer accounts created after November 13, 2023 may need a
closed test with at least 12 continuously opted-in testers for 14 days before
production access is available. Internal testing remains useful, but it does
not satisfy that separate production gate. See Google’s
[current personal-account testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465).

## 1. Confirm the production package name

From the Flutter app, inspect:

```text
android/app/build.gradle.kts
android/app/build.gradle
```

Find the release application ID. A simple project looks like:

```kotlin
defaultConfig {
    applicationId = "com.example.myapp"
}
```

For flavors, confirm the final production ID after suffixes or flavor-specific
overrides. Record it exactly.

If the app already exists in Play Console, open the app and confirm the package
name shown there is identical. Never create a second app to work around a
package mismatch.

## 2. Create or verify the Play Console app

1. Open [Google Play Console](https://play.google.com/console/).
2. Select the correct developer account.
3. If the app exists, open it and stop here.
4. Otherwise select **Home → Create app**.
5. Enter the default language, app name, app/game type, free/paid choice, and
   contact email.
6. Read and accept the required declarations and Play App Signing terms.
7. Select **Create app**.

Creation does not make the app public. Google documents the current fields in
[Create and set up your app](https://support.google.com/googleplay/android-developer/answer/9859152).

Complete the dashboard tasks owned by the app team: store listing, app access,
ads, content rating, target audience, data safety, privacy policy, and any
policy declarations. SMF cannot answer these questions for you.

## 3. Confirm Play App Signing and the upload key

Open the app’s **App integrity** / **Play App Signing** page.

Play App Signing uses two different keys:

- Google protects the app-signing key used for customer APKs.
- Your team protects the upload key used for submitted AABs.

For an existing app, use the upload key already registered by Google Play.
Do not generate a replacement merely because the original keystore is hard to
find. Ask the account owner to follow Google’s upload-key reset process if it
is truly lost or compromised.

For a new app without an upload key, create one:

```bash
keytool -genkeypair \
  -storetype JKS \
  -keystore upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Choose a strong keystore password and key password, then store all four values
in the team’s secret manager:

- `upload-keystore.jks`
- alias
- keystore password
- key password

Back up the keystore securely. Do not put it inside the repository.

Google’s [Play App Signing guide](https://support.google.com/googleplay/android-developer/answer/9842756)
explains the two keys, enrollment, certificate download, and upload-key reset.

## 4. Create the internal testing audience

SMF uploads to the `internal` track by default, but it does not decide who your
testers are.

1. In the app, open **Test and release → Testing → Internal testing**.
2. Open **Testers**.
3. Create or select an email list.
4. Add trusted Google Account or Google Workspace addresses.
5. Save the list and copy the opt-in link.
6. Have at least one release tester opt in.

Internal testing supports up to 100 testers and is not publicly discoverable.
Google’s [internal testing guide](https://support.google.com/googleplay/android-developer/answer/9845334)
explains tester lists and opt-in behavior.

Use a real track, not Internal App Sharing. Internal App Sharing re-signs
artifacts with a separate sharing key and is not the promotable candidate path
used by SMF.

## 5. Create a Google Cloud service account

1. Open [Google Cloud Console](https://console.cloud.google.com/).
2. Select an approved existing project or create a project dedicated to release
   automation.
3. Open **APIs & Services → Library**.
4. Find **Google Play Android Developer API** and select **Enable**.
5. Open **IAM & Admin → Service Accounts**.
6. Select **Create service account**.
7. Use a clear name such as `myapp-smf-release`.
8. Do not grant broad Google Cloud project roles; Play permissions are assigned
   separately.
9. Open the service account, select **Keys → Add key → Create new key → JSON**.
10. Download the JSON once and move it immediately to the secret manager.

Google recommends service accounts for server-to-server access and documents
the current setup in the
[Google Play Developer API getting-started guide](https://developers.google.com/android-publisher/getting_started).

## 6. Grant only the required Play Console permissions

1. In Play Console, open **Users and permissions**.
2. Select **Invite new users**.
3. Enter the service account’s `client_email` from the JSON file.
4. Limit access to this app when your account structure permits it.
5. Grant:
   - **View app information and download bulk reports (read-only)**;
   - **Release apps to testing tracks**.
6. Grant **Release to production, exclude devices, and use Play App Signing**
   only if you will later use `mode: review` or `mode: auto`.
7. Do not grant financial, orders, user-management, or global Admin access.
8. Send/accept the invitation.

SMF does not edit tester lists, so it does not need the permission to manage
testing tracks and tester lists. Google describes the current release
permissions in [Publish your app](https://support.google.com/googleplay/android-developer/answer/9859751)
and [Users and permissions](https://support.google.com/googleplay/android-developer/answer/9844686).

## 7. Encode the two files

On macOS:

```bash
base64 -i service-account.json | pbcopy
base64 -i upload-keystore.jks | pbcopy
```

On Linux:

```bash
base64 -w 0 service-account.json
base64 -w 0 upload-keystore.jks
```

Base64 is not encryption. Delete unprotected working copies after the GitHub
secrets are verified and the originals are stored safely.

## 8. Add the five GitHub Actions secrets

Open the Flutter repository:

**Settings → Secrets and variables → Actions → New repository secret**

Add:

| Secret | Value |
| --- | --- |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64` | Base64 service-account JSON |
| `ANDROID_KEYSTORE_BASE64` | Base64 upload keystore |
| `ANDROID_KEY_ALIAS` | Upload-key alias |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |

Use repository or organization secrets according to your organization’s
policy. Environment-protected secrets are also valid if the generated jobs are
configured to use that environment.

## 9. Configure Android in SMF

The generated section should resemble:

```yaml
platforms:
  android:
    enabled: true
    initial_version: 1.0.0
    package_name: com.example.myapp
    google_play:
      testing_track: internal
      production_track: production
      mode: upload
```

Keep `mode: upload` for the first live run.

If `package_name` is omitted, SMF can detect a literal `applicationId` in a
simple Gradle file. Set it explicitly for flavors or computed IDs.

Run:

```bash
smf validate
```

## 10. Decide how production will work later

After the internal-testing candidate is installed and approved:

- `upload` leaves production untouched.
- `review` moves the exact `versionCode` to production, but requires
  **Managed publishing** to be enabled in Play Console so a person controls the
  final publish after Google approval.
- `auto` moves the exact `versionCode` to production and allows normal Play
  publication after review.

Do not use `review` unless you have confirmed Managed Publishing is enabled.
Google explains that control in
[Managed publishing](https://support.google.com/googleplay/android-developer/answer/9859654).

SMF will not replace a production track that contains an unfinished release.
Finish or halt that release in Play Console first.

## Final checklist

Before returning to [Getting Started](getting-started.md):

- the Play app uses the exact production package name;
- Play App Signing is enabled;
- the upload keystore matches Play’s registered upload certificate;
- at least one internal tester has opted in;
- the Android Publisher API is enabled;
- the service account is invited with only the required permissions;
- all five GitHub secrets exist;
- `google_play.mode` is still `upload`; and
- `smf validate` succeeds.

Never test a credential by printing it. Trigger the upload-only candidate and
use the [recovery guide](operations.md#retry-and-recovery) if Google rejects
authentication, permission, signing, or package identity.
