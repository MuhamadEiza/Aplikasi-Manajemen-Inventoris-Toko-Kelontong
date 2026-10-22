/// Model StockOpname
class StockOpname {
  final String id;
  final DateTime date;
  final List<StockOpnameItem> items;

  StockOpname({
    required this.id,
    required this.date,
    required this.items,
  });

  /// Total selisih nilai (Rp)
  /// Contoh: -2 pcs × Rp 2.500 = -Rp 5.000
  double get totalDifferenceValue =>
      items.fold(0, (sum, item) => sum + item.differenceValue);

  /// Total selisih unit
  /// Contoh: -2 pcs + 0 + -1 = -3 unit
  int get totalDifferenceUnit =>
      items.fold(0, (sum, item) => sum + item.difference);
}

/// Detail item StockOpname
class StockOpnameItem {
  final String productId;
  final String productName;
  final int systemStock;      // stok sistem (auto)
  final int physicalStock;    // stok fisik (input)
  final String? note;         // keterangan
  final double purchasePrice; // untuk hitung selisih nilai

  StockOpnameItem({
    required this.productId,
    required this.productName,
    required this.systemStock,
    required this.physicalStock,
    this.note,
    required this.purchasePrice,
  });

  /// Selisih: fisik - sistem
  /// Contoh: 108 - 110 = -2
  int get difference => physicalStock - systemStock;

  /// Selisih nilai (Rp)
  /// Contoh: -2 × Rp 2.500 = -Rp 5.000
  double get differenceValue => difference * purchasePrice;
}