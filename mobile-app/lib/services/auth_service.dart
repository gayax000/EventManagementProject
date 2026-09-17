import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool success;
  final String? message;

  AuthResult({required this.success, this.message});
}

class AuthService {
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

  static const String _tokenKey = 'jwt_token';
  static const String _userRoleKey = 'user_role';
  static const String _userNameKey = 'user_name';

  static Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password.trim()}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final role = data['role'] ?? 'Customer';
        final name = data['fullName'] ?? email.split('@').first;

        await saveToken(token, role, name);
        return AuthResult(success: true);
      } else {
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('message')) {
            return AuthResult(success: false, message: data['message'].toString());
          }
        } catch (_) {}
        return AuthResult(success: false, message: 'Invalid email or password.');
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      return AuthResult(success: false, message: 'Connection error: Unable to reach server.');
    }
  }

  static Future<AuthResult> register(String fullName, String email, String password, String phoneNumber, {String role = 'Customer'}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName.trim(),
          'email': email.trim(),
          'password': password.trim(),
          'phoneNumber': phoneNumber.trim(),
          'role': role,
        }),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return AuthResult(success: true, message: 'Registration successful! Please login.');
      } else {
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('message')) {
            return AuthResult(success: false, message: data['message'].toString());
          }
          if (data is Map && data.containsKey('errors')) {
            final errors = data['errors'] as Map;
            final firstKey = errors.keys.first;
            final firstErrorList = errors[firstKey] as List;
            return AuthResult(success: false, message: firstErrorList.first.toString());
          }
        } catch (_) {}
        return AuthResult(success: false, message: 'Registration failed (${response.statusCode}).');
      }
    } catch (e) {
      debugPrint('Register Error: $e');
      return AuthResult(success: false, message: 'Connection error: Unable to reach server.');
    }
  }

  static Future<void> saveToken(String token, String role, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userRoleKey, role);
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Customer';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userNameKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
