# smf_apple

Apple delivery support for [SMF](https://github.com/Ventairy/smf), including
signing, upload, TestFlight, App Store Connect, and promotion operations.

The standard [`smf_cli`](https://pub.dev/packages/smf_cli) installation already
includes this adapter. Add `smf_apple` directly only when building custom Apple
release automation:

```sh
dart pub add --dev smf_apple
```

```dart
import 'package:smf_apple/smf_apple.dart';
```

The public API covers App Store Connect access, temporary signing installation,
IPA build/upload, TestFlight candidates, candidate receipts, and promotion of
the exact recorded build. It expects the platform-neutral state and safety
contracts from `smf_engine`.

Complete the
[Apple bootstrap guide](https://github.com/Ventairy/smf/blob/main/doc/apple-bootstrap.md)
before using real credentials. By default the candidate flow resolves exact
App Store profiles through Apple's API for every signed app or extension
target. Keep private keys, certificates, and passwords outside source control
and always clean up temporary signing assets. This package exposes a Dart
library and no terminal executable. A minimal custom-client example is
available in
[`example/smf_apple_example.dart`](https://github.com/Ventairy/smf/blob/main/packages/smf_apple/example/smf_apple_example.dart).
