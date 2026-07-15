import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/shared_prefs_service.dart';
import 'package:mart/features/auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final DioClient _dioClient;

  ProfileRepositoryImpl(this._dioClient);

  @override
  Future<User> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.profile);
      final user = User.fromJson(response.data['data'] as Map<String, dynamic>);
      
      // Update local cache
      await SharedPrefsService.saveVendorDetails(
        shopName: user.shopName,
        ownerName: user.ownerName,
        mobile: user.mobile,
        address: user.address,
        openingTime: user.openingTime,
        closingTime: user.closingTime,
        shopPhoto: user.shopPhoto,
        isClosed: user.isClosed,
      );
      
      return user;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load profile details.');
    }
  }

  @override
  Future<User> updateProfile(User profile) async {
    try {
      final response = await _dioClient.dio.put(
        ApiEndpoints.profile,
        data: profile.toJson(),
      );
      final user = User.fromJson(response.data['data'] as Map<String, dynamic>);

      // Sync local storage cache
      await SharedPrefsService.saveVendorDetails(
        shopName: user.shopName,
        ownerName: user.ownerName,
        mobile: user.mobile,
        address: user.address,
        openingTime: user.openingTime,
        closingTime: user.closingTime,
        shopPhoto: user.shopPhoto,
        isClosed: user.isClosed,
      );

      return user;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to update profile details.');
    }
  }

  @override
  Future<String> uploadShopPhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(filePath),
      });

      final response = await _dioClient.dio.post(
        ApiEndpoints.uploadShopPhoto,
        data: formData,
      );

      return response.data['data']['shop_photo'];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to upload shop photo.');
    }
  }
}
