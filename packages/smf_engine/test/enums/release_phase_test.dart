import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('when parsing noop, it should return the non-runnable no-op phase', () {
    final phase = ReleasePhase.tryParse('noop');

    expect(phase, ReleasePhase.noop);
    expect(phase?.isRunnable, isFalse);
  });

  test('when parsing pull-request, it should return the pull-request phase', () {
    expect(
      ReleasePhase.tryParse('pull-request'),
      ReleasePhase.pullRequest,
    );
    expect(ReleasePhase.pullRequest.isRunnable, isTrue);
  });

  test('when parsing release-candidate, it should return the release-candidate phase', () {
    expect(
      ReleasePhase.tryParse('release-candidate'),
      ReleasePhase.releaseCandidate,
    );
  });

  test('when parsing ship, it should return the ship phase', () {
    expect(ReleasePhase.tryParse('ship'), ReleasePhase.ship);
  });

  test('when parsing an unsupported value, it should return null', () {
    expect(ReleasePhase.tryParse('deploy'), isNull);
  });
}
