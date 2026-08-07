import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/apple.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

import 'support/fake_app_store.dart';

const encoder = JsonEncoder.withIndent('  ');

Future<void> writeObject(String path, Object? value) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString('${encoder.convert(value)}\n');
}

void main() {
  test(
    'reuses a valid build and submits configured external testing',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-release-candidate-');
      final origin = await Directory.systemTemp.createTemp(
        'smf-release-candidate-origin-',
      );
      addTearDown(() async {
        await root.delete(recursive: true);
        await origin.delete(recursive: true);
      });
      await GitClient(root: origin.path).run(const <String>['init', '--bare']);
      await Directory(p.join(root.path, 'ios')).create();
      await File(
        p.join(root.path, 'pubspec.yaml'),
      ).writeAsString('name: example\nversion: 1.0.0+1\n');
      await File(
        p.join(root.path, 'pubspec.lock'),
      ).writeAsString('# fixture lockfile\n');
      await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
      await GitClient(root: root.path).run(const <String>['config', 'user.name', 'Test']);
      await GitClient(root: root.path).run(const <String>[
        'config',
        'user.email',
        'test@example.com',
      ]);
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>['commit', '-m', 'chore: bootstrap']);
      await RepositoryInitializer.initialize(
        InitOptions(appRoot: root.path, iosBundleId: 'dev.example.app'),
      );
      final paths = SmfPaths.resolve(root.path);
      final configFile = File(paths.config);
      await configFile.writeAsString(
        (await configFile.readAsString())
            .replaceFirst(
              '        target: internal-testing',
              '        target: external-testing',
            )
            .replaceFirst(
              '        groups: []',
              '        groups:\n'
                  '          - Public Beta',
            ),
      );
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>[
        'commit',
        '-m',
        'chore: configure releases',
      ]);
      await GitClient(root: root.path).run(<String>['remote', 'add', 'origin', origin.path]);
      await GitClient(root: root.path).run(const <String>['push', '-u', 'origin', 'main']);
      await GitClient(root: root.path).run(
        const <String>['checkout', '-b', 'smf/example/release'],
      );
      final endCommitHash = await GitClient(root: root.path).currentCommitHash();
      final manifest = ManifestDto(
        schemaVersion: 1,
        platforms: ManifestPlatformsDto(
          ios: PlatformManifestDto(
            version: '1.1.0',
            endCommitHash: endCommitHash,
            isReleasePending: true,
          ),
          android: PlatformManifestDto(
            version: '0.0.0',
            endCommitHash: endCommitHash,
            isReleasePending: false,
          ),
        ),
      );
      await writeObject(paths.manifest, manifest.toJson());
      await writeObject(paths.storeReleaseNotes, <String, Object?>{
        'ios': <String, Object?>{
          '1.1.0': <String, Object?>{'en-US': 'Try the refreshed notes.'},
        },
      });
      final changelog = ChangelogDto(
        schemaVersion: 1,
        platforms: ChangelogPlatformsDto(
          ios: ChangelogPlatformDto(
            releases: <ChangelogPlatformReleaseVersionDto>[
              ChangelogPlatformReleaseVersionDto(
                version: '1.1.0',
                preparedAt: DateTime.utc(2026, 7, 26),
                baseCommitHash: endCommitHash,
                endCommitHash: endCommitHash,
                changes: <ConventionalChangeDto>[
                  ConventionalChangeDto(
                    commitHash: endCommitHash,
                    type: 'feat',
                    scope: 'ios',
                    description: 'Fixture release',
                    body: null,
                    isBreaking: false,
                    versionBumpType: VersionBumpType.minor,
                    platforms: const <ReleasePlatform>[ReleasePlatform.ios],
                  ),
                ],
              ),
            ],
          ),
          android: const ChangelogPlatformDto(
            releases: <ChangelogPlatformReleaseVersionDto>[],
          ),
        ),
      );
      await writeObject(paths.changelog, changelog.toJson());
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>[
        'commit',
        '-m',
        'chore(ios): prepare fixture release',
      ]);
      final sourceCommitHash = await GitClient(root: root.path).currentCommitHash();
      final fingerprint = await SourceFingerprint.calculate(root.path);
      final receipt = ReleaseCandidateReceiptDto(
        schemaVersion: 1,
        platform: ReleasePlatform.ios,
        version: '1.1.0',
        buildNumber: '7',
        artifactId: 'build-7',
        applicationId: 'dev.example.app',
        storeApplicationId: 'app-1',
        sourceCommitHash: sourceCommitHash,
        sourceFingerprint: fingerprint,
        artifactSha256: List<String>.filled(64, 'a').join(),
        uploadedAt: DateTime.utc(2026, 7, 26),
        testingDestinations: const <String>[],
        processingState: 'VALID',
      );
      await writeObject(
        paths.releaseCandidateReceiptPath(
          platform: ReleasePlatform.ios,
          version: '1.1.0',
        ),
        receipt.toJson(),
      );
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>[
        'commit',
        '-m',
        'chore(ios): record fixture release candidate',
      ]);
      await GitClient(root: root.path).run(
        const <String>['push', '-u', 'origin', 'smf/example/release'],
      );
      final client = FakeAppStoreConnectApi(
        builds: const <ApiResourceDto<BuildAttributesDto>>[
          ApiResourceDto<BuildAttributesDto>(
            type: 'builds',
            id: 'build-7',
            attributes: BuildAttributesDto(
              version: '7',
              processingState: BuildProcessingState.valid,
            ),
          ),
        ],
      );
      var didReleaseCandidateHookRun = false;

      final reused = await AppleReleaseCandidate.create(
        AppleReleaseCandidateOptions(
          workingDirectory: root.path,
          appleCredentials: const AppleCredentials(
            keyId: 'unused',
            issuerId: 'unused',
            privateKey: 'unused',
          ),
          signingCredentials: const AppleSigningCredentials(
            certificateBase64: 'unused',
            certificatePassword: 'unused',
          ),
          client: client,
          dependencies: AppleReleaseCandidateDependencies(
            runBeforeBuild: ({required workingDirectory}) async {
              didReleaseCandidateHookRun = true;
              await writeObject(paths.storeReleaseNotes, <String, Object?>{
                'ios': <String, Object?>{
                  '1.1.0': <String, Object?>{
                    'en-US': 'Generated immediately before the build.',
                  },
                },
              });
              return true;
            },
          ),
        ),
      );

      expect(didReleaseCandidateHookRun, isTrue);
      expect(reused.artifactId, receipt.artifactId);
      expect(reused.testingDestinations, <String>['Public Beta']);
      expect(client.groupAssignments.single.groups, <String>['Public Beta']);
      expect(client.isBetaSubmitted, isTrue);
      expect(client.betaNotes.single.locale, 'en-US');
      expect(
        client.betaNotes.single.whatsNew,
        'Generated immediately before the build.',
      );
      expect(
        await GitClient(root: origin.path).run(const <String>[
          'show',
          'smf/example/release:smf/store-release-notes.json',
        ]),
        contains('Generated immediately before the build.'),
      );
      expect(
        await GitClient(root: root.path).run(const <String>['log', '-2', '--pretty=%s']),
        'chore(ios): record store release candidate 1.1.0\n'
        'chore(ios): apply before_build hook for 1.1.0',
      );
      expect(client.isClosed, isFalse);

      final receiptPath = paths.releaseCandidateReceiptPath(
        platform: ReleasePlatform.ios,
        version: '1.1.0',
      );
      final intentPath = paths.releaseCandidateIntentPath(
        platform: ReleasePlatform.ios,
        version: '1.1.0',
      );
      await File(receiptPath).delete();
      await writeObject(
        intentPath,
        ReleaseCandidateIntentDto(
          schemaVersion: 1,
          platform: ReleasePlatform.ios,
          version: '1.1.0',
          buildNumber: '7',
          applicationId: 'dev.example.app',
          storeApplicationId: 'app-1',
          sourceCommitHash: await GitClient(root: root.path).currentCommitHash(),
          sourceFingerprint: await SourceFingerprint.calculate(root.path),
          artifactSha256: receipt.artifactSha256,
          preparedAt: DateTime.utc(2026, 7, 26),
        ).toJson(),
      );
      await GitClient(root: root.path).run(const <String>['add', '--all']);
      await GitClient(root: root.path).run(const <String>[
        'commit',
        '-m',
        'test: preserve interrupted upload intent',
      ]);
      await GitClient(root: root.path).run(
        const <String>['push', 'origin', 'smf/example/release'],
      );

      final recovered = await AppleReleaseCandidate.create(
        AppleReleaseCandidateOptions(
          workingDirectory: root.path,
          appleCredentials: const AppleCredentials(
            keyId: 'unused',
            issuerId: 'unused',
            privateKey: 'unused',
          ),
          signingCredentials: const AppleSigningCredentials(
            certificateBase64: 'unused',
            certificatePassword: 'unused',
          ),
          client: client,
          dependencies: AppleReleaseCandidateDependencies(
            runBeforeBuild: ({required workingDirectory}) async => false,
            upload: ({required ipaPath, required credentials}) async {
              fail('a recovered App Store build must not be uploaded again');
            },
          ),
        ),
      );

      expect(recovered.artifactId, 'build-7');
      expect(await File(intentPath).exists(), isFalse);
      expect(await File(receiptPath).exists(), isTrue);
      expect(
        await GitClient(root: origin.path).run(const <String>[
          'show',
          'smf/example/release:smf/release_candidates/ios-1.1.0.json',
        ]),
        contains('"artifactId": "build-7"'),
      );
      expect(
        await GitClient(root: origin.path).run(
          const <String>[
            'show',
            'smf/example/release:smf/release_candidates/ios-1.1.0.intent.json',
          ],
          isFailureAllowed: true,
        ),
        isEmpty,
      );

      await GitClient(root: root.path).run(const <String>['checkout', 'main']);
      await expectLater(
        AppleReleaseCandidate.create(
          AppleReleaseCandidateOptions(
            workingDirectory: root.path,
            appleCredentials: const AppleCredentials(
              keyId: 'unused',
              issuerId: 'unused',
              privateKey: 'unused',
            ),
            signingCredentials: const AppleSigningCredentials(
              certificateBase64: 'unused',
              certificatePassword: 'unused',
            ),
            client: client,
          ),
        ),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('only runs on smf/example/release'),
          ),
        ),
      );
    },
  );
}
