# Example

Install the CLI globally, then run it from a Flutter application:

```bash
dart install smf_cli
cd path/to/flutter_app
smf init
smf validate
smf --phase pull-request
# Check out the release branch reported above.
smf --phase release-candidate
# Test and merge the generated release PR, then update the target branch.
smf --phase ship
```

Add `--no-github-actions` to `smf init` when the release will be operated only
through these CLI commands.

Follow the
[Getting started guide](https://github.com/Ventairy/smf/blob/main/doc/getting-started.md)
before creating a release or running a shipping command.
