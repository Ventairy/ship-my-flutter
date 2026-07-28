# Changelog

## 0.1.0

- Initial standalone SMF command-line interface.
- Add `smf upgrade` and advisory checks for newer published CLI versions.
- Make `smf validate` discover every initialized app by default, with
  `--smf-path` available to validate only one.
- Use `smf release --phase pull-request|release-candidate|ship` for both manual and
  GitHub Actions releases, with an optional `--platform` filter in every phase.
