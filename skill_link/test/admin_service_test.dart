import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skill_link/services/admin_service.dart';

void main() {
  group('AdminService gateway integration', () {
    const testBaseUrl = 'https://gateway.test/admin-registrations';

    test(
      'listRegistrations succeeds with valid token and returns registrations',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('POST'));
          expect(
            request.url.toString(),
            equals('$testBaseUrl/admin/registrations/list'),
          );
          expect(request.headers['authorization'], equals('Bearer test-token'));
          expect(request.headers['content-type'], contains('application/json'));
          expect(request.headers['accept'], contains('application/json'));
          expect(request.body, equals('{}'));

          return http.Response(
            jsonEncode({
              'registrations': [
                {
                  'id': 'reg-1',
                  'fullName': 'Abebe Bikila',
                  'category': 'Plumbing',
                  'status': 'pending',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final service = AdminService(
          client: mockClient,
          tokenProvider: ({bool forceRefresh = false}) async => 'test-token',
          baseUrl: testBaseUrl,
        );

        final list = await service.listRegistrations();
        expect(list, hasLength(1));
        expect(list.first['id'], equals('reg-1'));
        expect(list.first['fullName'], equals('Abebe Bikila'));
        expect(list.first['status'], equals('pending'));
      },
    );

    test('review succeeds and validates response payload', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.toString(),
          equals('$testBaseUrl/admin/registrations/review'),
        );
        expect(request.headers['authorization'], equals('Bearer test-token'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['registrationId'], equals('reg-1'));
        expect(body['decision'], equals('approved'));
        expect(body['rejectionReason'], isNull);

        return http.Response(
          jsonEncode({'id': 'reg-1', 'status': 'approved'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AdminService(
        client: mockClient,
        tokenProvider: ({bool forceRefresh = false}) async => 'test-token',
        baseUrl: testBaseUrl,
      );

      await expectLater(
        service.review(registrationId: 'reg-1', decision: 'approved'),
        completes,
      );
    });

    test('on 401, force-refreshes token and retries at most once', () async {
      var callCount = 0;
      final tokensUsed = <String>[];
      final forceRefreshHistory = <bool>[];

      final mockClient = MockClient((request) async {
        callCount++;
        final authHeader = request.headers['authorization'] ?? '';
        tokensUsed.add(authHeader);

        if (callCount == 1) {
          return http.Response(
            jsonEncode({'error': 'The authentication token is invalid.'}),
            401,
          );
        }

        return http.Response(jsonEncode({'registrations': []}), 200);
      });

      final service = AdminService(
        client: mockClient,
        tokenProvider: ({bool forceRefresh = false}) async {
          forceRefreshHistory.add(forceRefresh);
          return forceRefresh ? 'fresh-refreshed-token' : 'expired-token';
        },
        baseUrl: testBaseUrl,
      );

      final result = await service.listRegistrations();
      expect(result, isEmpty);
      expect(callCount, equals(2));
      expect(forceRefreshHistory, equals([false, true]));
      expect(
        tokensUsed,
        equals(['Bearer expired-token', 'Bearer fresh-refreshed-token']),
      );
    });

    test(
      'on 401 when retry also returns 401, fails without infinite loop',
      () async {
        var callCount = 0;

        final mockClient = MockClient((request) async {
          callCount++;
          return http.Response(
            jsonEncode({'error': 'The authentication token is invalid.'}),
            401,
          );
        });

        final service = AdminService(
          client: mockClient,
          tokenProvider: ({bool forceRefresh = false}) async =>
              forceRefresh ? 'still-bad-token' : 'expired-token',
          baseUrl: testBaseUrl,
        );

        await expectLater(
          service.listRegistrations(),
          throwsA(
            isA<AdminGatewayException>().having(
              (e) => e.statusCode,
              'statusCode',
              401,
            ),
          ),
        );
        expect(callCount, equals(2)); // exactly 1 initial + 1 retry
      },
    );

    test(
      'on 403, throws AdminGatewayException with administrator permission message',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'Administrator access is required.'}),
            403,
          );
        });

        final service = AdminService(
          client: mockClient,
          tokenProvider: ({bool forceRefresh = false}) async =>
              'non-admin-token',
          baseUrl: testBaseUrl,
        );

        await expectLater(
          service.listRegistrations(),
          throwsA(
            isA<AdminGatewayException>()
                .having((e) => e.statusCode, 'statusCode', 403)
                .having(
                  (e) => e.message,
                  'message',
                  contains('Administrator access is required'),
                ),
          ),
        );
      },
    );

    test('on 400, throws validation error', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'A valid registration decision is required.'}),
          400,
        );
      });

      final service = AdminService(
        client: mockClient,
        tokenProvider: ({bool forceRefresh = false}) async => 'test-token',
        baseUrl: testBaseUrl,
      );

      await expectLater(
        service.review(registrationId: 'reg-invalid', decision: 'bad-decision'),
        throwsA(
          isA<AdminGatewayException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having(
                (e) => e.message,
                'message',
                contains('A valid registration decision is required'),
              ),
        ),
      );
    });

    test(
      'on 500, throws gateway server error without leaking secrets',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'The request could not be completed.'}),
            500,
          );
        });

        final service = AdminService(
          client: mockClient,
          tokenProvider: ({bool forceRefresh = false}) async => 'test-token',
          baseUrl: testBaseUrl,
        );

        await expectLater(
          service.listRegistrations(),
          throwsA(
            isA<AdminGatewayException>()
                .having((e) => e.statusCode, 'statusCode', 500)
                .having(
                  (e) => e.message,
                  'message',
                  contains('temporarily unavailable'),
                ),
          ),
        );
      },
    );

    test(
      'on malformed JSON in 200 response, throws AdminGatewayException safely',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('not valid json {[[', 200);
        });

        final service = AdminService(
          client: mockClient,
          tokenProvider: ({bool forceRefresh = false}) async => 'test-token',
          baseUrl: testBaseUrl,
        );

        await expectLater(
          service.listRegistrations(),
          throwsA(
            isA<AdminGatewayException>().having(
              (e) => e.message,
              'message',
              contains('response was invalid'),
            ),
          ),
        );
      },
    );

    test(
      'on network failure, throws AdminGatewayException with network error message',
      () async {
        final mockClient = MockClient((request) async {
          throw http.ClientException('Failed to connect to host');
        });

        final service = AdminService(
          client: mockClient,
          tokenProvider: ({bool forceRefresh = false}) async => 'test-token',
          baseUrl: testBaseUrl,
        );

        await expectLater(
          service.listRegistrations(),
          throwsA(
            isA<AdminGatewayException>().having(
              (e) => e.message,
              'message',
              contains('Network error'),
            ),
          ),
        );
      },
    );

    test('fails safely if user is not signed in', () async {
      final mockClient = MockClient(
        (request) async => http.Response('{}', 200),
      );

      final service = AdminService(
        client: mockClient,
        tokenProvider: ({bool forceRefresh = false}) async => null,
        baseUrl: testBaseUrl,
      );

      await expectLater(
        service.listRegistrations(),
        throwsA(
          isA<AdminGatewayException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having(
                (e) => e.message,
                'message',
                contains('Authentication is required'),
              ),
        ),
      );
    });
  });
}
