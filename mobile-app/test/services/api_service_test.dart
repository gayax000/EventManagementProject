import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:eventcraft_mobile/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.signature';

  setUp(() {
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'read') {
          return mockToken;
        }
        return null;
      },
    );
  });

  tearDown(() {
    ApiService.resetClient();
  });

  test('getMyEvents sends Bearer token and omits customerId query parameter', () async {
    Uri? capturedUri;
    Map<String, String>? capturedHeaders;

    final mockClient = MockClient((request) async {
      capturedUri = request.url;
      capturedHeaders = request.headers;

      final sampleResponse = [
        {
          'eventId': 'ev-101',
          'title': 'Galle Lighthouse Gala',
          'eventType': 'Dinner/Gala',
          'targetDate': '2026-11-20T18:00:00Z',
          'guestCount': 150,
          'budgetLimit': 850000.0,
          'status': 'UnderReview',
          'isOutdoor': true,
        }
      ];

      return http.Response(jsonEncode(sampleResponse), 200, headers: {'content-type': 'application/json'});
    });

    ApiService.setClient(mockClient);

    final events = await ApiService.getMyEvents();

    expect(capturedUri, isNotNull);
    expect(capturedUri!.path, endsWith('/api/events/my-events'));
    expect(capturedUri!.queryParameters.containsKey('customerId'), isFalse);
    expect(capturedHeaders?['Authorization'], equals('Bearer $mockToken'));
    expect(events.length, equals(1));
    expect(events.first.title, equals('Galle Lighthouse Gala'));
  });

  test('getMyPayments sends Bearer token and omits customerId query parameter', () async {
    Uri? capturedUri;
    Map<String, String>? capturedHeaders;

    final mockClient = MockClient((request) async {
      capturedUri = request.url;
      capturedHeaders = request.headers;

      final samplePayments = [
        {
          'paymentId': 'pay-201',
          'amountPaid': 250000.0,
          'status': 'Approved',
          'paymentMethod': 'BankTransferSlip',
        }
      ];

      return http.Response(jsonEncode(samplePayments), 200, headers: {'content-type': 'application/json'});
    });

    ApiService.setClient(mockClient);

    final payments = await ApiService.getMyPayments();

    expect(capturedUri, isNotNull);
    expect(capturedUri!.path, endsWith('/api/payments/my-payments'));
    expect(capturedUri!.queryParameters.containsKey('customerId'), isFalse);
    expect(capturedHeaders?['Authorization'], equals('Bearer $mockToken'));
    expect(payments.length, equals(1));
    expect(payments.first['paymentId'], equals('pay-201'));
  });

  test('createEvent sends body payload without customerId field', () async {
    Map<String, dynamic>? parsedBody;

    final mockClient = MockClient((request) async {
      parsedBody = jsonDecode(request.body) as Map<String, dynamic>;

      final createdResponse = {
        'eventId': 'ev-303',
        'title': 'Colombo Seaside Reception',
        'eventType': 'Wedding',
        'targetDate': '2026-12-15T10:00:00Z',
        'guestCount': 200,
        'budgetLimit': 1200000.0,
        'status': 'Draft',
        'isOutdoor': false,
      };

      return http.Response(jsonEncode(createdResponse), 200, headers: {'content-type': 'application/json'});
    });

    ApiService.setClient(mockClient);

    final result = await ApiService.createEvent(
      title: 'Colombo Seaside Reception',
      eventType: 'Wedding',
      targetDate: DateTime.parse('2026-12-15T10:00:00Z'),
      guestCount: 200,
      budgetLimit: 1200000.0,
      isOutdoor: false,
    );

    expect(parsedBody, isNotNull);
    expect(parsedBody!.containsKey('customerId'), isFalse);
    expect(parsedBody!['title'], equals('Colombo Seaside Reception'));
    expect(result, isNotNull);
    expect(result!.eventId, equals('ev-303'));
  });

  test('getMyEvents handles 401 and 500 error responses gracefully returning empty list', () async {
    final mockClient401 = MockClient((request) async {
      return http.Response(jsonEncode({'message': 'Unauthorized'}), 401);
    });

    ApiService.setClient(mockClient401);
    final events401 = await ApiService.getMyEvents();
    expect(events401, isEmpty);

    final mockClient500 = MockClient((request) async {
      return http.Response(jsonEncode({'message': 'Internal Server Error'}), 500);
    });

    ApiService.setClient(mockClient500);
    final events500 = await ApiService.getMyEvents();
    expect(events500, isEmpty);
  });
}
