import 'dart:convert';

const String configSchemaUrl =
    'https://raw.githubusercontent.com/Ventairy/smf/main/'
    'packages/smf_engine/schemas/config.schema.json';

String generatedConfigYaml({
  required String initialVersion,
  required bool enableIos,
  required bool enableAndroid,
  String? bundleId,
  String? packageName,
}) {
  final bundleLine = bundleId == null
      ? ''
      : '    bundle_id: ${jsonEncode(bundleId)}\n';
  final packageLine = packageName == null
      ? ''
      : '    package_name: ${jsonEncode(packageName)}\n';
  return '''
# yaml-language-server: \$schema=$configSchemaUrl

schema_version: 1
target_branch: main
platforms:
  ios:
    enabled: $enableIos
    initial_version: $initialVersion
$bundleLine    testflight:
      groups: []
      wait_timeout_minutes: 45
    app_store:
      mode: upload
  android:
    enabled: $enableAndroid
    initial_version: $initialVersion
$packageLine    google_play:
      testing_track: internal
      production_track: production
      mode: upload
''';
}

String generatedWorkflowYaml({required String smfPath}) {
  return workflowTemplate.replaceAll('__SMF_PATH__', jsonEncode(smfPath));
}

const String workflowTemplate = r'''
name: SMF

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
      releases: ${{ steps.smf.outputs.releases }}
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          fetch-depth: 0
          persist-credentials: false
      - id: project
        uses: Ventairy/smf-action/resolve-project@v1
        with:
          smf-path: ${{ env.SMF_PATH }}
      - if: steps.project.outputs.has-before-create-hook == 'true'
        uses: Ventairy/smf-action/setup-flutter@v1
        with:
          app-path: ${{ steps.project.outputs.app-path }}
          uses-fvm: ${{ steps.project.outputs.uses-fvm }}
          fvm-root: ${{ steps.project.outputs.fvm-root }}
      - id: smf
        uses: Ventairy/smf-action@v1
        with:
          phase: pull-request
          smf-path: ${{ env.SMF_PATH }}

  release_candidate:
    name: release-candidate (${{ matrix.platform }})
    needs: pull_request
    if: needs.pull_request.outputs.phase == 'release-candidate'
    strategy:
      fail-fast: false
      max-parallel: 1
      matrix:
        include: ${{ fromJSON(needs.pull_request.outputs.releases) }}
    runs-on: ${{ matrix.platform == 'ios' && 'macos-26' || 'ubuntu-latest' }}
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          ref: ${{ needs.pull_request.outputs.branch }}
          fetch-depth: 0
          persist-credentials: false
      - id: project
        uses: Ventairy/smf-action/resolve-project@v1
        with:
          smf-path: ${{ env.SMF_PATH }}
      - uses: Ventairy/smf-action/setup-flutter@v1
        with:
          app-path: ${{ steps.project.outputs.app-path }}
          uses-fvm: ${{ steps.project.outputs.uses-fvm }}
          fvm-root: ${{ steps.project.outputs.fvm-root }}
      - uses: Ventairy/smf-action@v1
        with:
          phase: release-candidate
          platform: ${{ matrix.platform }}
          smf-path: ${{ env.SMF_PATH }}
          app-store-connect-key-id: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          app-store-connect-issuer-id: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          app-store-connect-private-key-base64: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY_BASE64 }}
          ios-certificate-base64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
          ios-certificate-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
          ios-provisioning-profiles-base64: ${{ secrets.IOS_PROVISIONING_PROFILES_BASE64 }}
          google-play-service-account-json-base64: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64 }}
          android-keystore-base64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
          android-key-alias: ${{ secrets.ANDROID_KEY_ALIAS }}
          android-keystore-password: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          android-key-password: ${{ secrets.ANDROID_KEY_PASSWORD }}

  ship:
    name: ship (${{ matrix.platform }})
    needs: pull_request
    if: needs.pull_request.outputs.phase == 'ship'
    strategy:
      fail-fast: false
      matrix:
        include: ${{ fromJSON(needs.pull_request.outputs.releases) }}
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
          platform: ${{ matrix.platform }}
          smf-path: ${{ env.SMF_PATH }}
          app-store-connect-key-id: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          app-store-connect-issuer-id: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          app-store-connect-private-key-base64: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY_BASE64 }}
          google-play-service-account-json-base64: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64 }}
''';
