import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('when decoding a GitHub release, it should map the API URL field', () {
    final release = GitHubReleaseDto.fromJson(<String, Object?>{
      'html_url': 'https://github.com/Ventairy/example/releases/tag/v1.0.0',
      'tag_name': 'v1.0.0',
      'target_commitish': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    });

    expect(
      release.htmlUrl,
      'https://github.com/Ventairy/example/releases/tag/v1.0.0',
    );
  });
}
