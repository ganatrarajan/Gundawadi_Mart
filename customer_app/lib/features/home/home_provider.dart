import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class HomeProvider extends ChangeNotifier {
  final ApiClient apiClient;

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _vendors = [];
  Map<String, dynamic>? _selectedVendor;
  List<dynamic> _products = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get vendors => _vendors;
  Map<String, dynamic>? get selectedVendor => _selectedVendor;
  List<dynamic> get products => _products;

  HomeProvider(this.apiClient);

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> fetchVendors() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await apiClient.dio.get('/customer/vendors');
      if (response.data['success'] == true) {
        _vendors = response.data['data'];
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to load vendors. Check internet connection.';
    }
    _setLoading(false);
  }

  Future<void> fetchVendorDetails(int vendorId) async {
    _setLoading(true);
    _errorMessage = null;
    _selectedVendor = null;
    _products = [];
    try {
      final response = await apiClient.dio.get('/customer/vendors/$vendorId');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        _selectedVendor = data['vendor'];
        _products = data['products'];
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to load products. Check internet connection.';
    }
    _setLoading(false);
  }
}
