import 'package:smf_engine/apple.dart';

Future<String> nextBuildNumber({
  required AppleCredentials credentials,
  required String bundleId,
  required String marketingVersion,
}) async {
  final client = AppStoreConnectClient(credentials);
  try {
    final app = await client.findApp(bundleId);
    return client.nextBuildNumber(
      appId: app.id,
      version: marketingVersion,
    );
  } finally {
    client.close();
  }
}
