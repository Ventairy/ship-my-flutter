# smf_cli

The command-line interface for [SMF](https://github.com/Ventairy/smf).

Install it globally:

```sh
dart install smf_cli
```

Then initialize and operate SMF from a Flutter application repository:

```sh
smf init
smf migrate
smf validate
smf create-release
smf ship
```

Run `smf migrate` after installing a newer CLI in an existing SMF repository.
It migrates configuration, an existing generated workflow, and machine-owned
registry formats that changed.

Run `smf --help` for the complete command list. The CLI wraps `smf_engine` and the
available platform adapters; it is the only SMF package that exposes a terminal
executable.

Start with the definitive
[Getting started guide](https://github.com/Ventairy/smf/blob/main/doc/getting-started.md).
It explains store prerequisites, `smf init`, optional GitHub Actions
automation, CLI-only releases, safe candidate-only defaults, candidate testing,
and recovery. The Flutter application does not add `smf_cli` to
`dev_dependencies`.

The
[`example`](https://github.com/Ventairy/smf/blob/main/packages/smf_cli/example/README.md)
shows the installed command sequence.
