import 'product_model.dart';

class CartItem {
  final ProductModel product;
  final String optionLabel; // e.g., '500g', '1kg', '2kg', '1 piece', 'Custom (1.5 kg)'
  final double pricePerUnit; // price of this selected weight/unit option
  final int vendorId;
  final String vendorName;
  int quantity; // number of items of this selected option

  CartItem({
    required this.product,
    required this.optionLabel,
    required this.pricePerUnit,
    required this.vendorId,
    required this.vendorName,
    required this.quantity,
  });

  double get totalPrice => pricePerUnit * quantity;

  // Convert to JSON for api placement
  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'name': product.name,
      'unit': optionLabel,
      'price': pricePerUnit,
      'quantity': quantity,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
    };
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'product': product.toJson(),
      'option_label': optionLabel,
      'price_per_unit': pricePerUnit,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'quantity': quantity,
    };
  }

  factory CartItem.fromLocalJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      optionLabel: json['option_label']?.toString() ?? '',
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble() ?? 0.0,
      vendorId: (json['vendor_id'] as num?)?.toInt() ?? 0,
      vendorName: json['vendor_name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
