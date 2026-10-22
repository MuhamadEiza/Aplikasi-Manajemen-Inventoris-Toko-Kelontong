/// Model Product — merepresentasikan 1 barang di toko
/// v2: tambah field barcode (EAN13, CODE128, dll)
class Product {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double purchasePrice;
  final double sellingPrice;
  final int currentStock;
  final int minimumStock;
  final String? barcode;   // ← BARU: kode barcode
  final String? location;  // ← lokasi penyimpanan (opsional)

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.minimumStock,
    this.barcode,
    this.location,
  });

  /// Margin otomatis: (jual - beli) / beli
  double get marginPercent =>
      purchasePrice > 0 ? (sellingPrice - purchasePrice) / purchasePrice : 0;

  /// Margin dalam rupiah
  double get marginRupiah => sellingPrice - purchasePrice;

  /// Status stok
  String get stockStatus {
    if (currentStock == 0) return 'OUT';
    if (currentStock <= minimumStock) return 'LOW';
    if (currentStock <= minimumStock * 2) return 'MODERATE';
    return 'SAFE';
  }

  /// Apakah produk punya barcode?
  bool get hasBarcode => barcode != null && barcode!.isNotEmpty;

  /// Copy with — untuk update sebagian field
  Product copyWith({
    String? name,
    String? category,
    String? unit,
    double? purchasePrice,
    double? sellingPrice,
    int? currentStock,
    int? minimumStock,
    String? barcode,
    String? location,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      barcode: barcode ?? this.barcode,
      location: location ?? this.location,
    );
  }
}