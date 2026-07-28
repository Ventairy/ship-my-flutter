import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when FVM is configured inside the repository, it should select the FVM Flutter executable',
    () async {
      final repository = await Directory.systemTemp.createTemp(
        'smf-toolchain-',
      );
      addTearDown(() => repository.delete(recursive: true));
      await Directory(p.join(repository.path, '.git')).create();
      await File(p.join(repository.path, '.fvmrc')).writeAsString('{}');
      final project = Directory(
        p.join(repository.path, 'apps', 'mobile'),
      );
      await project.create(recursive: true);

      expect(
        await FlutterToolchain.resolveExecutable(project.path),
        'fvm flutter',
      );
    },
  );
}
