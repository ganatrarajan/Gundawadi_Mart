import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String mobile, String password);
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(String name, String mobile, AddressModel address);
  Future<AddressModel> submitAddressChangeRequest(AddressModel address);
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
  });
  Future<void> logout();
}
