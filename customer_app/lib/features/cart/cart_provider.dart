import 'package:flutter/material.dart';

class CartItem {
  final int productId;
  final String name;
  final double price;
  final String unit;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.unit,
    required this.quantity,
  });

  double get totalPrice => price * quantity;
}

class CartProvider extends ChangeNotifier {
  int? _currentVendorId;
  final Map<int, CartItem> _items = {};
  String _specialNote = '';

  int? get currentVendorId => _currentVendorId;
  List<CartItem> get items => _items.values.toList();
  String get specialNote => _specialNote;

  int get itemsCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addToCart({
    required int vendorId,
    required int productId,
    required String name,
    required double price,
    required String unit,
  }) {
    if (_currentVendorId != null && _currentVendorId != vendorId) {
      clearCart();
    }
    
    _currentVendorId = vendorId;
    
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += 1;
    } else {
      _items[productId] = CartItem(
        productId: productId,
        name: name,
        price: price,
        unit: unit,
        quantity: 1,
      );
    }
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (!_items.containsKey(productId)) return;

    if (quantity <= 0) {
      _items.remove(productId);
      if (_items.isEmpty) {
        _currentVendorId = null;
      }
    } else {
      _items[productId]!.quantity = quantity;
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      if (_items.isEmpty) {
        _currentVendorId = null;
      }
      notifyListeners();
    }
  }

  void setSpecialNote(String note) {
    _specialNote = note;
    notifyListeners();
  }

  int getProductQuantity(int productId) {
    return _items[productId]?.quantity ?? 0;
  }

  void clearCart() {
    _items.clear();
    _currentVendorId = null;
    _specialNote = '';
    notifyListeners();
  }
}
