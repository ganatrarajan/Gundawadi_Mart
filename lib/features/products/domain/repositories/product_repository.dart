import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> addProduct(Product product);
  Future<Product> editProduct(Product product);
  Future<void> deleteProduct(int id);
  Future<Product> toggleProduct(int id);
  Future<Product> updatePrice(int id, double price);
  Future<String> uploadImage(String filePath);
}
