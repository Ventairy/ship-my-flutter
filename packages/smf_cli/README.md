# smf_cli

The command-line interface for [SMF](https://github.com/Ventairy/smf).

Install it globally:

```sh
dart install smf_cli
```

Then initialize and operate SMF from a Flutter application repository:

```sh
smf init
smf validate
smf plan
```

Run `smf --help` for the complete command list. The CLI wraps `smf_engine` and the
available platform adapters; it is the only SMF package that exposes a terminal
executable.
