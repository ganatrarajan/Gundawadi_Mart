import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class OrderProvider extends ChangeNotifier {
  final ApiClient apiClient;

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _orders = [];
  Map<String, dynamic>? _selectedOrder;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get orders => _orders;
  Map<String, dynamic>? get selectedOrder => _selectedOrder;

  OrderProvider(this.apiClient);

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await apiClient.dio.get('/customer/orders');
      if (response.data['success'] == true) {
        _orders = response.data['data'];
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to load order history.';
    }
    _setLoading(false);
  }

  Future<void> fetchOrderDetails(int orderId) async {
    _setLoading(true);
    _errorMessage = null;
    _selectedOrder = null;
    try {
      final response = await apiClient.dio.get('/customer/orders/$orderId');
      if (response.data['success'] == true) {
        _selectedOrder = response.data['data'];
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to load order details.';
    }
    _setLoading(false);
  }

  Future<bool> reorder(int orderId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await apiClient.dio.post('/customer/orders/$orderId/reorder');
      if (response.data['success'] == true) {
        await fetchOrders();
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.data['message'];
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Reorder request failed. Check product availability.';
      _setLoading(false);
      return false;
    }
  }
}
