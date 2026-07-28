# Changelog

## 0.1.0

- Initial standalone SMF command-line interface.
- Add `smf upgrade` and advisory checks for newer published CLI versions.
- Use `smf --phase pull-request|release-candidate|ship` for both manual and
  GitHub Actions releases, with an optional `--platform` filter in every phase.
