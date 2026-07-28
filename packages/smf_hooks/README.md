# smf_hooks

The lightweight, typed hook SDK for [SMF](https://github.com/Ventairy/smf).
Add this package to a Flutter application's development dependencies when its
release workflow needs custom hooks:

```sh
dart pub add --dev smf_hooks
```

```dart
import 'package:smf_hooks/smf_hooks.dart';

final class CheckPlan extends SmfHook {
  @override
  Future<void> run(SmfBeforeCreatePrContext context) async {
    final ios = context.release.ios;
    if (ios != null) {
      ios.storeReleaseNotes.write(
        locale: 'en-US',
        message: ios.changes
            .map((change) => '- ${change.description}')
            .join('\n'),
      );
    }
  }
}

Future<void> main() => CheckPlan().execute();
```

Applications that only use the standard SMF workflow do not need this package.
See the [hook guide](https://github.com/Ventairy/smf/blob/main/doc/hooks.md) for
the supported phases, data contract, verification, and recovery. A complete
implementation is available in
[`example/smf_hooks_example.dart`](https://github.com/Ventairy/smf/blob/main/packages/smf_hooks/example/smf_hooks_example.dart).
This package exposes a Dart library and no terminal executable.
