import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final role = data['role'] ?? 'Customer';
        
        // Dynamic name from backend or email prefix
        final name = data['fullName'] ?? email.split('@').first;

        await saveToken(token, role, name);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  static Future<bool> register(String fullName, String email, String password, String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
        }),
      );
      
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Register Error: $e');
      return false;
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
