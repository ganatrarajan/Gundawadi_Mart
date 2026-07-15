import '../../core/constants/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final DioClient _dioClient;

  OrderRepositoryImpl(this._dioClient);

  @override
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
  }) async {
    final payload = {
      'vendor_id': vendorId,
      'items': items,
      'total_amount': totalAmount,
      'delivery_charge': deliveryCharge,
      'handling_charge': handlingCharge,
      'platform_fee': platformFee,
      'address': address,
      'special_instructions': specialInstructions,
      'delivery_slot': deliverySlot,
      'payment_method': 'COD' // COD is forced
    };

    final response = await _dioClient.post(
      ApiEndpoints.orders,
      data: payload,
    );

    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<OrderModel>> getOrders({String? date, String? month, String? year}) async {
    final response = await _dioClient.get(
      ApiEndpoints.orders,
      queryParameters: {
        if (date != null) 'date': date,
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );
    final List<dynamic> list = response.data['data'] as List;
    return list.map((json) => OrderModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<OrderModel> getOrderDetails(int id) async {
    final response = await _dioClient.get(ApiEndpoints.orderDetails(id));
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> cancelOrder(int id) async {
    final response = await _dioClient.post(ApiEndpoints.cancelOrder(id));
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
