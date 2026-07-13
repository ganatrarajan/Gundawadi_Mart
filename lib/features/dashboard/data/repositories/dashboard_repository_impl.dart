import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DioClient _dioClient;

  DashboardRepositoryImpl(this._dioClient);

  @override
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.dashboard);
      return DashboardStats.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to load dashboard statistics.';
      throw Exception(msg);
    }
  }
}
