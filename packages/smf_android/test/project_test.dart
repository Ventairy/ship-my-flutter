import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_android/smf_android.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('detects a literal Gradle version name', () async {
    final root = await Directory.systemTemp.createTemp('smf-android-app-');
    addTearDown(() => root.delete(recursive: true));
    final app = Directory(p.join(root.path, 'android', 'app'));
    await app.create(recursive: true);
    await File(p.join(app.path, 'build.gradle.kts')).writeAsString('''
android {
  defaultConfig {
    versionName = "2.3.1"
  }
}
''');
    await File(
      p.join(root.path, 'android', 'local.properties'),
    ).writeAsString('flutter.versionName=1.0.0\n');

    expect(await AndroidProject.detectVersion(root.path), '2.3.1');
  });

  test('falls back to Flutter local properties', () async {
    final root = await Directory.systemTemp.createTemp('smf-android-app-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'android')).create();
    await File(
      p.join(root.path, 'android', 'local.properties'),
    ).writeAsString('flutter.versionName=4.5.0\n');

    expect(await AndroidProject.detectVersion(root.path), '4.5.0');
  });

  test('rejects conflicting Android version names', () async {
    final root = await Directory.systemTemp.createTemp('smf-android-app-');
    addTearDown(() => root.delete(recursive: true));
    final app = Directory(p.join(root.path, 'android', 'app'));
    await app.create(recursive: true);
    await File(p.join(app.path, 'build.gradle')).writeAsString('''
versionName "1.0.0"
versionName "2.0.0"
''');

    await expectLater(
      AndroidProject.detectVersion(root.path),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'ANDROID_VERSION_AMBIGUOUS',
        ),
      ),
    );
  });

  test('resolves explicit and literal Gradle application IDs', () async {
    final root = await Directory.systemTemp.createTemp('smf-android-app-');
    addTearDown(() => root.delete(recursive: true));
    final app = Directory(p.join(root.path, 'android', 'app'));
    await app.create(recursive: true);
    await File(p.join(app.path, 'build.gradle.kts')).writeAsString('''
android {
  defaultConfig {
    applicationId = "dev.example.detected"
  }
}
''');

    expect(
      await AndroidProject.resolvePackageName(
        root.path,
        const AndroidConfig(packageName: 'dev.example.explicit'),
      ),
      'dev.example.explicit',
    );
    expect(
      await AndroidProject.resolvePackageName(root.path, const AndroidConfig()),
      'dev.example.detected',
    );
  });

  test(
    'requires an explicit package for flavored or dynamic projects',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-android-app-');
      addTearDown(() => root.delete(recursive: true));
      await Directory(
        p.join(root.path, 'android', 'app'),
      ).create(recursive: true);

      await expectLater(
        AndroidProject.resolvePackageName(root.path, const AndroidConfig(), flavor: 'prod'),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'PACKAGE_NAME_REQUIRED',
          ),
        ),
      );
      await expectLater(
        AndroidProject.resolvePackageName(root.path, const AndroidConfig()),
        throwsA(isA<SmfError>()),
      );
    },
  );
}
