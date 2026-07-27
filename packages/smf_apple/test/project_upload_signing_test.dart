import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_apple/smf_apple.dart';
import 'package:smf_engine/smf_engine.dart';
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

  test('uses the global Flutter flavor as the Xcode scheme', () async {
    final root = await Directory.systemTemp.createTemp('smf-flavor-project-');
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

    await resolveBundleId(
      root.path,
      const IosConfig(),
      flavor: 'production',
      processRunner: runner,
      isMacOS: true,
    );

    expect(
      runner.invocations.single.arguments,
      containsAllInOrder(<String>['-scheme', 'production']),
    );
  });

  test(
    'runs the project build command with immutable release context',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-upload-');
      addTearDown(() => root.delete(recursive: true));
      final ipaDirectory = p.join(root.path, 'build', 'ios', 'ipa');
      await Directory(ipaDirectory).create(recursive: true);
      final ipa = p.join(ipaDirectory, 'example.ipa');
      await File(ipa).writeAsBytes(const <int>[1, 2, 3]);
      final runner = RecordingProcessRunner();
      expect(
        await runIosBuildCommand(
          projectRoot: root.path,
          command: 'fvm dart run release:build_ios',
          ipaOutputPath: 'build/ios/ipa',
          version: '1.2.0',
          buildNumber: '17',
          exportOptionsPath: '/tmp/ExportOptions.plist',
          flavor: 'production',
          processRunner: runner,
        ),
        ipa,
      );
      final invocation = runner.invocations.single;
      expect(invocation.executable, '/bin/bash');
      expect(
        invocation.arguments.last,
        contains('fvm dart run release:build_ios'),
      );
      expect(
        invocation.arguments.last,
        contains(r'--build-name "$SMF_PLATFORM_VERSION"'),
      );
      expect(
        invocation.arguments.last,
        contains(r'--build-number "$SMF_BUILD_NUMBER"'),
      );
      expect(
        invocation.arguments.last,
        contains(
          '--export-options-plist '
          r'"$SMF_EXPORT_OPTIONS_PATH"',
        ),
      );
      expect(invocation.arguments.last, contains(r'--flavor "$SMF_FLAVOR"'));
      expect(
        invocation.options.environment,
        containsPair('SMF_PLATFORM_VERSION', '1.2.0'),
      );
      expect(
        invocation.options.environment,
        containsPair('SMF_BUILD_NUMBER', '17'),
      );
      expect(
        invocation.options.environment,
        containsPair('SMF_EXPORT_OPTIONS_PATH', '/tmp/ExportOptions.plist'),
      );
      expect(
        invocation.options.environment,
        containsPair('SMF_FLAVOR', 'production'),
      );
    },
  );

  test('uses FVM when an ancestor declares the project SDK', () async {
    final root = await Directory.systemTemp.createTemp('smf-fvm-command-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, '.git')).create();
    await File(
      p.join(root.path, '.fvmrc'),
    ).writeAsString('{"flutter":"3.44.0"}\n');
    final project = await Directory(p.join(root.path, 'app')).create();

    expect(
      await resolveIosBuildCommand(project.path),
      'fvm flutter build ipa --release',
    );
  });

  test('uses Flutter directly when the repository does not use FVM', () async {
    final root = await Directory.systemTemp.createTemp('smf-flutter-command-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, '.git')).create();
    final project = await Directory(p.join(root.path, 'app')).create();

    expect(
      await resolveIosBuildCommand(project.path),
      'flutter build ipa --release',
    );
  });

  test('prefers an explicitly configured build command', () async {
    final root = await Directory.systemTemp.createTemp('smf-custom-command-');
    addTearDown(() => root.delete(recursive: true));
    await File(
      p.join(root.path, '.fvmrc'),
    ).writeAsString('{"flutter":"3.44.0"}\n');

    expect(
      await resolveIosBuildCommand(
        root.path,
        configuredCommand: 'melos run build:ios',
      ),
      'melos run build:ios',
    );
  });

  test('passes every managed argument to a custom build executable', () async {
    final root = await Directory.systemTemp.createTemp('smf-build-command-');
    addTearDown(() => root.delete(recursive: true));
    await File(p.join(root.path, 'build.sh')).writeAsString(r'''
set -eu
mkdir -p "$(dirname "$SMF_IPA_OUTPUT_PATH")"
printf '%s\n' "$@" > "$SMF_IPA_OUTPUT_PATH.args"
printf 'ipa' > "$SMF_IPA_OUTPUT_PATH"
''');

    final ipa = await runIosBuildCommand(
      projectRoot: root.path,
      command: '/bin/sh build.sh',
      ipaOutputPath: 'build/app.ipa',
      version: '2.3.0',
      buildNumber: '41',
      exportOptionsPath: '/tmp/Export Options.plist',
      flavor: 'production',
    );

    expect(ipa, p.join(root.path, 'build', 'app.ipa'));
    expect(await File('$ipa.args').readAsLines(), <String>[
      '--build-name',
      '2.3.0',
      '--build-number',
      '41',
      '--export-options-plist',
      '/tmp/Export Options.plist',
      '--flavor',
      'production',
    ]);
  });

  test('accepts an exact IPA artifact path', () async {
    final root = await Directory.systemTemp.createTemp('smf-upload-');
    addTearDown(() => root.delete(recursive: true));
    final ipa = p.join(root.path, 'artifacts', 'example.ipa');
    await File(ipa).create(recursive: true);

    expect(
      await findIpa(root.path, ipaOutputPath: 'artifacts/example.ipa'),
      ipa,
    );
  });

  test('rejects an IPA artifact symlink that escapes the project', () async {
    final root = await Directory.systemTemp.createTemp('smf-upload-');
    final outside = await Directory.systemTemp.createTemp('smf-outside-');
    addTearDown(() async {
      await root.delete(recursive: true);
      await outside.delete(recursive: true);
    });
    final externalIpa = p.join(outside.path, 'example.ipa');
    await File(externalIpa).create();
    await Link(p.join(root.path, 'example.ipa')).create(externalIpa);

    await expectLater(
      findIpa(root.path, ipaOutputPath: 'example.ipa'),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'IPA_PATH_ESCAPE',
        ),
      ),
    );
  });

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
        handler: (invocation) async {
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
          (value) =>
              value.executable == 'security' &&
              value.arguments.first == 'delete-keychain',
        ),
        isTrue,
      );
    },
  );

  test('maps malformed signing inputs to typed failures', () async {
    final root = await Directory.systemTemp.createTemp('smf-signing-invalid-');
    addTearDown(() => root.delete(recursive: true));
    final temporaryRoot = await Directory(
      p.join(root.path, 'temporary'),
    ).create();
    final home = await Directory(p.join(root.path, 'home')).create();
    final runner = RecordingProcessRunner(
      handler: (invocation) async {
        if (invocation.executable == 'security' &&
            invocation.arguments.first == 'list-keychains') {
          return const RunResult(stdout: '', stderr: '', exitCode: 0);
        }
        return const RunResult(stdout: '', stderr: '', exitCode: 0);
      },
    );

    await expectLater(
      installSigningAssets(
        const SigningCredentials(
          certificateBase64: 'not-base64',
          certificatePassword: 'password',
          provisioningProfiles: 'unused',
        ),
        'dev.example.app',
        processRunner: runner,
        isMacOS: true,
        homeDirectory: home.path,
        temporaryRoot: temporaryRoot,
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'INVALID_CERTIFICATE',
        ),
      ),
    );
    await expectLater(
      installSigningAssets(
        SigningCredentials(
          certificateBase64: base64Encode(const <int>[1, 2, 3]),
          certificatePassword: 'password',
          provisioningProfiles: '{not-json',
        ),
        'dev.example.app',
        processRunner: runner,
        isMacOS: true,
        homeDirectory: home.path,
        temporaryRoot: temporaryRoot,
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'INVALID_PROFILE',
        ),
      ),
    );
  });

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

  test(
    'rejects an App Store Connect key ID that could escape its directory',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-upload-key-');
      addTearDown(() => root.delete(recursive: true));
      final ipa = p.join(root.path, 'example.ipa');
      await File(ipa).writeAsBytes(const <int>[1, 2, 3]);

      await expectLater(
        uploadIpa(
          ipa,
          const AppleCredentials(
            keyId: '../../outside',
            issuerId: 'issuer',
            privateKey: 'private-key',
          ),
          processRunner: RecordingProcessRunner(),
          homeDirectory: root.path,
        ),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'INVALID_CREDENTIAL',
          ),
        ),
      );
    },
  );
}
