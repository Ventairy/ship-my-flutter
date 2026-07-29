import 'package:smf_engine/android.dart';

Future<List<GooglePlayBundle>> listUploadedBundles({
  required GooglePlayCredentials credentials,
  required String packageName,
}) async {
  final client = await GooglePlayClient.open(credentials);
  final edit = await client.createEdit(packageName);
  try {
    return client.listBundles(
      packageName: packageName,
      editId: edit.id,
    );
  } finally {
    await client.deleteEdit(
      packageName: packageName,
      editId: edit.id,
    );
    client.close();
  }
}
