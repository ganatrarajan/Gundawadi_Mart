import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class OrdersProvider extends ChangeNotifier {
  final ApiClient apiClient;

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _orders = [];
  Map<String, dynamic>? _selectedOrder;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get orders => _orders;
  Map<String, dynamic>? get selectedOrder => _selectedOrder;

  OrdersProvider(this.apiClient);

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await apiClient.dio.get('/vendor/orders');
      if (response.data['success'] == true) {
        _orders = response.data['data'];
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to load orders.';
    }
    _setLoading(false);
  }

  Future<void> fetchOrderDetails(int orderId) async {
    _setLoading(true);
    _errorMessage = null;
    _selectedOrder = null;
    try {
      final response = await apiClient.dio.get('/vendor/orders/$orderId');
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

  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await apiClient.dio.post('/vendor/orders/$orderId/status', data: {
        'status': status,
      });

      if (response.data['success'] == true) {
        final index = _orders.indexWhere((o) => o['id'] == orderId);
        if (index != -1) {
          _orders[index]['status'] = status;
        }
        if (_selectedOrder != null && _selectedOrder!['id'] == orderId) {
          _selectedOrder!['status'] = status;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
