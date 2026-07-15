import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders({String? date, String? month, String? year});
  Future<Order> updateOrderStatus(String orderId, String status);
  Future<Order> updateOrderItemPrice(int orderItemId, double price);
}
