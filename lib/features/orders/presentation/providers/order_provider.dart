import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../../../../core/services/fcm_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _fcmSubscription;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OrderProvider(this._orderRepository) {
    fetchOrders();
    // Refresh orders reactively on incoming push notification triggers (New/Cancelled orders)
    _fcmSubscription = FcmService.notificationStream.listen((_) {
      fetchOrders();
    });
  }

  Future<void> fetchOrders({String? date, String? month, String? year}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderRepository.getOrders(date: date, month: month, year: year);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changeStatus(String orderId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedOrder = await _orderRepository.updateOrderStatus(orderId, status);
      
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeItemPrice(String orderId, int orderItemId, double price) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedOrder = await _orderRepository.updateOrderItemPrice(orderItemId, price);
      
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    super.dispose();
  }
}
