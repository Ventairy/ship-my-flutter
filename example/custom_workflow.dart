import 'dart:convert';
import 'dart:io';

import 'package:ship_my_flutter/ship_my_flutter.dart';

Future<void> main() async {
  final root = Directory.current.path;
  await validateRepository(root);
  final manifest = await loadManifest(root);
  final plan = await createReleasePlan(root, manifest, Platform.ios);
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(plan?.toJson()));
}
