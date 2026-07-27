import 'dart:convert';

const String configSchemaUrl =
    'https://raw.githubusercontent.com/Ventairy/smf/main/'
    'schemas/config.schema.json';

String generatedConfigYaml({required String initialVersion, String? bundleId}) {
  final bundleLine = bundleId == null
      ? ''
      : '    bundle_id: ${jsonEncode(bundleId)}\n';
  return '''
# yaml-language-server: \$schema=$configSchemaUrl

schema_version: 1
target_branch: main
platforms:
  ios:
    enabled: true
    initial_version: $initialVersion
$bundleLine    testflight:
      groups: []
      wait_timeout_minutes: 45
    app_store:
      mode: upload
''';
}

String generatedWorkflowYaml({required String smfPath}) {
  return workflowTemplate.replaceAll('__SMF_PATH__', jsonEncode(smfPath));
}

const String workflowTemplate = r'''name: SMF

on:
  push:
  workflow_dispatch:

env:
  SMF_PATH: __SMF_PATH__

permissions:
  contents: read

concurrency:
  group: smf-${{ github.repository }}
  cancel-in-progress: false

jobs:
  pull_request:
    name: pull-request
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
    outputs:
      phase: ${{ steps.smf.outputs.phase }}
      branch: ${{ steps.smf.outputs.branch }}
      version: ${{ steps.smf.outputs.version }}
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          fetch-depth: 0
          persist-credentials: false
      - id: project
        name: Resolve selected Flutter app
        shell: bash
        run: |
          if [[ "$SMF_PATH" != "smf" && "$SMF_PATH" != */smf ]]; then
            echo "SMF_PATH must point directly to an smf directory." >&2
            exit 1
          fi
          if [[ ! -f "$SMF_PATH/config.yaml" ]]; then
            echo "$SMF_PATH/config.yaml does not exist." >&2
            exit 1
          fi
          app_dir="${SMF_PATH%/smf}"
          app_dir="${app_dir%/}"
          if [[ -z "$app_dir" ]]; then
            app_dir="."
          fi
          search_dir="$app_dir"
          uses_fvm=false
          fvm_root=
          while true; do
            if [[ -f "$search_dir/.fvmrc" || -f "$search_dir/.fvm/fvm_config.json" ]]; then
              uses_fvm=true
              fvm_root="$search_dir"
              break
            fi
            if [[ "$search_dir" == "." ]]; then
              break
            fi
            search_dir="$(dirname "$search_dir")"
          done
          has_hook=false
          if [[ -f "$SMF_PATH/hooks/before_create_pr.dart" ]]; then
            has_hook=true
          fi
          echo "uses_fvm=$uses_fvm" >> "$GITHUB_OUTPUT"
          echo "fvm_root=$fvm_root" >> "$GITHUB_OUTPUT"
          echo "has_before_create_hook=$has_hook" >> "$GITHUB_OUTPUT"
      - if: steps.project.outputs.has_before_create_hook == 'true' && steps.project.outputs.uses_fvm == 'true'
        uses: dart-lang/setup-dart@65eb853c7ba17dde3be364c3d2858773e7144260 # v1.7.2
        with:
          sdk: 3.10.0
      - if: steps.project.outputs.has_before_create_hook == 'true' && steps.project.outputs.uses_fvm == 'true'
        uses: actions/cache@27d5ce7f107fe9357f9df03efb73ab90386fccae # v5.0.5
        with:
          path: ~/fvm/versions
          key: fvm-${{ runner.os }}-${{ runner.arch }}-${{ hashFiles(format('{0}/.fvmrc', steps.project.outputs.fvm_root), format('{0}/.fvm/fvm_config.json', steps.project.outputs.fvm_root)) }}
      - if: steps.project.outputs.has_before_create_hook == 'true' && steps.project.outputs.uses_fvm == 'true'
        shell: bash
        run: |
          dart pub global activate fvm 4.1.2
          app_dir="${SMF_PATH%/smf}"
          app_dir="${app_dir%/}"
          if [[ -z "$app_dir" ]]; then
            app_dir="."
          fi
          search_dir="$app_dir"
          while true; do
            if [[ -f "$search_dir/.fvmrc" || -f "$search_dir/.fvm/fvm_config.json" ]]; then
              (cd "$search_dir" && fvm install)
              break
            fi
            if [[ "$search_dir" == "." ]]; then
              echo "Could not resolve the selected app's FVM configuration." >&2
              exit 1
            fi
            search_dir="$(dirname "$search_dir")"
          done
      - if: steps.project.outputs.has_before_create_hook == 'true' && steps.project.outputs.uses_fvm != 'true'
        uses: subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2 # v2.23.0
        with:
          channel: stable
          cache: true
          pub-cache: true
      - id: smf
        uses: Ventairy/smf-action@v1
        with:
          phase: pull-request
          smf-path: ${{ env.SMF_PATH }}

  release_candidate:
    name: release-candidate
    needs: pull_request
    if: needs.pull_request.outputs.phase == 'release-candidate'
    runs-on: macos-26
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          ref: ${{ needs.pull_request.outputs.branch }}
          fetch-depth: 0
          persist-credentials: false
      - id: project
        name: Resolve selected Flutter app
        shell: bash
        run: |
          if [[ "$SMF_PATH" != "smf" && "$SMF_PATH" != */smf ]]; then
            echo "SMF_PATH must point directly to an smf directory." >&2
            exit 1
          fi
          if [[ ! -f "$SMF_PATH/config.yaml" ]]; then
            echo "$SMF_PATH/config.yaml does not exist." >&2
            exit 1
          fi
          app_dir="${SMF_PATH%/smf}"
          app_dir="${app_dir%/}"
          if [[ -z "$app_dir" ]]; then
            app_dir="."
          fi
          search_dir="$app_dir"
          uses_fvm=false
          fvm_root=
          while true; do
            if [[ -f "$search_dir/.fvmrc" || -f "$search_dir/.fvm/fvm_config.json" ]]; then
              uses_fvm=true
              fvm_root="$search_dir"
              break
            fi
            if [[ "$search_dir" == "." ]]; then
              break
            fi
            search_dir="$(dirname "$search_dir")"
          done
          echo "uses_fvm=$uses_fvm" >> "$GITHUB_OUTPUT"
          echo "fvm_root=$fvm_root" >> "$GITHUB_OUTPUT"
      - if: steps.project.outputs.uses_fvm == 'true'
        uses: dart-lang/setup-dart@65eb853c7ba17dde3be364c3d2858773e7144260 # v1.7.2
        with:
          sdk: 3.10.0
      - if: steps.project.outputs.uses_fvm == 'true'
        uses: actions/cache@27d5ce7f107fe9357f9df03efb73ab90386fccae # v5.0.5
        with:
          path: ~/fvm/versions
          key: fvm-${{ runner.os }}-${{ runner.arch }}-${{ hashFiles(format('{0}/.fvmrc', steps.project.outputs.fvm_root), format('{0}/.fvm/fvm_config.json', steps.project.outputs.fvm_root)) }}
      - if: steps.project.outputs.uses_fvm == 'true'
        shell: bash
        run: |
          dart pub global activate fvm 4.1.2
          app_dir="${SMF_PATH%/smf}"
          app_dir="${app_dir%/}"
          if [[ -z "$app_dir" ]]; then
            app_dir="."
          fi
          search_dir="$app_dir"
          while true; do
            if [[ -f "$search_dir/.fvmrc" || -f "$search_dir/.fvm/fvm_config.json" ]]; then
              (cd "$search_dir" && fvm install)
              break
            fi
            if [[ "$search_dir" == "." ]]; then
              echo "Could not resolve the selected app's FVM configuration." >&2
              exit 1
            fi
            search_dir="$(dirname "$search_dir")"
          done
      - if: steps.project.outputs.uses_fvm != 'true'
        uses: subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2 # v2.23.0
        with:
          channel: stable
          cache: true
          pub-cache: true
      - uses: Ventairy/smf-action@v1
        with:
          phase: release-candidate
          smf-path: ${{ env.SMF_PATH }}
          app-store-connect-key-id: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          app-store-connect-issuer-id: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          app-store-connect-private-key-base64: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY_BASE64 }}
          ios-certificate-base64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
          ios-certificate-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
          ios-provisioning-profiles-base64: ${{ secrets.IOS_PROVISIONING_PROFILES_BASE64 }}

  ship:
    needs: pull_request
    if: needs.pull_request.outputs.phase == 'ship'
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          fetch-depth: 0
          persist-credentials: false
      - uses: Ventairy/smf-action@v1
        with:
          phase: ship
          smf-path: ${{ env.SMF_PATH }}
          app-store-connect-key-id: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          app-store-connect-issuer-id: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          app-store-connect-private-key-base64: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY_BASE64 }}
''';
