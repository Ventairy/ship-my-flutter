import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

Map<String, Object?> validConfig() => <String, Object?>{
  'schema_version': 1,
  'app_id': 'example',
  'target_branch': 'main',
  'platforms': <String, Object?>{
    'ios': <String, Object?>{
      'enabled': true,
      'initial_version': '1.0.0',
      'build_command': 'flutter build ipa --release',
      'ipa_output_path': 'build/ios/ipa',
      'app_store': <String, Object?>{
        'release_candidate': <String, Object?>{
          'target': 'internal-testing',
          'groups': <Object?>[],
          'wait_timeout_minutes': 45,
        },
        'ship': <String, Object?>{'target': 'production'},
      },
    },
  },
};

String repeated(String value, int count) => List<String>.filled(count, value).join();

Map<String, Object?> iosConfig(Map<String, Object?> config) {
  final platforms = config['platforms']! as Map<String, Object?>;
  return platforms['ios']! as Map<String, Object?>;
}

void main() {
  group('configuration', () {
    test('keeps the editor schema aligned with the runtime schema', () async {
      final libraryUri = await Isolate.resolvePackageUri(
        Uri.parse('package:smf_engine/smf_engine.dart'),
      );
      if (libraryUri == null) {
        fail('Could not resolve the smf_engine package root.');
      }
      final packageRoot = File.fromUri(libraryUri).parent.parent;
      final schemaFile = File.fromUri(
        packageRoot.uri.resolve('schemas/config.schema.json'),
      );
      final schema = jsonDecode(schemaFile.readAsStringSync()) as Map<String, Object?>;
      final properties = schema['properties']! as Map<String, Object?>;
      final schemaVersion = properties['schema_version']! as Map<String, Object?>;
      final platforms = properties['platforms']! as Map<String, Object?>;
      final platformProperties = platforms['properties']! as Map<String, Object?>;
      final android = platformProperties['android']! as Map<String, Object?>;
      final androidProperties = android['properties']! as Map<String, Object?>;
      final googlePlay = androidProperties['google_play']! as Map<String, Object?>;
      final googlePlayProperties = googlePlay['properties']! as Map<String, Object?>;
      final releaseCandidate = googlePlayProperties['release_candidate']! as Map<String, Object?>;
      final allOf = releaseCandidate['allOf']! as List<Object?>;
      final closedTestingCondition = allOf.first! as Map<String, Object?>;
      final condition = closedTestingCondition['if']! as Map<String, Object?>;

      expect(
        (
          schemaVersion: schemaVersion['const'],
          closedTestingRequired: jsonEncode(condition['required']),
        ),
        (
          schemaVersion: SmfConfig.currentSchemaVersion,
          closedTestingRequired: '["target"]',
        ),
      );
    });

    test('accepts the minimal generated configuration', () {
      expect(SmfState.parseConfig(validConfig()).ios.isEnabled, isTrue);
    });

    test('accepts safe release trigger paths and removes duplicates', () {
      final config = validConfig()
        ..['release_trigger_paths'] = <Object?>[
          'packages/shared/**',
          'packages/shared/**',
          'tool/release.dart',
        ];

      expect(SmfState.parseConfig(config).releaseTriggerPaths, <String>[
        'packages/shared/**',
        'tool/release.dart',
      ]);
    });

    test('rejects release trigger paths that escape the repository', () {
      final config = validConfig()..['release_trigger_paths'] = <Object?>['../shared'];

      expect(
        () => SmfState.parseConfig(config),
        throwsA(isA<SmfError>()),
      );
    });

    test('treats an omitted platform as unsupported', () {
      final config = SmfState.parseConfig(<String, Object?>{
        'schema_version': 1,
        'app_id': 'example',
        'platforms': <String, Object?>{
          'android': <String, Object?>{
            'enabled': true,
            'initial_version': '1.0.0',
          },
        },
      });

      expect(config.ios.isEnabled, isFalse);
      expect(config.android.isEnabled, isTrue);
    });

    test('accepts one optional global Flutter flavor', () {
      final config = validConfig()..['flavor'] = 'production';

      expect(SmfState.parseConfig(config).flavor, 'production');
    });

    test('rejects the removed release branch prefix', () {
      final config = validConfig()..['release_branch_prefix'] = 'releases';

      expect(
        () => SmfState.parseConfig(config),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            allOf(contains('unknown field'), contains('release_branch_prefix')),
          ),
        ),
      );
    });

    test('rejects a prerelease initial iOS version', () {
      final config = validConfig();
      iosConfig(config)['initial_version'] = '1.0.0-beta.1';

      expect(() => SmfState.parseConfig(config), throwsA(isA<SmfError>()));
    });

    test('rejects the removed iOS scheme field', () {
      final config = validConfig();
      iosConfig(config)['scheme'] = 'production';

      expect(
        () => SmfState.parseConfig(config),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            allOf(contains('unknown field'), contains('scheme')),
          ),
        ),
      );
    });

    test(
      'defaults automatic toolchain selection and the standard IPA directory',
      () {
        final config = validConfig();
        iosConfig(config)
          ..remove('build_command')
          ..remove('ipa_output_path');

        final ios = SmfState.parseConfig(config).ios;

        expect(ios.buildCommand, isNull);
        expect(ios.ipaOutputPath, 'build/ios/ipa');
      },
    );

    test('rejects unknown fields at every configuration level', () {
      final cases = <Map<String, Object?> Function()>[
        () => validConfig()..['unexpected'] = true,
        () {
          final config = validConfig();
          final platforms = config['platforms']! as Map<String, Object?>;
          platforms['web'] = <String, Object?>{};
          return config;
        },
        () {
          final config = validConfig();
          iosConfig(config)['unexpected'] = true;
          return config;
        },
        () {
          final config = validConfig();
          final appStore = iosConfig(config)['app_store']! as Map<String, Object?>;
          final releaseCandidate = appStore['release_candidate']! as Map<String, Object?>;
          releaseCandidate['unexpected'] = true;
          return config;
        },
        () {
          final config = validConfig();
          final appStore = iosConfig(config)['app_store']! as Map<String, Object?>;
          appStore['unexpected'] = true;
          return config;
        },
      ];

      for (final createConfig in cases) {
        expect(
          () => SmfState.parseConfig(createConfig()),
          throwsA(
            isA<SmfError>().having(
              (error) => error.message,
              'message',
              contains('unknown field'),
            ),
          ),
        );
      }
    });

    test('defaults to internal testing and no configured ship target', () {
      final config = validConfig();
      iosConfig(config).remove('app_store');
      final appStore = SmfState.parseConfig(config).ios.appStore;
      expect(
        appStore.releaseCandidate.target,
        AppleReleaseCandidateTarget.internalTesting,
      );
      expect(appStore.releaseCandidate.groups, isEmpty);
      expect(appStore.ship, isNull);
    });

    test('rejects IPA paths that escape the Flutter app', () {
      final config = validConfig();
      iosConfig(config)['ipa_output_path'] = '../outside/app.ipa';
      expect(() => SmfState.parseConfig(config), throwsA(isA<SmfError>()));
    });

    test('rejects unsupported App Store release-candidate targets', () {
      final config = validConfig();
      final appStore = iosConfig(config)['app_store']! as Map<String, Object?>;
      final releaseCandidate = appStore['release_candidate']! as Map<String, Object?>;
      releaseCandidate['target'] = 'private-testing';
      expect(
        () => SmfState.parseConfig(config),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('internal-testing or external-testing'),
          ),
        ),
      );
    });

    test('maps every App Store ship target to its public enum value', () {
      for (final entry in <String, AppleShipTarget>{
        'external-testing': AppleShipTarget.externalTesting,
        'submit-for-review': AppleShipTarget.submitForReview,
        'production': AppleShipTarget.production,
      }.entries) {
        final config = validConfig();
        final appStore = iosConfig(config)['app_store']! as Map<String, Object?>;
        appStore['ship'] = <String, Object?>{
          'target': entry.key,
          if (entry.value == AppleShipTarget.externalTesting) 'groups': <Object?>['Public Beta'],
        };

        expect(SmfState.parseConfig(config).ios.appStore.ship?.target, entry.value);
      }
    });

    test('requires external TestFlight groups beside their phase', () {
      final releaseCandidateConfig = validConfig();
      final releaseCandidateAppStore = iosConfig(releaseCandidateConfig)['app_store']! as Map<String, Object?>;
      releaseCandidateAppStore['release_candidate'] = <String, Object?>{
        'target': 'external-testing',
      };
      expect(() => SmfState.parseConfig(releaseCandidateConfig), throwsA(isA<SmfError>()));

      final shipConfig = validConfig();
      final shipAppStore = iosConfig(shipConfig)['app_store']! as Map<String, Object?>;
      shipAppStore['ship'] = <String, Object?>{
        'target': 'external-testing',
      };
      expect(() => SmfState.parseConfig(shipConfig), throwsA(isA<SmfError>()));
    });

    test('accepts multiple named Google Play closed-testing tracks', () {
      final config = validConfig();
      final platforms = config['platforms']! as Map<String, Object?>;
      platforms['android'] = <String, Object?>{
        'enabled': true,
        'google_play': <String, Object?>{
          'release_candidate': <String, Object?>{
            'target': 'closed-testing',
            'tracks': <Object?>['internal-qa', 'trusted-users'],
          },
          'ship': <String, Object?>{
            'target': 'closed-testing',
            'tracks': <Object?>['customer-preview'],
          },
        },
      };

      final play = SmfState.parseConfig(config).android.googlePlay;

      expect(play.releaseCandidate.tracks, <String>[
        'internal-qa',
        'trusted-users',
      ]);
      expect(play.ship?.tracks, <String>['customer-preview']);
    });

    test('rejects tracks unless the Google Play target is closed testing', () {
      final config = validConfig();
      final platforms = config['platforms']! as Map<String, Object?>;
      platforms['android'] = <String, Object?>{
        'enabled': true,
        'google_play': <String, Object?>{
          'release_candidate': <String, Object?>{
            'target': 'internal-testing',
            'tracks': <Object?>['qa'],
          },
        },
      };

      expect(() => SmfState.parseConfig(config), throwsA(isA<SmfError>()));
    });

    test('rejects removed App Store release policy fields', () {
      for (final field in <String>['release_type', 'earliest_release_date']) {
        final config = validConfig();
        final appStore = iosConfig(config)['app_store']! as Map<String, Object?>;
        appStore[field] = 'removed';
        expect(
          () => SmfState.parseConfig(config),
          throwsA(
            isA<SmfError>().having(
              (error) => error.message,
              'message',
              allOf(contains('unknown field'), contains(field)),
            ),
          ),
        );
      }
    });

    test('accepts one project-owned build command', () {
      final config = validConfig();
      iosConfig(config)['build_command'] = 'fvm dart run release:build_ios';

      final parsed = SmfState.parseConfig(config);

      expect(parsed.ios.buildCommand, contains('release:build_ios'));
    });

    test('rejects removed app path and YAML hook configuration', () {
      for (final field in <String>['app_path', 'hooks']) {
        final config = validConfig()..[field] = <String, Object?>{};
        expect(
          () => SmfState.parseConfig(config),
          throwsA(
            isA<SmfError>().having(
              (error) => error.message,
              'message',
              allOf(contains('unknown field'), contains(field)),
            ),
          ),
        );
      }
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
            () => SmfState.parseConfig(config),
            throwsA(
              isA<SmfError>().having(
                (error) => error.message,
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
            'flutter build ipa '
            '--dart-define="URL=https://example.test?a=1&b=2" '
            r'--dart-define=LABEL=release\;candidate';

        expect(
          SmfState.parseConfig(config).ios.buildCommand,
          contains(r'release\;candidate'),
        );
      },
    );

    test('rejects release arguments managed by smf', () {
      for (final flag in <String>[
        '--build-name 9.9.9',
        "'--build-name=9.9.9'",
        '--build-number=99',
        '"--build-number=99"',
        '--export-options-plist custom.plist',
        '--dart-define=FORBIDDEN=--export-options-plist',
        '--flavor production',
      ]) {
        final config = validConfig();
        iosConfig(config)['build_command'] = 'flutter build ipa $flag';
        expect(
          () => SmfState.parseConfig(config),
          throwsA(
            isA<SmfError>().having(
              (error) => error.message,
              'message',
              contains('appends it automatically'),
            ),
          ),
        );
      }
    });

    test('rejects configuration contracts outside schema v1', () {
      final config = validConfig()..['schema_version'] = 0;

      expect(
        () => SmfState.parseConfig(config),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('schema_version must be 1'),
          ),
        ),
      );
    });

    test('rejects iOS prerelease versions', () {
      expect(
        () => SmfState.parseManifest(<String, Object?>{
          'schemaVersion': 1,
          'platforms': <String, Object?>{
            'ios': <String, Object?>{
              'version': '2.0.0-beta.1',
              'endCommitHash': repeated('a', 40),
              'isReleasePending': false,
            },
            'android': <String, Object?>{
              'version': '1.0.0',
              'endCommitHash': repeated('a', 40),
              'isReleasePending': false,
            },
          },
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('stable major.minor.patch'),
          ),
        ),
      );
    });

    test('rejects duplicate changelog versions and empty localized notes', () {
      final release = <String, Object?>{
        'version': '1.2.3',
        'preparedAt': '2026-07-26T00:00:00.000Z',
        'baseCommitHash': repeated('a', 40),
        'endCommitHash': repeated('b', 40),
        'changes': <Object?>[
          <String, Object?>{
            'commitHash': repeated('c', 40),
            'type': 'fix',
            'scope': 'ios',
            'description': 'Fix launch',
            'body': null,
            'isBreaking': false,
            'versionBumpType': 'patch',
            'platforms': <Object?>['ios'],
          },
        ],
      };
      expect(
        () => SmfState.parseChangelog(<String, Object?>{
          'schemaVersion': 1,
          'platforms': <String, Object?>{
            'ios': <String, Object?>{
              'releases': <Object?>[release, Map<String, Object?>.of(release)],
            },
            'android': <String, Object?>{'releases': <Object?>[]},
          },
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('duplicate version 1.2.3'),
          ),
        ),
      );
      expect(
        () => SmfState.parseStoreReleaseNotes(<String, Object?>{
          'ios': <String, Object?>{
            '1.2.3': <String, Object?>{'en-US': ''},
          },
        }),
        throwsA(isA<SmfError>()),
      );
    });

    test('rejects manifests without every platform object', () {
      expect(
        () => SmfState.parseManifest(<String, Object?>{
          'schemaVersion': 1,
          'platforms': <String, Object?>{
            'ios': <String, Object?>{
              'version': '1.0.0',
              'endCommitHash': repeated('a', 40),
              'isReleasePending': false,
            },
          },
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('platforms.android must be an object'),
          ),
        ),
      );
    });

    test('rejects unknown manifest fields', () {
      expect(
        () => SmfState.parseManifest(<String, Object?>{
          'schemaVersion': 1,
          'platforms': <String, Object?>{
            'ios': <String, Object?>{
              'version': '1.0.0',
              'endCommitHash': repeated('a', 40),
              'isReleasePending': false,
              'legacy': true,
            },
            'android': <String, Object?>{
              'version': '1.0.0',
              'endCommitHash': repeated('a', 40),
              'isReleasePending': false,
            },
          },
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('platforms.ios contains unknown field "legacy"'),
          ),
        ),
      );
    });

    test('accepts pre-v1 manifest field names', () {
      final manifest = SmfState.parseManifest(<String, Object?>{
        'schemaVersion': 1,
        'platforms': <String, Object?>{
          'ios': <String, Object?>{
            'version': '1.2.0',
            'baselineSha': repeated('a', 40),
            'pendingRelease': true,
          },
          'android': <String, Object?>{
            'version': '1.0.0',
            'baselineSha': repeated('b', 40),
            'pendingRelease': false,
          },
        },
      });

      expect(
        (
          iosCommit: manifest.platforms.ios.endCommitHash,
          iosPending: manifest.platforms.ios.isReleasePending,
          androidCommit: manifest.platforms.android.endCommitHash,
          androidPending: manifest.platforms.android.isReleasePending,
        ),
        (
          iosCommit: repeated('a', 40),
          iosPending: true,
          androidCommit: repeated('b', 40),
          androidPending: false,
        ),
      );
    });

    test('rejects mixed current and pre-v1 manifest field names', () {
      expect(
        () => SmfState.parseManifest(<String, Object?>{
          'schemaVersion': 1,
          'platforms': <String, Object?>{
            'ios': <String, Object?>{
              'version': '1.2.0',
              'endCommitHash': repeated('a', 40),
              'pendingRelease': true,
            },
            'android': <String, Object?>{
              'version': '1.0.0',
              'endCommitHash': repeated('b', 40),
              'isReleasePending': false,
            },
          },
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains(
              'platforms.ios must not mix current and pre-v1 '
              'manifest field names',
            ),
          ),
        ),
      );
    });

    test('rejects changelogs without every platform object', () {
      expect(
        () => SmfState.parseChangelog(<String, Object?>{
          'schemaVersion': 1,
          'platforms': <String, Object?>{
            'ios': <String, Object?>{'releases': <Object?>[]},
          },
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('platforms.android must be an object'),
          ),
        ),
      );
    });

    test('rejects unknown changelog fields', () {
      expect(
        () => SmfState.parseChangelog(<String, Object?>{
          'schemaVersion': 1,
          'platforms': <String, Object?>{
            'ios': <String, Object?>{
              'releases': <Object?>[],
              'legacy': true,
            },
            'android': <String, Object?>{'releases': <Object?>[]},
          },
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('platforms.ios contains unknown field "legacy"'),
          ),
        ),
      );
    });

    test('accepts the complete pre-v1 changelog shape', () {
      final changelog = SmfState.parseChangelog(<String, Object?>{
        'schemaVersion': 1,
        'platforms': <String, Object?>{
          'ios': <String, Object?>{
            'releases': <String, Object?>{
              '1.2.0': <String, Object?>{
                'version': '1.2.0',
                'preparedAt': '2026-07-28T17:04:40.224001Z',
                'baseSha': repeated('a', 40),
                'headSha': repeated('b', 40),
                'changes': <Object?>[
                  <String, Object?>{
                    'sha': repeated('c', 40),
                    'type': 'feat',
                    'scope': 'ios',
                    'description': 'verify the release',
                    'body': null,
                    'breaking': false,
                    'versionBump': 'minor',
                    'platforms': <Object?>['ios'],
                  },
                ],
              },
            },
          },
          'android': <String, Object?>{
            'releases': <String, Object?>{},
          },
        },
      });
      final release = changelog.platforms.ios.releases.single;
      final change = release.changes.single;

      expect(
        (
          version: release.version,
          baseCommitHash: release.baseCommitHash,
          endCommitHash: release.endCommitHash,
          commitHash: change.commitHash,
          isBreaking: change.isBreaking,
          versionBumpType: change.versionBumpType,
          platforms: change.platforms.map((platform) => platform.value).join(),
          androidReleaseCount: changelog.platforms.android.releases.length,
        ),
        (
          version: '1.2.0',
          baseCommitHash: repeated('a', 40),
          endCommitHash: repeated('b', 40),
          commitHash: repeated('c', 40),
          isBreaking: false,
          versionBumpType: VersionBumpType.minor,
          platforms: 'ios',
          androidReleaseCount: 0,
        ),
      );
    });

    test('rejects a pre-v1 changelog whose version disagrees with its key', () {
      expect(
        () => SmfState.parseChangelog(<String, Object?>{
          'schemaVersion': 1,
          'platforms': <String, Object?>{
            'ios': <String, Object?>{
              'releases': <String, Object?>{
                '1.2.0': <String, Object?>{
                  'version': '1.3.0',
                  'preparedAt': '2026-07-28T17:04:40.224001Z',
                  'baseSha': repeated('a', 40),
                  'headSha': repeated('b', 40),
                  'changes': <Object?>[
                    <String, Object?>{
                      'sha': repeated('c', 40),
                      'type': 'feat',
                      'scope': null,
                      'description': 'verify the release',
                      'body': null,
                      'breaking': false,
                      'versionBump': 'minor',
                      'platforms': <Object?>['ios'],
                    },
                  ],
                },
              },
            },
            'android': <String, Object?>{
              'releases': <String, Object?>{},
            },
          },
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains(
              'platforms.ios.releases.1.2.0.version must match its '
              'release key 1.2.0',
            ),
          ),
        ),
      );
    });

    test('enforces platform-specific store release note limits', () {
      expect(
        () => SmfState.parseStoreReleaseNotes(<String, Object?>{
          'android': <String, Object?>{
            '1.2.3': <String, Object?>{'en-US': repeated('a', 500)},
          },
          'ios': <String, Object?>{
            '1.2.3': <String, Object?>{'en-US': repeated('a', 4000)},
          },
        }),
        returnsNormally,
      );
      expect(
        () => SmfState.parseStoreReleaseNotes(<String, Object?>{
          'android': <String, Object?>{
            '1.2.3': <String, Object?>{'en-US': repeated('a', 501)},
          },
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('android.1.2.3.en-US must be at most 500 characters'),
          ),
        ),
      );
      expect(
        () => SmfState.parseStoreReleaseNotes(<String, Object?>{
          'ios': <String, Object?>{
            '1.2.3': <String, Object?>{'en-US': repeated('a', 4001)},
          },
        }),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('ios.1.2.3.en-US must be at most 4000 characters'),
          ),
        ),
      );
    });
  });
}
