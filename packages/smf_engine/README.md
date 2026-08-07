# smf_engine

The complete planning and platform-delivery implementation behind
[SMF](https://github.com/Ventairy/smf).

Most users should install [`smf_cli`](https://pub.dev/packages/smf_cli) instead.
Add `smf_engine` as a development dependency only when building custom release
automation:

```sh
dart pub add --dev smf_engine
```

```dart
import 'package:smf_engine/smf_engine.dart';
```

The package is organized as three public libraries:

```dart
import 'package:smf_engine/smf_engine.dart'; // Shared release behavior.
import 'package:smf_engine/apple.dart'; // Apple delivery.
import 'package:smf_engine/android.dart'; // Android delivery.
```

Shared planning, configuration, state, and Git/GitHub behavior live in
`lib/src`. Apple credentials, signing, builds, and App Store Connect delivery
live entirely in `lib/src/ios`. Android credentials, signing, builds, and
Google Play delivery live entirely in `lib/src/android`.

Read the
[architecture guide](https://github.com/Ventairy/smf/blob/main/ARCHITECTURE.md)
before composing a custom runner, and preserve the documented clean-worktree,
fingerprint, and exact-artifact guarantees. This package exposes Dart
libraries and no terminal executable.

See
[`example/smf_engine_example.dart`](https://github.com/Ventairy/smf/blob/main/packages/smf_engine/example/smf_engine_example.dart)
for shared planning,
[`example/apple_example.dart`](https://github.com/Ventairy/smf/blob/main/packages/smf_engine/example/apple_example.dart)
for Apple, and
[`example/android_example.dart`](https://github.com/Ventairy/smf/blob/main/packages/smf_engine/example/android_example.dart)
for Android.
