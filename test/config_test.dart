import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

Map<String, Object?> validConfig() => <String, Object?>{
  'schemaVersion': 1,
  'targetBranch': 'main',
  'releaseBranchPrefix': 'ship-my-flutter',
  'hooks': <String, Object?>{},
  'platforms': <String, Object?>{
    'ios': <String, Object?>{
      'enabled': true,
      'projectPath': '.',
      'buildArgs': <Object?>[],
      'testflight': <String, Object?>{
        'groups': <Object?>[],
        'waitTimeoutMinutes': 45,
      },
      'appStore': <String, Object?>{
        'mode': 'submit-for-review',
        'releaseType': 'manual',
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

    test('defaults omitted App Store behavior to upload only', () {
      final config = validConfig();
      iosConfig(config).remove('appStore');
      final appStore = validateConfig(config).ios.appStore;
      expect(appStore.mode, ReleaseMode.uploadOnly);
      expect(appStore.releaseType, StoreReleaseType.manual);
    });

    test('rejects paths that escape the repository', () {
      final config = validConfig();
      iosConfig(config)['projectPath'] = '../another-app';
      expect(() => validateConfig(config), throwsA(isA<ShipError>()));
    });

    test('rejects unsupported App Store modes', () {
      final config = validConfig();
      final appStore = iosConfig(config)['appStore']! as Map<String, Object?>;
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
          iosConfig(missingDate)['appStore']! as Map<String, Object?>;
      scheduled['releaseType'] = 'scheduled';
      expect(
        () => validateConfig(missingDate),
        throwsA(
          isA<ShipError>().having(
            (ShipError error) => error.message,
            'message',
            contains('required when releaseType is scheduled'),
          ),
        ),
      );

      final unexpectedDate = validConfig();
      final manual =
          iosConfig(unexpectedDate)['appStore']! as Map<String, Object?>;
      manual['earliestReleaseDate'] = '2026-08-01T12:00:00.000Z';
      expect(
        () => validateConfig(unexpectedDate),
        throwsA(
          isA<ShipError>().having(
            (ShipError error) => error.message,
            'message',
            contains('only valid when releaseType is scheduled'),
          ),
        ),
      );
    });

    test('does not allow custom arguments to override release identity', () {
      final config = validConfig();
      iosConfig(config)['buildArgs'] = <Object?>['--build-number=99'];
      expect(
        () => validateConfig(config),
        throwsA(
          isA<ShipError>().having(
            (ShipError error) => error.message,
            'message',
            contains('managed by ship-my-flutter'),
          ),
        ),
      );
      iosConfig(config)['buildArgs'] = <Object?>['--pub'];
      expect(() => validateConfig(config), throwsA(isA<ShipError>()));
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
