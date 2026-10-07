/// Model Product — merepresentasikan 1 barang di toko
class Product {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double purchasePrice;
  final double sellingPrice;
  final int currentStock;
  final int minimumStock;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.minimumStock,
  });

  double get marginPercent =>
      purchasePrice > 0 ? (sellingPrice - purchasePrice) / purchasePrice : 0;

  double get marginRupiah => sellingPrice - purchasePrice;

  String get stockStatus {
    if (currentStock == 0) return 'OUT';
    if (currentStock <= minimumStock) return 'LOW';
    if (currentStock <= minimumStock * 2) return 'MODERATE';
    return 'SAFE';
  }
}