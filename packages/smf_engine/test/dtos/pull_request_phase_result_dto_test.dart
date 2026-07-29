import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('when encoding a no-op result, it should contain only the next phase', () {
    expect(
      const PullRequestPhaseResultDto.noop().toJson(),
      <String, Object?>{
        'nextPhase': 'noop',
      },
    );
  });

  test(
    'when encoding a release-candidate route, it should name its routing data',
    () {
      expect(
        const PullRequestPhaseResultDto.releaseCandidate(
          targets: <ReleaseTargetDto>[
            ReleaseTargetDto(
              platform: ReleasePlatform.ios,
              version: '1.2.0',
            ),
          ],
          releaseBranch: 'smf/example/release',
          pullRequestNumber: 42,
        ).toJson(),
        <String, Object?>{
          'nextPhase': 'release-candidate',
          'targets': <Object?>[
            <String, Object?>{'platform': 'ios', 'version': '1.2.0'},
          ],
          'releaseBranch': 'smf/example/release',
          'pullRequestNumber': 42,
        },
      );
    },
  );

  test('when encoding a ship route, it should contain only its targets', () {
    expect(
      const PullRequestPhaseResultDto.ship(
        targets: <ReleaseTargetDto>[
          ReleaseTargetDto(
            platform: ReleasePlatform.android,
            version: '2.0.0',
          ),
        ],
      ).toJson(),
      <String, Object?>{
        'nextPhase': 'ship',
        'targets': <Object?>[
          <String, Object?>{'platform': 'android', 'version': '2.0.0'},
        ],
      },
    );
  });
}
