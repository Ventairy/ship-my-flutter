import 'package:smf_engine/android.dart';
import 'package:smf_engine/apple.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when both platforms ship, it should preserve each platform result',
    () {
      const iosRelease = AppleShipReleaseResultDto(
        version: '1.2.3',
        tag: 'example/ios-v1.2.3',
        artifactId: 'build-7',
        buildNumber: '7',
        githubReleaseUrl: 'https://example.invalid/ios',
        appStoreVersionId: 'version-1',
      );
      final androidRelease = AndroidShipReleaseResultDto(
        version: '2.3.4',
        tag: 'example/android-v2.3.4',
        versionCode: 8,
        testingTrack: 'internal',
        githubReleaseUrl: 'https://example.invalid/android',
        testingTracks: const <String>['internal'],
        shippedTracks: const <String>['production'],
        productionTrack: 'production',
      );

      expect(
        ShipPhaseResultDto(
          iosRelease: iosRelease,
          androidRelease: androidRelease,
        ).toJson(),
        <String, Object?>{
          'shippedReleases': <Object?>[
            <String, Object?>{
              'version': '1.2.3',
              'tag': 'example/ios-v1.2.3',
              'artifactId': 'build-7',
              'buildNumber': '7',
              'githubReleaseUrl': 'https://example.invalid/ios',
              'platform': 'ios',
              'appStoreVersionId': 'version-1',
            },
            <String, Object?>{
              'platform': 'android',
              'version': '2.3.4',
              'tag': 'example/android-v2.3.4',
              'artifactId': '8',
              'buildNumber': '8',
              'testingTrack': 'internal',
              'testingTracks': <String>['internal'],
              'shippedTracks': <String>['production'],
              'productionTrack': 'production',
              'githubReleaseUrl': 'https://example.invalid/android',
            },
          ],
        },
      );
    },
  );
}
