import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final DioClient _dioClient;

  OrderRepositoryImpl(this._dioClient);

  @override
  Future<List<Order>> getOrders() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.orders);
      final List list = response.data['data'] as List;
      return list.map((item) => Order.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch orders.');
    }
  }

  @override
  Future<Order> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.orderStatusUpdate,
        data: {
          'id': orderId,
          'status': status,
        },
      );
      return Order.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to update order status.');
    }
  }

  @override
  Future<Order> updateOrderItemPrice(int orderItemId, double price) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.updateOrderItemPrice,
        data: {
          'order_item_id': orderItemId,
          'price': price,
        },
      );
      return Order.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to update item price.');
    }
  }
}
