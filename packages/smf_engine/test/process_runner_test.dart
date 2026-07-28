import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('maps process start failures to a typed command failure', () async {
    await expectLater(
      const SystemProcessRunner().run(
        '/path/that/does/not/exist',
        const <String>[],
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'COMMAND_FAILED',
        ),
      ),
    );
  });

  group('child-process security', () {
    test(
      'does not expose credential environment variables to subprocesses',
      () async {
        const runner = SystemProcessRunner(
          parentEnvironment: <String, String>{
            'PATH': '/usr/bin:/bin',
            'GITHUB_TOKEN': 'github-secret',
            'SMF_IOS_CERTIFICATE_PASSWORD': 'certificate-secret',
            'SMF_APP_STORE_CONNECT_AUTH_KEY_PATH': '/private/key.p8',
          },
        );
        const command =
            r'printf "%s|%s|%s" "$GITHUB_TOKEN" '
            r'"$SMF_IOS_CERTIFICATE_PASSWORD" '
            r'"$SMF_APP_STORE_CONNECT_AUTH_KEY_PATH"';
        final result = await runner.run('/bin/sh', const <String>[
          '-c',
          command,
        ]);
        expect(result.stdout, '||');
      },
    );

    test(
      'preserves explicitly supplied project-specific credentials',
      () async {
        const runner = SystemProcessRunner(
          parentEnvironment: <String, String>{
            'PATH': '/usr/bin:/bin',
            'CATAQUI_RELEASE_NOTES_TOKEN': 'project-secret',
            'SMF_IOS_CERTIFICATE_PASSWORD': 'signing-secret',
          },
        );
        const command =
            r'printf "%s|%s" "$CATAQUI_RELEASE_NOTES_TOKEN" '
            r'"$SMF_IOS_CERTIFICATE_PASSWORD"';
        final result = await runner.run('/bin/sh', const <String>[
          '-c',
          command,
        ]);
        expect(result.stdout, 'project-secret|');
      },
    );

    test('omits command arguments from failure messages', () async {
      expect(
        () => const SystemProcessRunner().run('/bin/sh', const <String>[
          '-c',
          'exit 1',
          'certificate-password',
        ]),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            isNot(contains('certificate-password')),
          ),
        ),
      );
    });

    test('includes bounded command diagnostics in failure messages', () async {
      await expectLater(
        const SystemProcessRunner().run('/bin/sh', const <String>[
          '-c',
          'printf "build failed safely" >&2; exit 1',
        ]),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('build failed safely'),
          ),
        ),
      );
    });
  });
}
