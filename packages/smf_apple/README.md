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
