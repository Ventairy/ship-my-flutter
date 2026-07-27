# smf_android

Android App Bundle signing and Google Play delivery for
[SMF](https://github.com/Ventairy/smf).

Most app teams do not add this package. Install `smf_cli` and use the generated
GitHub Actions workflow. Add `smf_android` as a development dependency only
when building custom Dart automation around Android candidate or promotion
operations:

```bash
dart pub add --dev smf_android
```

See the canonical
[Android and Google Play setup guide](https://github.com/Ventairy/smf/blob/main/doc/android-bootstrap.md)
before using real credentials.

The package supports:

- service-account credential loading;
- temporary upload-keystore handling;
- signed AAB build and exact certificate verification;
- Google Play Edit, bundle, and track operations;
- internal-testing candidate receipts; and
- exact-`versionCode` production promotion without rebuilding.

Never log or persist service-account JSON, keystores, aliases, or passwords.
