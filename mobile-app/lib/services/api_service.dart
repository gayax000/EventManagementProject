import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import 'auth_service.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      if (Uri.base.host.contains('vercel.app')) {
        return 'https://eventmanagementproject-production.up.railway.app/api';
      }
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      return 'http://$host:5147/api';
    }
    return 'https://eventmanagementproject-production.up.railway.app/api';
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
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

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

  // 3. Create Event Request (Triggers Multi-Agent Python AI with user isolation & location)
  static Future<EventSummary?> createEvent({
    required String title,
    required DateTime targetDate,
    required int guestCount,
    required double budgetLimit,
    String? preferredLocation,
    List<String>? inspirationImages,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      final url = Uri.parse('$baseUrl/events');
      final payload = jsonEncode({
        'title': title,
        'targetDate': targetDate.toIso8601String(),
        'guestCount': guestCount,
        'budgetLimit': budgetLimit,
        'customerId': userId,
        'preferredLocation': preferredLocation,
        'inspirationImageUrl': inspirationImages != null && inspirationImages.isNotEmpty 
            ? inspirationImages.join(',') 
            : null,
      });

      final headers = await _getHeaders();
      final response = await http
          .post(
            url,
            headers: headers,
            body: payload,
          )
          .timeout(const Duration(seconds: 30)); // Give AI time to run

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return EventSummary.fromJson(body);
      } else {
        throw Exception('Failed to create event: ${response.body}');
      }
    } catch (e) {
      debugPrint("API Error createEvent: $e");
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
      ).timeout(const Duration(seconds: 10));

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
}
