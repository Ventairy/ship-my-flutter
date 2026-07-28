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

The public API includes configuration loading and validation, Conventional
Commit planning, release manifests, candidate receipts, Git operations, and
GitHub release-PR orchestration. `SmfMigration.migrate(...)` gives custom
runners the same versioned configuration, workflow, and registry migrations as
`smf migrate`. Platform signing and store delivery belong in `smf_apple` and
`smf_android`.

Read the
[architecture guide](https://github.com/Ventairy/smf/blob/main/ARCHITECTURE.md)
before composing a custom runner, and preserve the documented clean-worktree,
fingerprint, and exact-artifact guarantees. This package exposes a Dart library
and no terminal executable.

See
[`example/smf_engine_example.dart`](https://github.com/Ventairy/smf/blob/main/packages/smf_engine/example/smf_engine_example.dart)
for a minimal custom planning workflow.
