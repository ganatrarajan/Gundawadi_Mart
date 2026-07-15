import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static late final SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token keys
  static const String _keyToken = 'auth_token';
  static const String _keyRememberLogin = 'remember_login';
  
  // Vendor details keys
  static const String _keyShopName = 'shop_name';
  static const String _keyOwnerName = 'owner_name';
  static const String _keyMobile = 'vendor_mobile';
  static const String _keyAddress = 'vendor_address';
  static const String _keyOpeningTime = 'opening_time';
  static const String _keyClosingTime = 'closing_time';
  static const String _keyShopPhoto = 'shop_photo';
  static const String _keyIsClosed = 'is_closed';

  // Token operations
  static Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  static String? getToken() {
    return _prefs.getString(_keyToken);
  }

  static Future<void> clearToken() async {
    await _prefs.remove(_keyToken);
  }

  // Remember login flag
  static Future<void> saveRememberLogin(bool remember) async {
    await _prefs.setBool(_keyRememberLogin, remember);
  }

  static bool getRememberLogin() {
    return _prefs.getBool(_keyRememberLogin) ?? false;
  }

  // Vendor Details operations
  static Future<void> saveVendorDetails({
    required String shopName,
    required String ownerName,
    required String mobile,
    required String address,
    required String openingTime,
    required String closingTime,
    String? shopPhoto,
    bool isClosed = false,
  }) async {
    await _prefs.setString(_keyShopName, shopName);
    await _prefs.setString(_keyOwnerName, ownerName);
    await _prefs.setString(_keyMobile, mobile);
    await _prefs.setString(_keyAddress, address);
    await _prefs.setString(_keyOpeningTime, openingTime);
    await _prefs.setString(_keyClosingTime, closingTime);
    await _prefs.setBool(_keyIsClosed, isClosed);
    if (shopPhoto != null) {
      await _prefs.setString(_keyShopPhoto, shopPhoto);
    } else {
      await _prefs.remove(_keyShopPhoto);
    }
  }

  static Map<String, dynamic> getVendorDetails() {
    return {
      'shopName': _prefs.getString(_keyShopName),
      'ownerName': _prefs.getString(_keyOwnerName),
      'mobile': _prefs.getString(_keyMobile),
      'address': _prefs.getString(_keyAddress),
      'openingTime': _prefs.getString(_keyOpeningTime),
      'closingTime': _prefs.getString(_keyClosingTime),
      'shopPhoto': _prefs.getString(_keyShopPhoto),
      'isClosed': _prefs.getBool(_keyIsClosed) ?? false,
    };
  }

  // Clear Session
  static Future<void> clearAll() async {
    // Keep remember login flag if needed, but clear token and credentials
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyShopName);
    await _prefs.remove(_keyOwnerName);
    await _prefs.remove(_keyMobile);
    await _prefs.remove(_keyAddress);
    await _prefs.remove(_keyOpeningTime);
    await _prefs.remove(_keyClosingTime);
    await _prefs.remove(_keyShopPhoto);
    await _prefs.remove(_keyIsClosed);
  }
}
