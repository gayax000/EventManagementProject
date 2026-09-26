import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import 'auth_service.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1' || host.isEmpty) {
        return 'http://localhost:8080/api';
      }
    }
    return 'https://eventmanagementproject-production-19c1.up.railway.app/api';
  }

  // Helper method to build headers with Bearer Token and Customer Id
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    final userId = await AuthService.getUserId();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (userId != null && userId.isNotEmpty) {
      headers['X-Customer-Id'] = userId;
    }
    return headers;
  }

  // 1. Fetch live events list from Backend (strictly isolated per customer)
  static Future<List<EventSummary>> getMyEvents() async {
    try {
      final userId = await AuthService.getUserId();
      var urlStr = '$baseUrl/events/my-events';
      if (userId != null && userId.isNotEmpty) {
        urlStr += '?customerId=$userId';
      }
      final url = Uri.parse(urlStr);
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => EventSummary.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("API Error getMyEvents: $e");
      return [];
    }
  }

  // 2. Fetch specific proposal and booking pass
  static Future<EventProposalDetail?> getProposalDetails(String eventId) async {
    try {
      final url = Uri.parse('$baseUrl/events/$eventId/proposal');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return EventProposalDetail.fromJson(body);
      } else {
        throw Exception('Failed to load proposal: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("API Error getProposalDetails: $e");
      return null;
    }
  }

  // 2.01 Request Budget Auto-Fit
  static Future<bool> requestBudgetAutoFit(String eventId) async {
    try {
      final url = Uri.parse('$baseUrl/events/$eventId/approve-proposal?finalTotal=1500000&status=ApprovedByManager');
      final headers = await _getHeaders();
      final response = await http.post(url, headers: headers).timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("API Error requestBudgetAutoFit: $e");
      return false;
    }
  }

  // 2.02 Accept Overrun & Approve
  static Future<bool> acceptOverrunAndApprove(String eventId, double finalTotal) async {
    try {
      final url = Uri.parse('$baseUrl/events/$eventId/approve-proposal?finalTotal=$finalTotal&status=ApprovedByManager');
      final headers = await _getHeaders();
      final response = await http.post(url, headers: headers).timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("API Error acceptOverrunAndApprove: $e");
      return false;
    }
  }

  // 2.03 Submit Client Budget Choice or Custom Revision Request
  static Future<bool> submitClientBudgetChoice(String eventId, String choice, double chosenTotal, {String? revisionNotes}) async {
    try {
      final url = Uri.parse('$baseUrl/events/$eventId/submit-client-budget-choice?choice=$choice&chosenTotal=$chosenTotal');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'clientAction': choice,
        'revisionNotes': revisionNotes,
        'selectedTier': choice,
      });
      final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("API Error submitClientBudgetChoice: $e");
      return false;
    }
  }

  // 2.1 Fetch Banquet Halls for Hotels
  static Future<List<BanquetHallItem>> getBanquetHalls({String? venueId, DateTime? date, String? session}) async {
    try {
      var urlStr = '$baseUrl/banquethalls';
      final params = <String>[];
      if (venueId != null && venueId.isNotEmpty) params.add('venueId=$venueId');
      if (date != null) params.add('date=${date.toIso8601String()}');
      if (session != null && session.isNotEmpty) params.add('session=$session');
      if (params.isNotEmpty) urlStr += '?${params.join('&')}';

      final url = Uri.parse(urlStr);
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => BanquetHallItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("API Error getBanquetHalls: $e");
      return [];
    }
  }

  // 3. Create Event Request (Triggers Multi-Agent Python AI with user isolation, hall & services)
  static Future<EventSummary?> createEvent({
    required String title,
    String? eventType,
    String? customEventType,
    required DateTime targetDate,
    required int guestCount,
    required double budgetLimit,
    bool isOutdoor = false,
    String? additionalDetails,
    String? venueId,
    String? banquetHallId,
    String? preferredLocation,
    List<String>? selectedServices,
    String? customServiceNotes,
    List<String>? inspirationImages,
    String? eventSession,
    String? cateringStyle,
    List<String>? tableRefreshments,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      final url = Uri.parse('$baseUrl/events');
      final payload = jsonEncode({
        'title': title,
        'eventType': eventType ?? 'Wedding',
        'customEventType': customEventType,
        'targetDate': targetDate.toIso8601String(),
        'guestCount': guestCount,
        'budgetLimit': budgetLimit,
        'isOutdoor': isOutdoor,
        'additionalDetails': additionalDetails,
        'venueId': venueId,
        'banquetHallId': banquetHallId,
        'customerId': userId,
        'preferredLocation': preferredLocation,
        'selectedServices': selectedServices,
        'customServiceNotes': customServiceNotes,
        'inspirationImages': inspirationImages,
        'eventSession': eventSession ?? 'DayLunch',
        'cateringStyle': cateringStyle ?? 'InternationalBuffet',
        'tableRefreshments': tableRefreshments,
        'inspirationImageUrl': inspirationImages != null && inspirationImages.isNotEmpty 
            ? jsonEncode(inspirationImages) 
            : null,
      });

      final headers = await _getHeaders();
      final response = await http
          .post(
            url,
            headers: headers,
            body: payload,
          )
          .timeout(const Duration(seconds: 45)); // Give AI time to run

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return EventSummary.fromJson(body);
      } else {
        try {
          final errJson = jsonDecode(response.body);
          if (errJson is Map && errJson.containsKey('message')) {
            throw Exception(errJson['message']);
          }
        } catch (e) {
          if (e is Exception && !e.toString().contains('Failed to create event')) {
            rethrow;
          }
        }
        throw Exception('Failed to create event (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint("API Error createEvent: $e");
      if (e.toString().contains('ClientException') || e.toString().contains('Failed to fetch') || e.toString().contains('TimeoutException')) {
        throw Exception("Server is starting up or network timed out. Please try submitting again in a few seconds.");
      }
      rethrow;
    }
  }

  // 4. Sign Digital Contract & Generate QR Entry Pass
  static Future<Map<String, dynamic>?> signContract({
    required String eventId,
    required double agreedAmount,
    required String signatureData,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/events/$eventId/sign-contract');
      final payload = jsonEncode({
        'agreedTotalAmount': agreedAmount,
        'digitalSignatureUrl': signatureData.isNotEmpty ? signatureData : 'signature_data_ok',
      });

      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: payload,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to sign contract: ${response.body}');
      }
    } catch (e) {
      debugPrint("API Error signContract: $e");
      rethrow;
    }
  }

  // 5. Upload Bank Transfer Payment Slip (Member 4 Mobile Feature)
  static Future<Map<String, dynamic>?> uploadPaymentSlip({
    String? bookingId,
    required String eventId,
    required double amount,
    required String slipImageBase64,
    String? bankReferenceNumber,
    String? notes,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/payments/upload-slip');
      final payload = jsonEncode({
        if (bookingId != null && bookingId.isNotEmpty) 'bookingId': bookingId,
        'eventId': eventId,
        'amountPaid': amount > 0 ? amount : 1000.0,
        'amount': amount > 0 ? amount : 1000.0,
        'slipImageUrl': slipImageBase64,
        'paymentSlipUrl': slipImageBase64,
        'paymentMethod': 'BankTransferSlip',
        'bankReferenceNumber': bankReferenceNumber,
        'notes': notes ?? 'Customer Bank Transfer via Mobile App',
      });

      final headers = await _getHeaders();
      final response = await http
          .post(url, headers: headers, body: payload)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to upload payment slip: ${response.body}');
      }
    } catch (e) {
      debugPrint("API Error uploadPaymentSlip: $e");
      rethrow;
    }
  }

  // 6. Verify QR Entry Pass (Staff Scanner Feature - Spec LO3 Device)
  static Future<Map<String, dynamic>> verifyQrPass(String qrCodeData) async {
    try {
      final encoded = Uri.encodeComponent(qrCodeData);
      final url = Uri.parse('$baseUrl/events/verify-pass/$encoded');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return {...body, 'statusCode': 200};
      } else if (response.statusCode == 400) {
        // Already scanned
        return {...body, 'statusCode': 400};
      } else if (response.statusCode == 404) {
        return {'isValid': false, 'message': 'Invalid QR Entry Pass.', 'statusCode': 404};
      } else {
        return {'isValid': false, 'message': 'Server error: ${response.statusCode}', 'statusCode': response.statusCode};
      }
    } catch (e) {
      debugPrint("API Error verifyQrPass: $e");
      return {'isValid': false, 'message': 'Network error: $e', 'statusCode': 0};
    }
  }
}
