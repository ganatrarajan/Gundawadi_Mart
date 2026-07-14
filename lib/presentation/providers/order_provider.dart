import 'package:flutter/material.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;

  List<OrderModel> _orders = [];
  OrderModel? _placedOrder;
  OrderModel? _selectedOrder;
  
  bool _isLoadingOrders = false;
  bool _isPlacingOrder = false;
  String? _error;

  OrderProvider(this._orderRepository);

  List<OrderModel> get orders => _orders;
  OrderModel? get placedOrder => _placedOrder;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get error => _error;

  // Filtered orders list getters for UI tabs
  List<OrderModel> get currentOrders {
    final activeStatuses = [
      'pending', 
      'accepted', 
      'packing', 
      'ready for pickup', 
      'ready_for_pickup', 
      'out for delivery', 
      'out_for_delivery'
    ];
    return _orders.where((o) => activeStatuses.contains(o.status.toLowerCase())).toList();
  }

  List<OrderModel> get completedOrders {
    return _orders.where((o) => o.status.toLowerCase() == 'delivered' || o.status.toLowerCase() == 'completed').toList();
  }

  List<OrderModel> get cancelledOrders {
    return _orders.where((o) => o.status.toLowerCase() == 'cancelled').toList();
  }

  // Place Order
  Future<bool> placeOrder({
    required int vendorId,
    required List<CartItem> cartItems,
    required double totalAmount,
    required double deliveryCharge,
    required AddressModel address,
    String specialInstructions = '',
    double handlingCharge = 0.0,
    double platformFee = 0.0,
    String deliverySlot = '',
  }) async {
    _isPlacingOrder = true;
    _error = null;
    _placedOrder = null;
    notifyListeners();

    try {
      final itemsPayload = cartItems.map((e) => e.toJson()).toList();
      _placedOrder = await _orderRepository.placeOrder(
        vendorId: vendorId,
        items: itemsPayload,
        totalAmount: totalAmount,
        deliveryCharge: deliveryCharge,
        address: address.toJson(),
        specialInstructions: specialInstructions,
        handlingCharge: handlingCharge,
        platformFee: platformFee,
        deliverySlot: deliverySlot,
      );

      // Prepend to current session order lists for fast local updating
      if (_placedOrder != null) {
        _orders.insert(0, _placedOrder!);
      }
      _isPlacingOrder = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isPlacingOrder = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fetch Orders
  Future<void> fetchOrders() async {
    _isLoadingOrders = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderRepository.getOrders();
      _isLoadingOrders = false;
      notifyListeners();
    } catch (e) {
      _isLoadingOrders = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Fetch single order details (polling/refreshing timeline status)
  Future<void> fetchOrderDetails(int id) async {
    _error = null;
    notifyListeners();

    try {
      final details = await _orderRepository.getOrderDetails(id);
      _selectedOrder = details;
      
      // Update item in local list
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _orders[index] = details;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Cancel order
  Future<bool> cancelOrder(int id) async {
    _error = null;
    notifyListeners();

    try {
      final details = await _orderRepository.cancelOrder(id);
      _selectedOrder = details;
      
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _orders[index] = details;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
