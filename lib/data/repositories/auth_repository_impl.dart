import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;
  final StorageService _storageService;

  AuthRepositoryImpl(this._dioClient, this._storageService);

  @override
  Future<UserModel> login(String mobile, String password) async {
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: {
        'mobile': mobile,
        'password': password,
      },
    );

    final responseData = response.data['data'] as Map<String, dynamic>;
    final token = responseData['token'];
    final userJson = responseData['customer'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userJson);

    // Save token and user details to SharedPreferences session
    await _storageService.saveToken(token);
    await _storageService.saveUser(user.toJson());

    return user;
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _dioClient.get(ApiEndpoints.profile);
    final user = UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    await _storageService.saveUser(user.toJson());
    return user;
  }

  @override
  Future<UserModel> updateProfile(
    String name,
    String mobile,
    AddressModel address,
  ) async {
    final payload = {
      'name': name,
      'mobile': mobile,
      'address': address.toJson(),
    };
    final response = await _dioClient.post(
      ApiEndpoints.updateProfile,
      data: payload,
    );
    
    final user = UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    await _storageService.saveUser(user.toJson());
    return user;
  }

  @override
  Future<AddressModel> submitAddressChangeRequest(AddressModel address) async {
    final response = await _dioClient.post(
      ApiEndpoints.addresses,
      data: address.toJson(),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return AddressModel.fromJson(data);
  }

  @override
  Future<String> register({
    required String name,
    required String mobile,
    required String password,
    required String passwordConfirmation,
    required String houseNumber,
    required String street,
    required String area,
    required String landmark,
    required String city,
    required String pincode,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.register,
      data: {
        'full_name': name,
        'mobile': mobile,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'house_number': houseNumber,
        'street': street,
        'area': area,
        'landmark': landmark,
        'city': city,
        'pincode': pincode,
      },
    );
    return response.data['message'] ?? 'Registration submitted successfully.';
  }

  @override
  Future<UserModel> uploadProfilePhoto(String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    await _dioClient.post(
      ApiEndpoints.uploadPhoto,
      data: formData,
    );

    return await getProfile();
  }

  @override
  Future<void> logout() async {
    await _storageService.clearAll();
  }
}
