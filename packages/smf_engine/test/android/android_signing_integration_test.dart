import 'dart:convert';
import 'dart:io' as io;

import 'package:path/path.dart' as p;
import 'package:smf_engine/android.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  final isEnabled = io.Platform.environment['SMF_RUN_ANDROID_SIGNING_INTEGRATION'] == 'true';

  test(
    'builds a real Flutter AAB with the temporary upload keystore',
    () async {
      final root = await io.Directory.systemTemp.createTemp('smf-android-e2e-');
      addTearDown(() => root.delete(recursive: true));
      final app = p.join(root.path, 'app');
      final keystore = p.join(root.path, 'upload.jks');
      final javaHome = await _javaHome();
      final environment = Map<String, String>.of(io.Platform.environment)
        ..['JAVA_HOME'] = javaHome
        ..['PATH'] =
            '${p.join(javaHome, 'bin')}:'
            '${io.Platform.environment['PATH'] ?? ''}';
      final runner = SystemProcessRunner(parentEnvironment: environment);
      await runner.run('flutter', <String>[
        'create',
        '--platforms=android',
        '--org',
        'dev.example',
        '--project-name',
        'smf_engine_android_e2e',
        app,
      ]);
      await runner.run(p.join(javaHome, 'bin', 'keytool'), <String>[
        '-genkeypair',
        '-noprompt',
        '-storetype',
        'JKS',
        '-keystore',
        keystore,
        '-alias',
        'upload',
        '-storepass',
        'changeit',
        '-keypass',
        'changeit',
        '-keyalg',
        'RSA',
        '-keysize',
        '2048',
        '-validity',
        '3650',
        '-dname',
        'CN=SMF Test, OU=CI, O=Ventairy, L=Test, ST=Test, C=BR',
      ]);
      final credentials = AndroidSigningCredentials(
        keystoreBase64: base64Encode(await io.File(keystore).readAsBytes()),
        keyAlias: 'upload',
        keystorePassword: 'changeit',
        keyPassword: 'changeit',
      );
      final signing = await AndroidSigningSession.install(credentials);
      addTearDown(signing.cleanup);

      final artifact = await AndroidBuild.run(
        projectRoot: app,
        command: 'flutter build appbundle --release',
        aabOutputPath: 'build/app/outputs/bundle/release',
        version: '1.2.3',
        buildNumber: '42',
        signing: signing,
        credentials: credentials,
        processRunner: runner,
      );

      expect(await io.File(artifact).exists(), isTrue);
    },
    skip: isEnabled ? false : 'Set SMF_RUN_ANDROID_SIGNING_INTEGRATION=true to run.',
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

Future<String> _javaHome() async {
  final home = io.Platform.environment['HOME'];
  final javaHomePaths = <String>[
    ?io.Platform.environment['JAVA_HOME'],
    if (home != null)
      p.join(
        home,
        'Applications',
        'Android Studio.app',
        'Contents',
        'jbr',
        'Contents',
        'Home',
      ),
    '/Applications/Android Studio.app/Contents/jbr/Contents/Home',
  ];
  for (final javaHomePath in javaHomePaths) {
    if (await io.File(p.join(javaHomePath, 'bin', 'keytool')).exists()) {
      return javaHomePath;
    }
  }
  throw StateError('Could not locate a JDK with keytool.');
}
