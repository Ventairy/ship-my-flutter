import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smf_android/smf_android.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('commits edits without canceling an in-progress Play review', () async {
    late http.Request captured;
    final client = GooglePlayClient.authenticated(
      MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      }),
    );
    addTearDown(client.close);

    await client.commitEdit(
      'dev.example.app',
      'edit-1',
      changesNotSentForReview: false,
    );

    expect(captured.method, 'POST');
    expect(
      captured.url.path,
      '/androidpublisher/v3/applications/dev.example.app/edits/edit-1:commit',
    );
    expect(
      captured.url.queryParameters,
      <String, String>{
        'changesNotSentForReview': 'false',
        'changesInReviewBehavior': 'ERROR_IF_IN_REVIEW',
      },
    );
  });

  test('maps structured Google Play commit errors to a safe failure', () async {
    final client = GooglePlayClient.authenticated(
      MockClient(
        (_) async => http.Response(
          jsonEncode(<String, Object?>{
            'error': <String, Object?>{'message': 'Review already running'},
          }),
          409,
        ),
      ),
    );
    addTearDown(client.close);

    await expectLater(
      client.commitEdit(
        'dev.example.app',
        'edit-1',
        changesNotSentForReview: false,
      ),
      throwsA(
        isA<SmfError>()
            .having((error) => error.code, 'code', 'GOOGLE_PLAY_API')
            .having(
              (error) => error.message,
              'message',
              contains('Review already running'),
            ),
      ),
    );
  });
}
