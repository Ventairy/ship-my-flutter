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
    final plan = context.releasePlan;

    // Inspect the plan or write project-owned release notes.
    print(plan.nextVersion);
  }
}

Future<void> main() async {
  await runSmfHook(CheckPlan());
}
```

Applications that only use the standard SMF workflow do not need this package.
See the [hook guide](https://github.com/Ventairy/smf/blob/main/doc/hooks.md) for
the supported phases and data contract.
