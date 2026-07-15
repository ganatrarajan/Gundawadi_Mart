class ApiEndpoints {
  // Base Laravel API URL
  static const String baseUrl = 'http://192.168.1.10:8000/api/vendor';

  // Auth endpoints
  static const String login = '/login';
  static const String verifyOtp = '/auth/verify-otp';
  static const String logout = '/auth/logout';

  // Dashboard endpoints
  static const String dashboard = '/dashboard';

  // Product endpoints
  static const String products = '/products';
  static const String toggleProduct = '/products/toggle';
  static const String updatePrice = '/products/update-price';
  static const String uploadProductImage = '/products/upload-image';

  // Order endpoints
  static const String orders = '/orders';
  static const String orderStatusUpdate = '/orders/update-status';
  static const String updateOrderItemPrice = '/orders/items/update-price';

  // Profile endpoints
  static const String profile = '/profile';
  static const String uploadShopPhoto = '/profile/upload-photo';

  // Notification endpoints
  static const String notifications = '/notifications';
  static const String updateFcmToken = '/profile/update-fcm';
}
