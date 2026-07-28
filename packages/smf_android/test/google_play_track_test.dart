import 'package:smf_android/smf_android.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when a caller mutates source track releases, it should preserve the original track state',
    () {
      final releases = <GooglePlayRelease>[];
      final track = GooglePlayTrack(name: 'qa', releases: releases);

      releases.add(
        GooglePlayRelease(
          status: GooglePlayReleaseStatus.completed,
          versionCodes: const <int>[42],
        ),
      );

      expect(track.releases, isEmpty);
    },
  );

  test(
    'when a caller mutates source release values, it should preserve the original release state',
    () {
      final versionCodes = <int>[42];
      final notes = <String, String>{'en-US': 'Ready'};
      final release = GooglePlayRelease(
        status: GooglePlayReleaseStatus.completed,
        versionCodes: versionCodes,
        releaseNotes: notes,
      );

      versionCodes.add(43);
      notes['pt-BR'] = 'Pronto';

      expect(release.versionCodes, const <int>[42]);
      expect(
        release.releaseNotes,
        const <String, String>{'en-US': 'Ready'},
      );
    },
  );

  test(
    'when a completed release contains a version code, it should identify the version as fully rolled out',
    () {
      final track = GooglePlayTrack(
        name: 'qa',
        releases: <GooglePlayRelease>[
          GooglePlayRelease(
            status: GooglePlayReleaseStatus.completed,
            versionCodes: <int>[42],
          ),
        ],
      );

      expect(track.containsCompletedVersionCode(42), isTrue);
    },
  );

  for (final status in <GooglePlayReleaseStatus>[
    GooglePlayReleaseStatus.unspecified,
    GooglePlayReleaseStatus.draft,
    GooglePlayReleaseStatus.inProgress,
    GooglePlayReleaseStatus.halted,
  ]) {
    test(
      'when a $status release contains a version code, it should not identify the version as fully rolled out',
      () {
        final track = GooglePlayTrack(
          name: 'qa',
          releases: <GooglePlayRelease>[
            GooglePlayRelease(status: status, versionCodes: const <int>[42]),
          ],
        );

        expect(track.containsCompletedVersionCode(42), isFalse);
      },
    );
  }
}
