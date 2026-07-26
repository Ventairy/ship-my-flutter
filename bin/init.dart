import 'dart:io';

import 'package:ship_my_flutter/ship_my_flutter.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runShipMyFlutterCli(<String>['init', ...arguments]);
}
