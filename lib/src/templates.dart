import 'dart:convert';

const String configSchemaUrl =
    'https://raw.githubusercontent.com/Ventairy/ship-my-flutter/main/'
    'schemas/config.schema.json';

String generatedConfigYaml({String? bundleId}) {
  final bundleLine = bundleId == null
      ? ''
      : '    bundle_id: ${jsonEncode(bundleId)}\n';
  return '''
# yaml-language-server: \$schema=$configSchemaUrl

schema_version: 2
target_branch: main
release_branch_prefix: ship-my-flutter
hooks: {}
platforms:
  ios:
    enabled: true
    project_path: .
$bundleLine    testflight:
      groups: []
      wait_timeout_minutes: 45
    app_store:
      mode: upload
''';
}

const String workflowTemplate = r'''name: Ship my Flutter

on:
  push:
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: ship-my-flutter-${{ github.repository }}
  cancel-in-progress: false

jobs:
  plan:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
    outputs:
      phase: ${{ steps.ship.outputs.phase }}
      branch: ${{ steps.ship.outputs.branch }}
      version: ${{ steps.ship.outputs.version }}
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          fetch-depth: 0
          persist-credentials: false
      - id: ship
        uses: Ventairy/ship-my-flutter-action@v1
        with:
          phase: plan

  candidate:
    needs: plan
    if: needs.plan.outputs.phase == 'candidate'
    runs-on: macos-26
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          ref: ${{ needs.plan.outputs.branch }}
          fetch-depth: 0
          persist-credentials: false
      - if: ${{ hashFiles('.fvmrc', '.fvm/fvm_config.json') != '' }}
        uses: dart-lang/setup-dart@65eb853c7ba17dde3be364c3d2858773e7144260 # v1.7.2
        with:
          sdk: 3.10.0
      - if: ${{ hashFiles('.fvmrc', '.fvm/fvm_config.json') != '' }}
        uses: actions/cache@27d5ce7f107fe9357f9df03efb73ab90386fccae # v5.0.5
        with:
          path: ~/fvm/versions
          key: fvm-${{ runner.os }}-${{ runner.arch }}-${{ hashFiles('.fvmrc', '.fvm/fvm_config.json') }}
      - if: ${{ hashFiles('.fvmrc', '.fvm/fvm_config.json') != '' }}
        run: |
          dart pub global activate fvm 4.1.2
          fvm install
      - if: ${{ hashFiles('.fvmrc', '.fvm/fvm_config.json') == '' }}
        uses: subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2 # v2.23.0
        with:
          channel: stable
          cache: true
          pub-cache: true
      - uses: Ventairy/ship-my-flutter-action@v1
        with:
          phase: candidate
          app-store-connect-key-id: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          app-store-connect-issuer-id: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          app-store-connect-private-key-base64: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY_BASE64 }}
          ios-certificate-base64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
          ios-certificate-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
          ios-provisioning-profiles-base64: ${{ secrets.IOS_PROVISIONING_PROFILES_BASE64 }}

  promote:
    needs: plan
    if: needs.plan.outputs.phase == 'promote'
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          fetch-depth: 0
          persist-credentials: false
      - uses: Ventairy/ship-my-flutter-action@v1
        with:
          phase: promote
          app-store-connect-key-id: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          app-store-connect-issuer-id: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          app-store-connect-private-key-base64: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY_BASE64 }}
''';
