import 'product_model.dart';

class CartItem {
  final ProductModel product;
  final String optionLabel; // e.g., '500g', '1kg', '2kg', '1 piece', 'Custom (1.5 kg)'
  final double pricePerUnit; // price of this selected weight/unit option
  int quantity; // number of items of this selected option

  CartItem({
    required this.product,
    required this.optionLabel,
    required this.pricePerUnit,
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
    };
  }
}
