import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../core/services/fcm_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _dashboardRepository;

  DashboardStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _fcmSubscription;

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DashboardProvider(this._dashboardRepository) {
    fetchStats();
    // Listen to push notifications for real-time metrics updates
    _fcmSubscription = FcmService.notificationStream.listen((payload) {
      fetchStats();
    });
  }

  Future<void> fetchStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _dashboardRepository.getDashboardStats();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    super.dispose();
  }
}
