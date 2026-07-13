import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiClient apiClient;

  bool _isLoading = false;
  String? _errorMessage;
  int _todayOrders = 0;
  int _pendingOrders = 0;
  int _completedOrders = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get todayOrders => _todayOrders;
  int get pendingOrders => _pendingOrders;
  int get completedOrders => _completedOrders;

  DashboardProvider(this.apiClient);

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> fetchDashboardStats() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await apiClient.dio.get('/vendor/dashboard');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        _todayOrders = data['today_orders'] ?? 0;
        _pendingOrders = data['pending_orders'] ?? 0;
        _completedOrders = data['completed_orders'] ?? 0;
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to load statistics. Pull to refresh.';
    }
    _setLoading(false);
  }
}
