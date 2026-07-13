import '../../core/constants/api_endpoints.dart';

class ProductModel {
  final int id;
  final String name;
  final String imageUrl;
  final double todayPrice;
  final String unit; // 'kg', '500g', '250g', 'piece'
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.todayPrice,
    required this.unit,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return ProductModel(
      id: parseId(json['id']),
      name: json['name']?.toString() ?? '',
      imageUrl: ApiEndpoints.formatImageUrl(json['image_url'] ?? json['image']?.toString()),
      todayPrice: parseDouble(json['today_price'] ?? json['price']),
      unit: json['unit']?.toString() ?? 'kg',
      category: json['category']?['name']?.toString() ?? json['category']?.toString() ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'today_price': todayPrice,
      'unit': unit,
      'category': category,
    };
  }
}
