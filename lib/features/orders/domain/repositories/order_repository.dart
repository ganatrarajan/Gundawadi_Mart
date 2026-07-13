import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order> updateOrderStatus(String orderId, String status);
  Future<Order> updateOrderItemPrice(int orderItemId, double price);
}
