import '../models/product.dart';
import '../repositories/product_repository.dart';

/// Data dummy 8 produk realistis
/// Setiap produk diberi barcode dummy (format EAN-13)
class DummyProductRepository implements ProductRepository {
  
  // List ini mensimulasikan isi tabel 'products' di database.
  // Digunakan sebagai sumber data sementara (hardcode) selama fase UTS.
  final List<Product> _products = [
    Product(
      id: 'p001',
      name: 'Indomie Goreng',
      category: 'Makanan Instan',
      unit: 'pcs',
      purchasePrice: 2500,
      sellingPrice: 3000,
      currentStock: 50,
      minimumStock: 10,
      barcode: '8992388101010',
      location: 'Rak A1',
    ),
    Product(
      id: 'p002',
      name: 'Aqua 600ml',
      category: 'Minuman',
      unit: 'botol',
      purchasePrice: 2000,
      sellingPrice: 3000,
      currentStock: 24,
      minimumStock: 12,
      barcode: '8886002101010',
      location: 'Rak B2',
    ),
    Product(
      id: 'p003',
      name: 'Beras Premium',
      category: 'Sembako',
      unit: 'kg',
      purchasePrice: 12000,
      sellingPrice: 14000,
      currentStock: 8,
      minimumStock: 10,
      barcode: '8991234567890',
      location: 'Karung Besar',
    ),
    Product(
      id: 'p004',
      name: 'Gula Pasir',
      category: 'Sembako',
      unit: 'kg',
      purchasePrice: 14000,
      sellingPrice: 16000,
      currentStock: 35,
      minimumStock: 5,
      barcode: '8991234567891',
      location: 'Karung Kecil',
    ),
    Product(
      id: 'p005',
      name: 'Minyak Goreng',
      category: 'Sembako',
      unit: 'liter',
      purchasePrice: 15000,
      sellingPrice: 17000,
      currentStock: 0,
      minimumStock: 5,
      barcode: '8991234567892',
      location: 'Rak C1',
    ),
    Product(
      id: 'p006',
      name: 'Teh Pucuk 350ml',
      category: 'Minuman',
      unit: 'botol',
      purchasePrice: 2500,
      sellingPrice: 4000,
      currentStock: 48,
      minimumStock: 12,
      barcode: '8886002101020',
      location: 'Rak B3',
    ),
    Product(
      id: 'p007',
      name: 'Kopi Kapal Api',
      category: 'Minuman',
      unit: 'pcs',
      purchasePrice: 1500,
      sellingPrice: 2000,
      currentStock: 60,
      minimumStock: 20,
      barcode: '8991234567893',
      location: 'Rak B1',
    ),
    Product(
      id: 'p008',
      name: 'Sabun Lifebuoy',
      category: 'Kebersihan',
      unit: 'pcs',
      purchasePrice: 4000,
      sellingPrice: 5500,
      currentStock: 15,
      minimumStock: 5,
      barcode: '8991234567894',
      location: 'Rak D1',
    ),
  ];

  @override
  Future<List<Product>> getAllProducts() async {
    // Simulasi jeda loading (300ms) agar UI terlihat lebih natural saat memuat data.
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mengembalikan salinan list (copy) agar UI tidak bisa mengubah data secara langsung.
    return List.from(_products);
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      // Mencari 1 produk berdasarkan ID-nya.
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      // Jika ID tidak ditemukan, kembalikan null (tidak error/crash).
      return null;
    }
  }

  /// Cari produk berdasarkan barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      // Fitur tambahan UTS: mencari produk dengan scan/input barcode.
      return _products.firstWhere((p) => p.barcode == barcode);
    } catch (_) {
      return null; // Barcode tidak terdaftar
    }
  }

  @override
  Future<void> addProduct(Product product) async {
    // Menambahkan produk baru ke dalam list.
    _products.add(product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    // Mencari index produk yang akan diubah berdasarkan ID.
    final i = _products.indexWhere((p) => p.id == product.id);
    
    // Jika produk ditemukan (index tidak -1), timpa data lama dengan data baru.
    if (i != -1) _products[i] = product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    // Menghapus produk dari list berdasarkan ID.
    _products.removeWhere((p) => p.id == id);
  }
}