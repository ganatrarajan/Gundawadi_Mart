class ApiEndpoints {
  // Toggle this flag to use Mock data for offline testing or real endpoints
  static const bool useMockApis = false;

  // Base configurations
  static const String baseUrl = 'http://192.168.1.11:8000/api';
  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 15000;

  static const String register = '/customer/register';
  static const String login = '/customer/login';
  static const String verifyOtp = '/customer/verify-otp';
  static const String profile = '/customer/profile';
  static const String updateProfile = '/customer/update-profile';
  static const String uploadPhoto = '/customer/profile/upload-photo';
  static const String vendors = '/customer/vendors';
  static const String orders = '/customer/orders';
  static const String addresses = '/customer/addresses';
  static const String updateDeviceToken = '/customer/update-device-token';
  
  static String vendorDetails(int id) => '/customer/vendors/$id';
  static String orderDetails(int id) => '/customer/orders/$id';
  static String reorder(int id) => '/customer/orders/$id/reorder';
  static String cancelOrder(int id) => '/customer/orders/$id/cancel';

  // Format local development image URLs safely
  static String formatImageUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') return '';
    
    const String baseHost = 'http://192.168.1.11:8000';
    String formatted = url;
    
    if (formatted.contains('localhost')) {
      formatted = formatted.replaceAll('localhost', '192.168.1.11');
    }
    if (formatted.contains('127.0.0.1')) {
      formatted = formatted.replaceAll('127.0.0.1', '192.168.1.11');
    }
    
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      if (!formatted.startsWith('/')) {
        formatted = '/$formatted';
      }
      formatted = '$baseHost$formatted';
    }
    
    return formatted;
  }
}
