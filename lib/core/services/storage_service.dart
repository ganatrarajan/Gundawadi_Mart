import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyAddresses = 'saved_addresses';

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  static StorageService get instance {
    if (_instance == null) {
      throw Exception("StorageService is not initialized. Call getInstance() first.");
    }
    return _instance!;
  }

  // Auth Token
  Future<bool> saveToken(String token) async {
    return await _preferences?.setString(_keyToken, token) ?? false;
  }

  String? getToken() {
    return _preferences?.getString(_keyToken);
  }

  Future<bool> clearToken() async {
    return await _preferences?.remove(_keyToken) ?? false;
  }

  // User Session
  Future<bool> saveUser(Map<String, dynamic> userMap) async {
    return await _preferences?.setString(_keyUser, json.encode(userMap)) ?? false;
  }

  Map<String, dynamic>? getUser() {
    final userStr = _preferences?.getString(_keyUser);
    if (userStr == null) return null;
    try {
      return json.decode(userStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> clearUser() async {
    return await _preferences?.remove(_keyUser) ?? false;
  }

  // Saved Addresses
  Future<bool> saveAddresses(List<Map<String, dynamic>> addresses) async {
    final addressStrings = addresses.map((e) => json.encode(e)).toList();
    return await _preferences?.setStringList(_keyAddresses, addressStrings) ?? false;
  }

  List<Map<String, dynamic>> getAddresses() {
    final list = _preferences?.getStringList(_keyAddresses);
    if (list == null) return [];
    try {
      return list.map((e) => json.decode(e) as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  // Clear Session
  Future<bool> clearAll() async {
    await clearToken();
    await clearUser();
    return true;
  }
}
