import '../models/product.dart';
import '../repositories/product_repository.dart';

/// Data dummy 8 produk realistis
class DummyProductRepository implements ProductRepository {
  final List<Product> _products = [
    Product(id: 'p001', name: 'Indomie Goreng', category: 'Makanan Instan',
      unit: 'pcs', purchasePrice: 2500, sellingPrice: 3000,
      currentStock: 50, minimumStock: 10),
    Product(id: 'p002', name: 'Aqua 600ml', category: 'Minuman',
      unit: 'botol', purchasePrice: 2000, sellingPrice: 3000,
      currentStock: 24, minimumStock: 12),
    Product(id: 'p003', name: 'Beras Premium', category: 'Sembako',
      unit: 'kg', purchasePrice: 12000, sellingPrice: 14000,
      currentStock: 8, minimumStock: 10),
    Product(id: 'p004', name: 'Gula Pasir', category: 'Sembako',
      unit: 'kg', purchasePrice: 14000, sellingPrice: 16000,
      currentStock: 35, minimumStock: 5),
    Product(id: 'p005', name: 'Minyak Goreng', category: 'Sembako',
      unit: 'liter', purchasePrice: 15000, sellingPrice: 17000,
      currentStock: 0, minimumStock: 5),
    Product(id: 'p006', name: 'Teh Pucuk 350ml', category: 'Minuman',
      unit: 'botol', purchasePrice: 2500, sellingPrice: 4000,
      currentStock: 48, minimumStock: 12),
    Product(id: 'p007', name: 'Kopi Kapal Api', category: 'Minuman',
      unit: 'pcs', purchasePrice: 1500, sellingPrice: 2000,
      currentStock: 60, minimumStock: 20),
    Product(id: 'p008', name: 'Sabun Lifebuoy', category: 'Kebersihan',
      unit: 'pcs', purchasePrice: 4000, sellingPrice: 5500,
      currentStock: 15, minimumStock: 5),
  ];

  @override
  Future<List<Product>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_products);
  }

  @override
  Future<Product?> getProductById(String id) async {
    try { return _products.firstWhere((p) => p.id == id); }
    catch (_) { return null; }
  }

  @override
  Future<void> addProduct(Product product) async {
    _products.add(product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final i = _products.indexWhere((p) => p.id == product.id);
    if (i != -1) _products[i] = product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
  }
}