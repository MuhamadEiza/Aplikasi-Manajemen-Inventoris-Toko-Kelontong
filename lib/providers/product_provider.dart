import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';

/// Provider untuk Product
/// Menyimpan list produk + logic bisnis
class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  List<Product> _products = [];
  bool _isLoading = false;

  ProductProvider(this._repository);

  // Getter
  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  /// Total nilai inventaris (stok × harga beli)
  double get totalInventoryValue =>
      _products.fold(0, (sum, p) => sum + (p.currentStock * p.purchasePrice));

  /// Jumlah barang stok menipis (LOW + OUT)
  int get lowStockCount => _products
      .where((p) => p.stockStatus == 'LOW' || p.stockStatus == 'OUT')
      .length;

  /// Load semua produk dari repository
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    _products = await _repository.getAllProducts();

    _isLoading = false;
    notifyListeners();
  }

  /// Tambah produk
  Future<void> addProduct(Product product) async {
    await _repository.addProduct(product);
    await loadProducts();
  }

  /// Update produk
  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);
    await loadProducts();
  }

  /// Hapus produk
  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    await loadProducts();
  }

  /// Cari produk by ID
  Product? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Filter by kategori
  List<Product> filterByCategory(String category) {
    if (category == 'Semua') return _products;
    return _products.where((p) => p.category == category).toList();
  }

  /// Search by nama
  List<Product> search(String query) {
    if (query.isEmpty) return _products;
    return _products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}