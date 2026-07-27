# smf_engine

The platform-neutral planning and orchestration library behind
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

Platform delivery belongs in adapter packages such as `smf_apple`; this package
does not expose a terminal executable.
