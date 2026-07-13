import '../../core/constants/api_endpoints.dart';

class UserModel {
  final int id;
  final String name;
  final String mobile;
  final String status;
  final String? rejectionReason;
  final double? deliveryKm;
  final double? deliveryCharge;
  final double handlingCharge;
  final double platformFee;
  final bool showHandlingCharge;
  final bool showPlatformFee;
  final List<String> deliveryTimeSlots;
  final String? profilePhoto;
  final AddressModel? address;
  final AddressModel? pendingAddress;

  UserModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.status,
    this.rejectionReason,
    this.deliveryKm,
    this.deliveryCharge,
    this.handlingCharge = 5.0,
    this.platformFee = 10.0,
    this.showHandlingCharge = true,
    this.showPlatformFee = true,
    this.deliveryTimeSlots = const [],
    this.profilePhoto,
    this.address,
    this.pendingAddress,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    bool parseBool(dynamic val, bool defaultVal) {
      if (val == null) return defaultVal;
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) {
        final lower = val.toLowerCase().trim();
        return lower == '1' || lower == 'true' || lower == 'yes' || lower == 'y' || lower == 'show';
      }
      return defaultVal;
    }

    List<String> parseSlots(dynamic val) {
      if (val == null) return const [];
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return const [];
    }

    return UserModel(
      id: parseId(json['id']),
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending_approval',
      rejectionReason: json['rejection_reason']?.toString(),
      deliveryKm: parseDouble(json['delivery_km']),
      deliveryCharge: parseDouble(json['delivery_charge']),
      handlingCharge: parseDouble(json['handling_charge'] ?? json['handling_fee']) ?? 5.0,
      platformFee: parseDouble(json['platform_fee'] ?? json['platform_charge']) ?? 10.0,
      showHandlingCharge: parseBool(json['show_handling_charge'] ?? json['handling_charge_enabled'] ?? json['show_handling'], true),
      showPlatformFee: parseBool(json['show_platform_fee'] ?? json['platform_fee_enabled'] ?? json['show_platform'], true),
      deliveryTimeSlots: parseSlots(json['delivery_time_slots']),
      profilePhoto: ApiEndpoints.formatImageUrl(json['profile_photo']?.toString()),
      address: json['address'] != null 
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>) 
          : null,
      pendingAddress: json['pending_address'] != null
          ? AddressModel.fromJson(json['pending_address'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'status': status,
      'rejection_reason': rejectionReason,
      'delivery_km': deliveryKm,
      'delivery_charge': deliveryCharge,
      'handling_charge': handlingCharge,
      'platform_fee': platformFee,
      'show_handling_charge': showHandlingCharge,
      'show_platform_fee': showPlatformFee,
      'delivery_time_slots': deliveryTimeSlots,
      'profile_photo': profilePhoto,
      'address': address?.toJson(),
      'pending_address': pendingAddress?.toJson(),
    };
  }

  UserModel copyWith({
    String? name,
    String? mobile,
    String? status,
    String? rejectionReason,
    double? deliveryKm,
    double? deliveryCharge,
    double? handlingCharge,
    double? platformFee,
    bool? showHandlingCharge,
    bool? showPlatformFee,
    List<String>? deliveryTimeSlots,
    String? profilePhoto,
    AddressModel? address,
    AddressModel? pendingAddress,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      deliveryKm: deliveryKm ?? this.deliveryKm,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      handlingCharge: handlingCharge ?? this.handlingCharge,
      platformFee: platformFee ?? this.platformFee,
      showHandlingCharge: showHandlingCharge ?? this.showHandlingCharge,
      showPlatformFee: showPlatformFee ?? this.showPlatformFee,
      deliveryTimeSlots: deliveryTimeSlots ?? this.deliveryTimeSlots,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      address: address ?? this.address,
      pendingAddress: pendingAddress ?? this.pendingAddress,
    );
  }
}

class AddressModel {
  final int? id;
  final String houseNumber;
  final String street;
  final String area;
  final String landmark;
  final String city;
  final String pincode;
  final String? status;
  final double? deliveryKm;
  final double? deliveryCharge;

  AddressModel({
    this.id,
    required this.houseNumber,
    required this.street,
    required this.area,
    required this.landmark,
    required this.city,
    required this.pincode,
    this.status,
    this.deliveryKm,
    this.deliveryCharge,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    return AddressModel(
      id: parseId(json['id']),
      houseNumber: json['house_number']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      city: json['city']?.toString() ?? 'Rajkot',
      pincode: json['pincode']?.toString() ?? '',
      status: json['status']?.toString(),
      deliveryKm: parseDouble(json['delivery_km']),
      deliveryCharge: parseDouble(json['delivery_charge']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'house_number': houseNumber,
      'street': street,
      'area': area,
      'landmark': landmark,
      'city': city,
      'pincode': pincode,
      'status': status,
      'delivery_km': deliveryKm,
      'delivery_charge': deliveryCharge,
    };
  }

  String get fullAddress {
    List<String> parts = [];
    if (houseNumber.isNotEmpty) parts.add(houseNumber);
    if (street.isNotEmpty) parts.add(street);
    if (area.isNotEmpty) parts.add(area);
    if (landmark.isNotEmpty) parts.add('Near $landmark');
    if (city.isNotEmpty) parts.add(city);
    if (pincode.isNotEmpty) parts.add(pincode);
    return parts.join(', ');
  }
}
