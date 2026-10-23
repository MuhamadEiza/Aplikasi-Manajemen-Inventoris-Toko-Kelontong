import '../models/product.dart';

/// INTERFACE (Kontrak) untuk akses data Produk.
/// UI hanya kenal ini
/// Tujuan: Menerapkan prinsip "Dependency Inversion" dan "Repository Pattern". 
/// UI tidak boleh tahu apakah data berasal dari Dummy (UTS) atau Database asli (UAS).
/// Saat migrasi ke UAS, kita cukup membuat class ApiProductRepository yang
/// meng-implement interface ini tanpa harus merombak halaman UI.
abstract class ProductRepository {
  
  /// Kontrak untuk mengambil semua daftar produk.
  Future<List<Product>> getAllProducts();
  
  /// Kontrak untuk mengambil satu produk spesifik berdasarkan ID.
  Future<Product?> getProductById(String id);
  
  /// Kontrak untuk menambahkan produk baru.
  Future<void> addProduct(Product product);
  
  /// Kontrak untuk mengubah data produk yang sudah ada.
  Future<void> updateProduct(Product product);
  
  /// Kontrak untuk menghapus produk berdasarkan ID.
  Future<void> deleteProduct(String id);
}