import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

Map<String, Object?> validConfig() => <String, Object?>{
  'schema_version': 2,
  'target_branch': 'main',
  'release_branch_prefix': 'ship-my-flutter',
  'hooks': <String, Object?>{},
  'platforms': <String, Object?>{
    'ios': <String, Object?>{
      'enabled': true,
      'project_path': '.',
      'build_command': 'flutter build ipa --release',
      'artifact_path': 'build/ios/ipa',
      'testflight': <String, Object?>{
        'groups': <Object?>[],
        'wait_timeout_minutes': 45,
      },
      'app_store': <String, Object?>{
        'mode': 'submit-for-review',
        'release_type': 'manual',
      },
    },
  },
};

String repeated(String value, int count) =>
    List<String>.filled(count, value).join();

Map<String, Object?> iosConfig(Map<String, Object?> config) {
  final platforms = config['platforms']! as Map<String, Object?>;
  return platforms['ios']! as Map<String, Object?>;
}

void main() {
  group('configuration', () {
    test('accepts the minimal generated configuration', () {
      expect(validateConfig(validConfig()).ios.enabled, isTrue);
    });

    test(
      'defaults the standard Flutter IPA command and artifact directory',
      () {
        final config = validConfig();
        iosConfig(config)
          ..remove('build_command')
          ..remove('artifact_path');

        final ios = validateConfig(config).ios;

        expect(ios.buildCommand, 'flutter build ipa --release');
        expect(ios.artifactPath, 'build/ios/ipa');
      },
    );

    test('rejects unknown fields at every configuration level', () {
      final cases = <Map<String, Object?> Function()>[
        () => validConfig()..['unexpected'] = true,
        () {
          final config = validConfig();
          final hooks = config['hooks']! as Map<String, Object?>;
          hooks['unexpected'] = true;
          return config;
        },
        () {
          final config = validConfig();
          final platforms = config['platforms']! as Map<String, Object?>;
          platforms['android'] = <String, Object?>{};
          return config;
        },
        () {
          final config = validConfig();
          iosConfig(config)['unexpected'] = true;
          return config;
        },
        () {
          final config = validConfig();
          final testflight =
              iosConfig(config)['testflight']! as Map<String, Object?>;
          testflight['unexpected'] = true;
          return config;
        },
        () {
          final config = validConfig();
          final appStore =
              iosConfig(config)['app_store']! as Map<String, Object?>;
          appStore['unexpected'] = true;
          return config;
        },
      ];

      for (final createConfig in cases) {
        expect(
          () => validateConfig(createConfig()),
          throwsA(
            isA<ShipError>().having(
              (ShipError error) => error.message,
              'message',
              contains('unknown field'),
            ),
          ),
        );
      }
    });

    test('defaults omitted App Store behavior to upload only', () {
      final config = validConfig();
      iosConfig(config).remove('app_store');
      final appStore = validateConfig(config).ios.appStore;
      expect(appStore.mode, ReleaseMode.uploadOnly);
      expect(appStore.releaseType, StoreReleaseType.manual);
    });

    test('rejects paths that escape the repository', () {
      final config = validConfig();
      iosConfig(config)['project_path'] = '../another-app';
      expect(() => validateConfig(config), throwsA(isA<ShipError>()));

      final artifactConfig = validConfig();
      iosConfig(artifactConfig)['artifact_path'] = '../outside/app.ipa';
      expect(() => validateConfig(artifactConfig), throwsA(isA<ShipError>()));
    });

    test('rejects unsupported App Store modes', () {
      final config = validConfig();
      final appStore = iosConfig(config)['app_store']! as Map<String, Object?>;
      appStore['mode'] = 'publish-now';
      expect(
        () => validateConfig(config),
        throwsA(
          isA<ShipError>().having(
            (ShipError error) => error.message,
            'message',
            contains('submit-for-review'),
          ),
        ),
      );
    });

    test('requires a date only for scheduled App Store releases', () {
      final missingDate = validConfig();
      final scheduled =
          iosConfig(missingDate)['app_store']! as Map<String, Object?>;
      scheduled['release_type'] = 'scheduled';
      expect(
        () => validateConfig(missingDate),
        throwsA(
          isA<ShipError>().having(
            (ShipError error) => error.message,
            'message',
            contains('required when release_type is scheduled'),
          ),
        ),
      );

      final unexpectedDate = validConfig();
      final manual =
          iosConfig(unexpectedDate)['app_store']! as Map<String, Object?>;
      manual['earliest_release_date'] = '2026-08-01T12:00:00.000Z';
      expect(
        () => validateConfig(unexpectedDate),
        throwsA(
          isA<ShipError>().having(
            (ShipError error) => error.message,
            'message',
            contains('only valid when release_type is scheduled'),
          ),
        ),
      );
    });

    test('accepts project-owned shell commands and hooks', () {
      final config = validConfig();
      iosConfig(config)['build_command'] = 'fvm dart run release:build_ios';
      final hooks = config['hooks']! as Map<String, Object?>;
      hooks['before_release_pr'] =
          'fvm dart run release:notes && test -f "\$OUTPUT"';
      hooks['before_candidate'] =
          'fvm dart run release:prepare | tee prepare.log';

      final parsed = validateConfig(config);

      expect(parsed.ios.buildCommand, contains('release:build_ios'));
      expect(parsed.hooks.beforeReleasePr, contains('release:notes'));
      expect(parsed.hooks.beforeCandidate, contains('release:prepare'));
    });

    test(
      'rejects build command composition that could steal managed flags',
      () {
        for (final command in <String>[
          'flutter build ipa && test -f build/app.ipa',
          'flutter build ipa | tee build.log',
          'flutter build ipa; echo done',
          'flutter build ipa > build.log',
          'flutter build ipa # release',
          'flutter build ipa\nprintf done',
          r'flutter build ipa $(printf extra)',
          'flutter build ipa `printf extra`',
          r'flutter build ipa "--dart-define=VALUE=$(printf extra)"',
          'flutter build ipa "--dart-define=VALUE=`printf extra`"',
        ]) {
          final config = validConfig();
          iosConfig(config)['build_command'] = command;
          expect(
            () => validateConfig(config),
            throwsA(
              isA<ShipError>().having(
                (ShipError error) => error.message,
                'message',
                contains('must be one shell command invocation'),
              ),
            ),
            reason: command,
          );
        }
      },
    );

    test(
      'allows quoted or escaped shell metacharacters in build arguments',
      () {
        final config = validConfig();
        iosConfig(config)['build_command'] =
            r'flutter build ipa '
            r'--dart-define="URL=https://example.test?a=1&b=2" '
            r'--dart-define=LABEL=release\;candidate';

        expect(
          validateConfig(config).ios.buildCommand,
          contains('release\\;candidate'),
        );
      },
    );

    test('rejects release arguments managed by ship-my-flutter', () {
      for (final flag in <String>[
        '--build-name 9.9.9',
        "'--build-name=9.9.9'",
        '--build-number=99',
        '"--build-number=99"',
        '--export-options-plist custom.plist',
        r'--dart-define=FORBIDDEN=--export-options-plist',
        '--flavor production',
      ]) {
        final config = validConfig();
        iosConfig(config)['build_command'] = 'flutter build ipa $flag';
        expect(
          () => validateConfig(config),
          throwsA(
            isA<ShipError>().having(
              (ShipError error) => error.message,
              'message',
              contains('appends it automatically'),
            ),
          ),
        );
      }
    });

    test('rejects the camelCase version 1 configuration contract', () {
      final config = validConfig()
        ..remove('schema_version')
        ..['schemaVersion'] = 1;

      expect(
        () => validateConfig(config),
        throwsA(
          isA<ShipError>().having(
            (ShipError error) => error.message,
            'message',
            contains('Migrate camelCase configuration keys to snake_case'),
          ),
        ),
      );
    });

    test('rejects iOS prerelease versions', () {
      expect(
        () => validateManifest(<String, Object?>{
          'schemaVersion': 1,
          'platforms': <String, Object?>{
            'ios': <String, Object?>{
              'version': '2.0.0-beta.1',
              'baselineSha': repeated('a', 40),
              'pendingRelease': false,
            },
          },
        }),
        throwsA(
          isA<ShipError>().having(
            (ShipError error) => error.message,
            'message',
            contains('stable major.minor.patch'),
          ),
        ),
      );
    });

    test('validates changelog identity and nonempty localized notes', () {
      expect(
        () => validateChangelog(<String, Object?>{
          'schemaVersion': 1,
          'platforms': <String, Object?>{
            'ios': <String, Object?>{
              'releases': <String, Object?>{
                '1.2.3': <String, Object?>{
                  'version': '1.2.4',
                  'preparedAt': '2026-07-26T00:00:00.000Z',
                  'baseSha': repeated('a', 40),
                  'headSha': repeated('b', 40),
                  'changes': <Object?>[
                    <String, Object?>{
                      'sha': repeated('c', 40),
                      'type': 'fix',
                      'scope': 'ios',
                      'description': 'Fix launch',
                      'body': null,
                      'breaking': false,
                      'bump': 'patch',
                      'platforms': <Object?>['ios'],
                    },
                  ],
                },
              },
            },
          },
        }),
        throwsA(
          isA<ShipError>().having(
            (ShipError error) => error.message,
            'message',
            contains('must match its release key'),
          ),
        ),
      );
      expect(
        () => validateStoreReleaseNotes(<String, Object?>{
          'ios': <String, Object?>{
            '1.2.3': <String, Object?>{'en-US': ''},
          },
        }),
        throwsA(isA<ShipError>()),
      );
    });
  });
}
