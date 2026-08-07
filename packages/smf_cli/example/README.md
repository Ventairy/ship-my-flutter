# Example

Install the CLI globally, then run it from a Flutter application:

```bash
dart install smf_cli
cd path/to/flutter_app
smf init
smf validate
smf release --phase pull-request
smf release --phase release-candidate
# Test and merge the generated release PR, then update the target branch.
smf release --phase ship
```

Add `--no-github-actions` to `smf init` when the release will be operated only
through these CLI commands.

Follow
[CLI setup](https://github.com/Ventairy/smf/blob/main/doc/cli-setup.md) before
creating a release or running a shipping command.
