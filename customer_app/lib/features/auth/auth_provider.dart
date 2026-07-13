import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  Map<String, dynamic>? _customerData;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get customerData => _customerData;

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
    final customerId = prefs.getInt('customer_id');
    final customerMobile = prefs.getString('customer_mobile');
    final customerName = prefs.getString('customer_name');

    if (token != null && customerId != null) {
      _isAuthenticated = true;
      _customerData = {
        'id': customerId,
        'mobile': customerMobile,
        'name': customerName,
      };
      notifyListeners();
    }
  }

  Future<bool> requestOtp(String mobile) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await apiClient.dio.post('/customer/login', data: {
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
      final response = await apiClient.dio.post('/customer/verify-otp', data: {
        'mobile': mobile,
        'otp': otp,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        final customerMap = data['customer'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setInt('customer_id', customerMap['id']);
        await prefs.setString('customer_mobile', customerMap['mobile']);
        if (customerMap['name'] != null) {
          await prefs.setString('customer_name', customerMap['name']);
        }

        _customerData = customerMap;
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

  Future<bool> updateProfileName(String name) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await apiClient.dio.post('/customer/update-profile', data: {
        'name': name,
      });

      if (response.data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('customer_name', name);
        
        _customerData?['name'] = name;
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
    _customerData = null;
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
