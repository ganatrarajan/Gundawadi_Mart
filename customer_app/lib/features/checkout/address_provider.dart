import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class AddressProvider extends ChangeNotifier {
  final ApiClient apiClient;

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _addresses = [];
  Map<String, dynamic>? _selectedAddress;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get addresses => _addresses;
  Map<String, dynamic>? get selectedAddress => _selectedAddress;

  AddressProvider(this.apiClient);

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void selectAddress(Map<String, dynamic> addr) {
    _selectedAddress = addr;
    notifyListeners();
  }

  Future<void> fetchAddresses() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await apiClient.dio.get('/customer/addresses');
      if (response.data['success'] == true) {
        _addresses = response.data['data'];
        if (_addresses.isNotEmpty && _selectedAddress == null) {
          _selectedAddress = _addresses.first;
        }
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to load addresses. Please retry.';
    }
    _setLoading(false);
  }

  Future<bool> saveAddress({
    required String fullName,
    required String mobile,
    required String houseNumber,
    required String street,
    required String area,
    required String landmark,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await apiClient.dio.post('/customer/addresses', data: {
        'full_name': fullName,
        'mobile': mobile,
        'house_number': houseNumber,
        'street': street,
        'area': area,
        'landmark': landmark,
      });

      if (response.data['success'] == true) {
        final newAddress = response.data['data'];
        _addresses.add(newAddress);
        _selectedAddress = newAddress;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.data['message'];
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to save address.';
      _setLoading(false);
      return false;
    }
  }
}
