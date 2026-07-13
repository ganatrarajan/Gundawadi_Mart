class Product {
  final int? id;
  final String name;
  final double price;
  final String unit; // kg, bunch, piece
  final bool isEnabled;
  final String? imageUrl;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.isEnabled = true,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }

    double parsePrice(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    bool parseEnabled(dynamic val) {
      if (val == null) return true;
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) {
        return val == '1' || val.toLowerCase() == 'true' || val.toLowerCase() == 'active';
      }
      return true;
    }

    return Product(
      id: parseId(json['id']),
      name: json['name']?.toString() ?? '',
      price: parsePrice(json['price'] ?? json['today_price']),
      unit: json['unit']?.toString() ?? 'kg',
      isEnabled: parseEnabled(json['is_enabled'] ?? json['status']),
      imageUrl: json['image_url'] ?? json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'unit': unit,
      'is_enabled': isEnabled,
      'image_url': imageUrl,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? unit,
    bool? isEnabled,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      isEnabled: isEnabled ?? this.isEnabled,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
