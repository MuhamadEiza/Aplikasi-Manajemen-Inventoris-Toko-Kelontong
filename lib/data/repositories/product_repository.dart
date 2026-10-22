import '../models/product.dart';

/// INTERFACE — UI hanya kenal ini
abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<Product?> getProductById(String id);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}