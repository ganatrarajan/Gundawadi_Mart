import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DioClient _dioClient;

  ProductRepositoryImpl(this._dioClient);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.products);
      final List list = response.data['data'] as List;
      return list.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load products.');
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.products,
        data: product.toJson(),
      );
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to add product.');
    }
  }

  @override
  Future<Product> editProduct(Product product) async {
    try {
      final response = await _dioClient.dio.put(
        ApiEndpoints.products,
        data: product.toJson(),
      );
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to update product.');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _dioClient.dio.delete('${ApiEndpoints.products}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete product.');
    }
  }

  @override
  Future<Product> toggleProduct(int id) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.toggleProduct,
        data: {'id': id},
      );
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to enable/disable product.');
    }
  }

  @override
  Future<Product> updatePrice(int id, double price) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.updatePrice,
        data: {
          'id': id,
          'price': price,
        },
      );
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to update price.');
    }
  }

  @override
  Future<String> uploadImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });

      final response = await _dioClient.dio.post(
        ApiEndpoints.uploadProductImage,
        data: formData,
      );

      return response.data['data']['image_url'];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to upload product image.');
    }
  }
}
