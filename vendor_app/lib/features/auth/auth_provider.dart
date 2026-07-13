import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  Map<String, dynamic>? _vendorData;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get vendorData => _vendorData;

  AuthProvider(this.apiClient) {
    checkPersistedAuth();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<void> checkPersistedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final vendorId = prefs.getInt('vendor_id');
    final vendorShopName = prefs.getString('vendor_shop_name');
    final vendorOwnerName = prefs.getString('vendor_owner_name');
    final vendorMobile = prefs.getString('vendor_mobile');

    if (token != null && vendorId != null) {
      _isAuthenticated = true;
      _vendorData = {
        'id': vendorId,
        'shop_name': vendorShopName,
        'owner_name': vendorOwnerName,
        'mobile_number': vendorMobile,
      };
      notifyListeners();
    }
  }

  Future<bool> requestOtp(String mobile) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await apiClient.dio.post('/vendor/login', data: {
        'mobile': mobile,
      });

      if (response.data['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.data['message'];
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOtp(String mobile, String otp) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await apiClient.dio.post('/vendor/verify-otp', data: {
        'mobile': mobile,
        'otp': otp,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        final vendorMap = data['vendor'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setInt('vendor_id', vendorMap['id']);
        await prefs.setString('vendor_shop_name', vendorMap['shop_name']);
        await prefs.setString('vendor_owner_name', vendorMap['owner_name']);
        await prefs.setString('vendor_mobile', vendorMap['mobile_number']);

        _vendorData = vendorMap;
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.data['message'];
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isAuthenticated = false;
    _vendorData = null;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
      }
      return e.message ?? 'An error occurred. Please try again.';
    }
    return e.toString();
  }
}
