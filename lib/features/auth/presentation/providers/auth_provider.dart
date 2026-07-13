import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/shared_prefs_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _user;
  bool _isCheckingAuth = true;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isCheckingAuth => _isCheckingAuth;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._authRepository) {
    checkAuthStatus();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isCheckingAuth = true;
    notifyListeners();
    
    try {
      final remember = SharedPrefsService.getRememberLogin();
      if (remember) {
        _user = await _authRepository.getLoggedInUser();
      } else {
        await _authRepository.logout();
      }
    } catch (_) {
      _user = null;
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
  }

  // Direct login flow
  Future<bool> login(String mobile, String password, bool rememberMe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(mobile, password);
      await SharedPrefsService.saveRememberLogin(rememberMe);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
