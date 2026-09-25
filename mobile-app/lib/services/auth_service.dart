import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool success;
  final String? message;

  AuthResult({required this.success, this.message});
}

class AuthService {
  static String get baseUrl {
    return 'https://eventmanagementproject-production.up.railway.app/api';
  }

  static const String _tokenKey = 'jwt_token';
  static const String _userRoleKey = 'user_role';
  static const String _userNameKey = 'user_name';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

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
        final userId = data['userId']?.toString() ?? '';

        await saveToken(token, role, name, userId: userId, email: email);
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

  static Future<void> saveToken(String token, String role, String name, {String? userId, String? email}) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _userRoleKey, value: role);
      await _secureStorage.write(key: _userNameKey, value: name);
      if (userId != null && userId.isNotEmpty) {
        await _secureStorage.write(key: _userIdKey, value: userId);
      }
      if (email != null && email.isNotEmpty) {
        await _secureStorage.write(key: _userEmailKey, value: email);
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userRoleKey, role);
      await prefs.setString(_userNameKey, name);
      if (userId != null && userId.isNotEmpty) {
        await prefs.setString(_userIdKey, userId);
      }
      if (email != null && email.isNotEmpty) {
        await prefs.setString(_userEmailKey, email);
      }
    } catch (_) {}
  }

  static Future<String?> getToken() async {
    try {
      final val = await _secureStorage.read(key: _tokenKey);
      if (val != null && val.isNotEmpty) return val;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUserId() async {
    try {
      final val = await _secureStorage.read(key: _userIdKey);
      if (val != null && val.isNotEmpty) return val;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<String?> getUserEmail() async {
    try {
      final val = await _secureStorage.read(key: _userEmailKey);
      if (val != null && val.isNotEmpty) return val;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<String?> getUserName() async {
    try {
      final val = await _secureStorage.read(key: _userNameKey);
      if (val != null && val.isNotEmpty) return val;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Customer';
  }

  static Future<String?> getUserRole() async {
    try {
      final val = await _secureStorage.read(key: _userRoleKey);
      if (val != null && val.isNotEmpty) return val;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userRoleKey);
      await _secureStorage.delete(key: _userNameKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _userEmailKey);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
