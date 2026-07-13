import 'package:flutter/material.dart';
import 'package:mart/features/auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import 'package:mart/features/auth/presentation/providers/auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final AuthProvider _authProvider; // Inject AuthProvider to keep auth status synchronized

  User? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProfileProvider(this._profileRepository, this._authProvider) {
    _profile = _authProvider.user;
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.getProfile();
      // Sync auth provider
      _authProvider.checkAuthStatus();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(User updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.updateProfile(updatedUser);
      // Sync auth provider state
      await _authProvider.checkAuthStatus();
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

  Future<String?> uploadPhoto(String path) async {
    try {
      return await _profileRepository.uploadShopPhoto(path);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }
}
