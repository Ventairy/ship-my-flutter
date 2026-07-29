import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('writes stable JSON and reads it back', () async {
    final directory = await Directory.systemTemp.createTemp('smf-json-file-');
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'nested', 'value.json');
    final file = JsonFile(path);

    await file.write(<String, Object?>{'value': 1});

    expect(await file.read(), <String, Object?>{'value': 1});
    expect(
      await File(path).readAsString(),
      '{\n  "value": 1\n}\n',
    );
  });

  test(
    'when replacing JSON, it should preserve the existing file permissions',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'smf-json-file-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final path = p.join(directory.path, 'value.json');
      await File(path).writeAsString('{"old":true}\n');
      if (!Platform.isWindows) {
        final result = await Process.run('/bin/chmod', <String>['640', path]);
        expect(result.exitCode, 0);
      }

      await JsonFile(path).write(<String, Object?>{'new': true});

      expect(await JsonFile(path).read(), <String, Object?>{'new': true});
      if (!Platform.isWindows) {
        expect((await File(path).stat()).mode & 0x1ff, 0x1a0);
      }
    },
  );

  test(
    'when replacing JSON through a symbolic link, it should replace the link '
    'without changing its target',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'smf-json-file-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final targetPath = p.join(directory.path, 'target.json');
      final linkPath = p.join(directory.path, 'value.json');
      await File(targetPath).writeAsString('{"target":true}\n');
      await Link(linkPath).create(targetPath);

      await JsonFile(linkPath).write(<String, Object?>{'replacement': true});

      expect(
        await JsonFile(targetPath).read(),
        <String, Object?>{'target': true},
      );
      expect(
        await JsonFile(linkPath).read(),
        <String, Object?>{'replacement': true},
      );
    },
  );

  test(
    'when the JSON root is not an object, it should throw a malformed JSON error',
    () async {
      final directory = await Directory.systemTemp.createTemp('smf-json-file-');
      addTearDown(() => directory.delete(recursive: true));
      final path = p.join(directory.path, 'value.json');
      await File(path).writeAsString('[1, 2, 3]\n');

      expect(
        JsonFile(path).read,
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.jsonMalformed,
          ),
        ),
      );
    },
  );

  test('when the file does not exist, it should throw a JSON not found error', () async {
    final directory = await Directory.systemTemp.createTemp('smf-json-file-');
    addTearDown(() => directory.delete(recursive: true));

    expect(
      JsonFile(p.join(directory.path, 'missing.json')).read,
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          SmfErrorCode.jsonNotFound,
        ),
      ),
    );
  });

  test(
    'when the JSON syntax is invalid, it should throw a malformed JSON error',
    () async {
      final directory = await Directory.systemTemp.createTemp('smf-json-file-');
      addTearDown(() => directory.delete(recursive: true));
      final path = p.join(directory.path, 'value.json');
      await File(path).writeAsString('invalid JSON');

      expect(
        JsonFile(path).read,
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.jsonMalformed,
          ),
        ),
      );
    },
  );
}
