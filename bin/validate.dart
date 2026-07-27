import 'dart:io';

import 'package:smf/src/executables.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runValidateExecutable(arguments);
}
