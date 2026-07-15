import 'package:flutter/material.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/product_model.dart';
import '../../core/services/storage_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String _specialInstructions = '';

  CartProvider() {
    _loadCartFromStorage();
  }

  void _loadCartFromStorage() {
    try {
      final localItems = StorageService.instance.getCartItems();
      _items.clear();
      for (final itemJson in localItems) {
        _items.add(CartItem.fromLocalJson(itemJson));
      }
    } catch (e) {
      debugPrint("Error loading cart: $e");
    }
  }

  void _saveCartToStorage() {
    try {
      final localItemsJson = _items.map((e) => e.toLocalJson()).toList();
      StorageService.instance.saveCartItems(localItemsJson);
    } catch (e) {
      debugPrint("Error saving cart: $e");
    }
  }

  List<CartItem> get items => _items;
  int? get activeVendorId => _items.isEmpty ? null : _items.first.vendorId;
  String? get activeVendorName => _items.isEmpty ? null : _items.first.vendorName;
  String get specialInstructions => _specialInstructions;

  int get totalItemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get deliveryCharge {
    if (_items.isEmpty) return 0.0;
    // Flat delivery charge of ₹30, free delivery on orders above ₹500
    return subtotal >= 500.0 ? 0.0 : 30.0;
  }

  double get total => subtotal + deliveryCharge;

  // Multi-vendor checkout allows items from any vendor
  bool hasVendorConflict(int vendorId) {
    return false;
  }

  // Add Item to Cart
  void addToCart({
    required ProductModel product,
    required String optionLabel,
    required double pricePerUnit,
    required int vendorId,
    required String vendorName,
    int quantity = 1,
  }) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id && item.optionLabel == optionLabel,
    );

    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          optionLabel: optionLabel,
          pricePerUnit: pricePerUnit,
          vendorId: vendorId,
          vendorName: vendorName,
          quantity: quantity,
        ),
      );
    }
    _saveCartToStorage();
    notifyListeners();
  }

  // Update quantity (+1 / -1)
  void updateQuantity(int productId, String optionLabel, int change) {
    final index = _items.indexWhere(
      (item) => item.product.id == productId && item.optionLabel == optionLabel,
    );

    if (index != -1) {
      final newQty = _items[index].quantity + change;
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQty;
      }
      _saveCartToStorage();
      notifyListeners();
    }
  }

  // Remove Item fully
  void removeItem(int productId, String optionLabel) {
    _items.removeWhere(
      (item) => item.product.id == productId && item.optionLabel == optionLabel,
    );
    _saveCartToStorage();
    notifyListeners();
  }

  // Special instructions
  void setSpecialInstructions(String text) {
    _specialInstructions = text;
    notifyListeners();
  }

  // Reset active vendor
  void resetActiveVendor() {
    _specialInstructions = '';
  }

  // Clear Cart
  void clearCart() {
    _items.clear();
    resetActiveVendor();
    _saveCartToStorage();
    notifyListeners();
  }

  // Get quantity of a specific product and option combination
  int getItemQuantity(int productId, String optionLabel) {
    final index = _items.indexWhere(
      (item) => item.product.id == productId && item.optionLabel == optionLabel,
    );
    return index != -1 ? _items[index].quantity : 0;
  }
}
