import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String mobile, String password);
  Future<void> logout();
  Future<User?> getLoggedInUser();
}
