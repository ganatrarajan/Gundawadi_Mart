import 'package:mart/features/auth/domain/entities/user.dart';

abstract class ProfileRepository {
  Future<User> getProfile();
  Future<User> updateProfile(User profile);
  Future<String> uploadShopPhoto(String filePath);
}
