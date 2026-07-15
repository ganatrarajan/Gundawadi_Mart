import '../../data/models/order_model.dart';

abstract class OrderRepository {
  Future<OrderModel> placeOrder({
    required int vendorId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required double deliveryCharge,
    required Map<String, dynamic> address,
    String specialInstructions = '',
    double handlingCharge = 0.0,
    double platformFee = 0.0,
    String deliverySlot = '',
  });
  Future<List<OrderModel>> getOrders({String? date, String? month, String? year});
  Future<OrderModel> getOrderDetails(int id);
  Future<OrderModel> cancelOrder(int id);
}
