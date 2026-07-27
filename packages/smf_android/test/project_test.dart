import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_android/smf_android.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
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
      await resolvePackageName(
        root.path,
        const AndroidConfig(packageName: 'dev.example.explicit'),
      ),
      'dev.example.explicit',
    );
    expect(
      await resolvePackageName(root.path, const AndroidConfig()),
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
        resolvePackageName(root.path, const AndroidConfig(), flavor: 'prod'),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'PACKAGE_NAME_REQUIRED',
          ),
        ),
      );
      await expectLater(
        resolvePackageName(root.path, const AndroidConfig()),
        throwsA(isA<SmfError>()),
      );
    },
  );
}
