import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_android/smf_android.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

const fingerprint =
    'AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:'
    'AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA';

final class RecordingRunner implements ProcessRunner {
  final calls = <(String, List<String>, RunOptions)>[];

  @override
  Future<RunResult> run(
    String executable,
    List<String> arguments, {
    RunOptions options = const RunOptions(),
  }) async {
    calls.add((executable, arguments, options));
    if (executable == '/bin/bash') {
      final output = p.join(
        options.workingDirectory!,
        'build',
        'app',
        'outputs',
        'bundle',
        'release',
        'app-release.aab',
      );
      await File(output).parent.create(recursive: true);
      await File(output).writeAsBytes(<int>[1, 2, 3]);
    }
    if (executable == 'keytool') {
      return const RunResult(
        stdout: 'Certificate fingerprint SHA256: $fingerprint',
        stderr: '',
        exitCode: 0,
      );
    }
    if (executable == 'jarsigner') {
      return const RunResult(
        stdout: 'jar verified.',
        stderr: '',
        exitCode: 0,
      );
    }
    return const RunResult(stdout: '', stderr: '', exitCode: 0);
  }
}

void main() {
  test('selects FVM only within the repository boundary', () async {
    final root = await Directory.systemTemp.createTemp('smf-android-build-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, '.git')).create();
    final app = Directory(p.join(root.path, 'apps', 'mobile'));
    await app.create(recursive: true);

    expect(
      await resolveAndroidBuildCommand(app.path),
      'flutter build appbundle --release',
    );
    await File(p.join(root.path, '.fvmrc')).writeAsString('{}');
    expect(
      await resolveAndroidBuildCommand(app.path),
      'fvm flutter build appbundle --release',
    );
    expect(
      await resolveAndroidBuildCommand(
        app.path,
        configuredCommand: 'tool build android',
      ),
      'tool build android',
    );
  });

  test('finds one contained AAB and rejects escapes or ambiguity', () async {
    final root = await Directory.systemTemp.createTemp('smf-android-aab-');
    addTearDown(() => root.delete(recursive: true));
    final output = Directory(p.join(root.path, 'build', 'bundle'));
    await output.create(recursive: true);
    final first = File(p.join(output.path, 'app.aab'));
    await first.writeAsBytes(<int>[1]);

    expect(await findAab(root.path, aabOutputPath: 'build/bundle'), first.path);
    await File(p.join(output.path, 'other.aab')).writeAsBytes(<int>[2]);
    await expectLater(
      findAab(root.path, aabOutputPath: 'build/bundle'),
      throwsA(
        isA<SmfError>().having((error) => error.code, 'code', 'AAB_COUNT'),
      ),
    );
    await expectLater(
      findAab(root.path, aabOutputPath: '../outside.aab'),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'AAB_PATH_ESCAPE',
        ),
      ),
    );
  });

  test(
    'builds with managed version/signing inputs and verifies the key',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-android-build-');
      addTearDown(() => root.delete(recursive: true));
      final credentials = AndroidSigningCredentials(
        keystoreBase64: base64Encode(<int>[7, 8, 9]),
        keyAlias: 'upload',
        keystorePassword: 'store-secret',
        keyPassword: 'key-secret',
      );
      final runner = RecordingRunner();
      final signing = await installAndroidSigning(
        credentials,
        processRunner: runner,
      );
      addTearDown(signing.cleanup);

      final artifact = await runAndroidBuildCommand(
        projectRoot: root.path,
        command: 'flutter build appbundle --release',
        aabOutputPath: 'build/app/outputs/bundle/release',
        version: '2.3.0',
        buildNumber: '42',
        signing: signing,
        credentials: credentials,
        flavor: 'production',
        processRunner: runner,
      );

      expect(artifact, endsWith('app-release.aab'));
      final shell = runner.calls.firstWhere((call) => call.$1 == '/bin/bash');
      expect(shell.$2.last, contains(r'--build-name "$SMF_PLATFORM_VERSION"'));
      expect(shell.$2.last, contains(r'--build-number "$SMF_BUILD_NUMBER"'));
      expect(shell.$2.last, contains(r'--flavor "$SMF_FLAVOR"'));
      expect(shell.$3.environment, containsPair('SMF_BUILD_NUMBER', '42'));
      expect(
        shell.$3.environment.keys,
        isNot(contains('SMF_ANDROID_KEYSTORE_PASSWORD')),
      );
      expect(
        runner.calls.where((call) => call.$1 == 'jarsigner'),
        hasLength(2),
      );
      final signer = runner.calls.firstWhere(
        (call) => call.$1 == 'jarsigner' && !call.$2.contains('-verify'),
      );
      expect(signer.$2, isNot(contains('store-secret')));
      expect(
        signer.$3.environment,
        containsPair('SMF_ANDROID_KEYSTORE_PASSWORD', 'store-secret'),
      );
      expect(
        runner.calls.where((call) => call.$1 == 'keytool'),
        hasLength(2),
      );
      expect(await File(signing.keystorePath).exists(), isTrue);
    },
  );
}
