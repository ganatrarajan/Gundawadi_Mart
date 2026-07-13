import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthState { uninitialized, authenticating, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  AuthState _state = AuthState.uninitialized;
  String? _errorMessage;
  UserModel? _currentUser;
  
  // Kept for backward compatibility if reference exists
  final int _otpCountdown = 0;
  final bool _isCountdownActive = false;

  AuthProvider(this._authRepository, this._storageService) {
    _checkSession();
  }

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  int get otpCountdown => _otpCountdown;
  bool get isCountdownActive => _isCountdownActive;

  // Auto session check
  Future<void> _checkSession() async {
    final token = _storageService.getToken();
    final userJson = _storageService.getUser();
    
    if (token != null && userJson != null) {
      _currentUser = UserModel.fromJson(userJson);
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // Deprecated OTP helper methods
  Future<bool> requestOtp(String mobile) async => false;
  Future<bool> verifyOtp(String mobile, String otp) async => false;

  // Password Login
  Future<bool> login(String mobile, String password) async {
    _state = AuthState.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(mobile, password);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Refresh Profile details from API
  Future<void> refreshProfile() async {
    if (_currentUser == null) return;
    try {
      _currentUser = await _authRepository.getProfile();
      notifyListeners();
    } catch (_) {
      // Gracefully capture, keep current session cache
    }
  }

  // Update Profile
  Future<bool> updateProfile(String name, String mobile, AddressModel address) async {
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.updateProfile(name, mobile, address);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Register customer
  Future<bool> register({
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
    _state = AuthState.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      _errorMessage = await _authRepository.register(
        name: name,
        mobile: mobile,
        password: password,
        passwordConfirmation: passwordConfirmation,
        houseNumber: houseNumber,
        street: street,
        area: area,
        landmark: landmark,
        city: city,
        pincode: pincode,
      );
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Submit address change request
  Future<bool> submitAddressChangeRequest(AddressModel address) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final newAddress = await _authRepository.submitAddressChangeRequest(address);
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(pendingAddress: newAddress);
        await _storageService.saveUser(_currentUser!.toJson());
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
