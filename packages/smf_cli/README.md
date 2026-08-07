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
smf release --phase pull-request
smf release --phase release-candidate
smf release --phase ship
```

Run `smf --help` for the complete command list. The CLI wraps the shared,
Apple, and Android release behavior in `smf_engine`; it is the only SMF package
that exposes a terminal executable.

Start with the [setup chooser](https://github.com/Ventairy/smf#get-started).
Use the recommended
[GitHub Actions setup](https://github.com/Ventairy/smf/blob/main/doc/github-actions-setup.md)
for an automated workflow, or
[CLI setup](https://github.com/Ventairy/smf/blob/main/doc/cli-setup.md) for
human operation or custom automation. The Flutter application does not add
`smf_cli` to `dev_dependencies`.

The
[`example`](https://github.com/Ventairy/smf/blob/main/packages/smf_cli/example/README.md)
shows the installed command sequence.
