import '../../core/constants/api_endpoints.dart';
import 'product_model.dart';

class VendorModel {
  final int id;
  final String shopName;
  final String ownerName;
  final String shopPhoto;
  final bool isOpen;
  final List<ProductModel> products;

  VendorModel({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.shopPhoto,
    required this.isOpen,
    this.products = const [],
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json.containsKey('vendor') && json['vendor'] is Map
        ? json['vendor'] as Map<String, dynamic>
        : json;

    var list = json['products'] as List? ?? data['products'] as List?;
    List<ProductModel> productList = list != null
        ? list.map((i) => ProductModel.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    int parseId(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) {
        return val == '1' || val.toLowerCase() == 'true' || val.toLowerCase() == 'open';
      }
      return false;
    }

    final rawShopPhoto = data['shop_photo']?.toString() ?? 
                         data['photo']?.toString() ?? 
                         '';

    final rawOwnerName = data['owner_name']?.toString() ?? 
                         data['owner']?['name']?.toString() ?? 
                         '';

    return VendorModel(
      id: parseId(data['id'] ?? json['id']),
      shopName: data['shop_name']?.toString() ?? json['shop_name']?.toString() ?? '',
      ownerName: rawOwnerName,
      shopPhoto: ApiEndpoints.formatImageUrl(rawShopPhoto),
      isOpen: parseBool(data['is_open'] ?? data['is_shop_open'] ?? json['is_open']),
      products: productList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_name': shopName,
      'owner_name': ownerName,
      'shop_photo': shopPhoto,
      'is_open': isOpen,
      'products': products.map((e) => e.toJson()).toList(),
    };
  }
}
