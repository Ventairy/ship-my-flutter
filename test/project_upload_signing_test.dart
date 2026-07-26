import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

import 'support/recording_process.dart';

const profilePlist = '''
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>Name</key><string>Example App Store</string>
  <key>UUID</key><string>PROFILE-UUID</string>
  <key>TeamIdentifier</key><array><string>TEAM123</string></array>
  <key>Entitlements</key>
  <dict>
    <key>application-identifier</key>
    <string>TEAM123.dev.example.app</string>
  </dict>
</dict>
</plist>
''';

void main() {
  test('detects the bundle identifier from Xcode build settings', () async {
    final root = await Directory.systemTemp.createTemp('smf-project-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(
      p.join(root.path, 'ios', 'Runner.xcworkspace'),
    ).create(recursive: true);
    final runner = RecordingProcessRunner(
      handler: (_) async => const RunResult(
        stdout: 'PRODUCT_BUNDLE_IDENTIFIER = dev.example.app\n',
        stderr: '',
        exitCode: 0,
      ),
    );
    expect(
      await resolveBundleId(
        root.path,
        const IosConfig(),
        processRunner: runner,
        isMacOS: true,
      ),
      'dev.example.app',
    );
    expect(runner.invocations.single.arguments, contains('-workspace'));
  });

  test(
    'builds with immutable version arguments and finds exactly one IPA',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-upload-');
      addTearDown(() => root.delete(recursive: true));
      final ipaDirectory = p.join(root.path, 'build', 'ios', 'ipa');
      await Directory(ipaDirectory).create(recursive: true);
      final ipa = p.join(ipaDirectory, 'example.ipa');
      await File(ipa).writeAsBytes(const <int>[1, 2, 3]);
      final runner = RecordingProcessRunner();
      expect(
        await buildFlutterIpa(
          projectRoot: root.path,
          version: '1.2.0',
          buildNumber: '17',
          exportOptionsPath: '/tmp/ExportOptions.plist',
          scheme: 'production',
          buildArgs: const <String>['--dart-define=ENV=production'],
          processRunner: runner,
        ),
        ipa,
      );
      final arguments = runner.invocations.single.arguments;
      expect(
        arguments,
        containsAllInOrder(<String>[
          '--build-name',
          '1.2.0',
          '--build-number',
          '17',
          '--flavor',
          'production',
          '--dart-define=ENV=production',
        ]),
      );
    },
  );

  test(
    'installs profiles, writes export options, and cleans temporary assets',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-signing-');
      addTearDown(() => root.delete(recursive: true));
      final temporaryRoot = await Directory(
        p.join(root.path, 'temporary'),
      ).create();
      final home = await Directory(p.join(root.path, 'home')).create();
      final runner = RecordingProcessRunner(
        handler: (ProcessInvocation invocation) async {
          if (invocation.executable == 'security' &&
              invocation.arguments.length == 3 &&
              invocation.arguments.first == 'list-keychains') {
            return const RunResult(
              stdout: '"login.keychain-db"\n',
              stderr: '',
              exitCode: 0,
            );
          }
          if (invocation.executable == 'security' &&
              invocation.arguments.first == 'cms') {
            return const RunResult(
              stdout: profilePlist,
              stderr: '',
              exitCode: 0,
            );
          }
          return const RunResult(stdout: '', stderr: '', exitCode: 0);
        },
      );
      final session = await installSigningAssets(
        SigningCredentials(
          certificateBase64: base64Encode(const <int>[1, 2, 3]),
          certificatePassword: 'password',
          provisioningProfiles: base64Encode(const <int>[4, 5, 6]),
        ),
        'dev.example.app',
        processRunner: runner,
        isMacOS: true,
        homeDirectory: home.path,
        temporaryRoot: temporaryRoot,
      );
      expect(session.profiles.single.teamId, 'TEAM123');
      expect(
        await File(session.profiles.single.installedPath).exists(),
        isTrue,
      );
      final exportOptions = await File(
        session.exportOptionsPath,
      ).readAsString();
      expect(exportOptions, contains('app-store-connect'));
      expect(exportOptions, contains('Example App Store'));
      final keychainPath = session.keychainPath;
      await session.cleanup();
      expect(
        await File(session.profiles.single.installedPath).exists(),
        isFalse,
      );
      expect(await File(keychainPath).exists(), isFalse);
      expect(
        runner.invocations.any(
          (ProcessInvocation value) =>
              value.executable == 'security' &&
              value.arguments.first == 'delete-keychain',
        ),
        isTrue,
      );
    },
  );

  test(
    'uploads with a temporary App Store Connect key and removes it',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-upload-');
      addTearDown(() => root.delete(recursive: true));
      final ipa = p.join(root.path, 'example.ipa');
      await File(ipa).writeAsBytes(const <int>[1, 2, 3]);
      final runner = RecordingProcessRunner();
      await uploadIpa(
        ipa,
        const AppleCredentials(
          keyId: 'KEY123',
          issuerId: 'issuer',
          privateKey: 'private-key',
        ),
        processRunner: runner,
        homeDirectory: root.path,
      );
      final key = p.join(
        root.path,
        '.appstoreconnect',
        'private_keys',
        'AuthKey_KEY123.p8',
      );
      expect(await File(key).exists(), isFalse);
      expect(
        runner.invocations.last.arguments,
        containsAllInOrder(<String>[
          'altool',
          '--upload-app',
          '-f',
          ipa,
          '--apiKey',
          'KEY123',
          '--apiIssuer',
          'issuer',
        ]),
      );
    },
  );
}
