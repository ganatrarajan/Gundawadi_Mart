import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class ProductsProvider extends ChangeNotifier {
  final ApiClient apiClient;

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _products = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get products => _products;

  ProductsProvider(this.apiClient);

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await apiClient.dio.get('/vendor/products');
      if (response.data['success'] == true) {
        _products = response.data['data'];
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to load products.';
    }
    _setLoading(false);
  }

  Future<bool> quickUpdatePrice(int productId, double price) async {
    try {
      final response = await apiClient.dio.patch('/vendor/products/$productId/price', data: {
        'today_price': price,
      });
      if (response.data['success'] == true) {
        final index = _products.indexWhere((p) => p['id'] == productId);
        if (index != -1) {
          _products[index]['today_price'] = price.toStringAsFixed(2);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleAvailability(int productId) async {
    try {
      final response = await apiClient.dio.post('/vendor/products/$productId/toggle');
      if (response.data['success'] == true) {
        final index = _products.indexWhere((p) => p['id'] == productId);
        if (index != -1) {
          final currentStatus = _products[index]['status'];
          _products[index]['status'] = currentStatus == 'active' ? 'inactive' : 'active';
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveProduct({
    required int categoryId,
    required String name,
    required double price,
    required String unit,
  }) async {
    _setLoading(true);
    try {
      final response = await apiClient.dio.post('/vendor/products', data: {
        'category_id': categoryId,
        'name': name,
        'today_price': price,
        'unit': unit,
      });

      if (response.data['success'] == true) {
        await fetchProducts();
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }
}
