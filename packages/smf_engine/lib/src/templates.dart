import 'dart:convert';

import 'package:smf_engine/src/models/smf_config.dart';

/// Renders the configuration and GitHub workflow files owned by SMF.
final class SmfTemplates {
  const SmfTemplates._();

  /// Schema URL embedded in generated configuration files.
  static const String configSchemaUrl =
      'https://raw.githubusercontent.com/Ventairy/smf/main/'
      'packages/smf_engine/schemas/config.schema.json';

  static String _yamlBlock(List<String> lines) => '${lines.join('\n')}\n';

  /// Renders a complete app configuration.
  static String configYaml({
    required String appId,
    required String? iosInitialVersion,
    required String? androidInitialVersion,
    List<String> releaseTriggerPaths = const <String>[],
    String? bundleId,
    String? packageName,
  }) {
    final encodedBundleId = bundleId == null ? null : jsonEncode(bundleId);
    final encodedPackageName = packageName == null ? null : jsonEncode(packageName);
    final iosBlock = iosInitialVersion == null
        ? ''
        : _yamlBlock(<String>[
            '  ios:',
            '    enabled: true',
            '    initial_version: $iosInitialVersion',
            if (encodedBundleId != null) '    bundle_id: $encodedBundleId',
            '    app_store:',
            '      release_candidate:',
            '        target: internal-testing',
            '        groups: []',
            '        wait_timeout_minutes: 45',
          ]);
    final androidBlock = androidInitialVersion == null
        ? ''
        : _yamlBlock(<String>[
            '  android:',
            '    enabled: true',
            '    initial_version: $androidInitialVersion',
            if (encodedPackageName != null) '    package_name: $encodedPackageName',
            '    google_play:',
            '      release_candidate:',
            '        target: internal-testing',
          ]);
    return '''
# yaml-language-server: \$schema=$configSchemaUrl

schema_version: ${SmfConfig.currentSchemaVersion}
app_id: ${jsonEncode(appId)}
target_branch: main
${releaseTriggerPaths.isEmpty ? '' : 'release_trigger_paths:\n${releaseTriggerPaths.map((path) => '  - ${jsonEncode(path)}').join('\n')}\n'}platforms:
$iosBlock$androidBlock''';
  }

  /// Renders the app-scoped GitHub Actions workflow.
  static String workflowYaml({
    required String smfPath,
    required String appId,
  }) {
    return _workflowTemplate.replaceAll('__SMF_PATH__', jsonEncode(smfPath)).replaceAll('__APP_ID__', appId);
  }

  /// Returns the app-scoped workflow file name.
  static String workflowFileName(String appId) => 'smf-$appId.yml';

  static const String _workflowTemplate = r'''
name: SMF (__APP_ID__)

on:
  push:
  workflow_dispatch:

env:
  SMF_APP_ID: __APP_ID__
  SMF_PATH: __SMF_PATH__

permissions:
  contents: read

concurrency:
  group: smf-${{ github.repository }}-${{ env.SMF_APP_ID }}
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
    environment: smf-__APP_ID__
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
          app-store-connect-key-id: ${{ secrets.SMF_APP_STORE_CONNECT_KEY_ID }}
          app-store-connect-issuer-id: ${{ secrets.SMF_APP_STORE_CONNECT_ISSUER_ID }}
          app-store-connect-auth-key-base64: ${{ secrets.SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64 }}
          ios-certificate-base64: ${{ secrets.SMF_IOS_CERTIFICATE_BASE64 }}
          ios-certificate-password: ${{ secrets.SMF_IOS_CERTIFICATE_PASSWORD }}
          google-play-service-account-json: ${{ secrets.SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON }}
          android-keystore-base64: ${{ secrets.SMF_ANDROID_KEYSTORE_BASE64 }}
          android-key-alias: ${{ secrets.SMF_ANDROID_KEY_ALIAS }}
          android-keystore-password: ${{ secrets.SMF_ANDROID_KEYSTORE_PASSWORD }}
          android-key-password: ${{ secrets.SMF_ANDROID_KEY_PASSWORD }}

  ship:
    name: ship (${{ matrix.platform }})
    needs: pull_request
    if: needs.pull_request.outputs.phase == 'ship'
    environment: smf-__APP_ID__
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
          app-store-connect-key-id: ${{ secrets.SMF_APP_STORE_CONNECT_KEY_ID }}
          app-store-connect-issuer-id: ${{ secrets.SMF_APP_STORE_CONNECT_ISSUER_ID }}
          app-store-connect-auth-key-base64: ${{ secrets.SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64 }}
          google-play-service-account-json: ${{ secrets.SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON }}
''';
}
