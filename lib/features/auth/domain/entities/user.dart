class User {
  final String shopName;
  final String ownerName;
  final String mobile;
  final String address;
  final String openingTime;
  final String closingTime;
  final String? shopPhoto;

  User({
    required this.shopName,
    required this.ownerName,
    required this.mobile,
    required this.address,
    required this.openingTime,
    required this.closingTime,
    this.shopPhoto,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      shopName: json['shop_name'] ?? '',
      ownerName: json['owner_name'] ?? '',
      mobile: json['mobile'] ?? '',
      address: json['address'] ?? json['shop_address'] ?? '',
      openingTime: json['opening_time'] ?? '06:00 AM',
      closingTime: json['closing_time'] ?? '08:00 PM',
      shopPhoto: json['shop_photo'] ?? json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_name': shopName,
      'owner_name': ownerName,
      'mobile': mobile,
      'address': address,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'shop_photo': shopPhoto,
    };
  }
}
