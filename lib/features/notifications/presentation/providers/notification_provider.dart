import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/fcm_service.dart';

class NotificationItem {
  final int id;
  final String title;
  final String body;
  final String time;
  final String type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      time: json['time'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final DioClient _dioClient;

  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _fcmSubscription;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NotificationProvider(this._dioClient) {
    fetchNotifications();
    // Reactively refresh notification history when an FCM notification triggers
    _fcmSubscription = FcmService.notificationStream.listen((_) {
      fetchNotifications();
    });
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dioClient.dio.get(ApiEndpoints.notifications);
      final List list = response.data;
      _notifications = list.map((item) => NotificationItem.fromJson(item)).toList();
    } catch (e) {
      _errorMessage = e.toString();
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
