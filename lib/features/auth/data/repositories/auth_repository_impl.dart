import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;

  AuthRepositoryImpl(this._dioClient);

  @override
  Future<User> login(String mobile, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: {
          'mobile': mobile,
          'password': password,
        },
      );

      final responseData = response.data['data'] as Map<String, dynamic>;
      final token = responseData['token'];
      final vendorJson = responseData['vendor'] as Map<String, dynamic>;
      final user = User.fromJson(vendorJson);

      // Save session locally
      await SharedPrefsService.saveToken(token);
      await SharedPrefsService.saveVendorDetails(
        shopName: user.shopName,
        ownerName: user.ownerName,
        mobile: user.mobile,
        address: user.address,
        openingTime: user.openingTime,
        closingTime: user.closingTime,
        shopPhoto: user.shopPhoto,
      );

      return user;
    } on DioException catch (e) {
      throw Exception(ErrorParser.parse(e, 'Login failed. Please verify credentials.'));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.dio.post(ApiEndpoints.logout).catchError((_) => Response(requestOptions: RequestOptions()));
    } finally {
      await SharedPrefsService.clearAll();
    }
  }

  @override
  Future<User?> getLoggedInUser() async {
    final token = SharedPrefsService.getToken();
    if (token == null) return null;

    final details = SharedPrefsService.getVendorDetails();
    if (details['shopName'] != null) {
      return User(
        shopName: details['shopName']!,
        ownerName: details['ownerName']!,
        mobile: details['mobile']!,
        address: details['address']!,
        openingTime: details['openingTime'] ?? '06:00 AM',
        closingTime: details['closingTime'] ?? '08:00 PM',
        shopPhoto: details['shopPhoto'],
      );
    }
    return null;
  }
}
