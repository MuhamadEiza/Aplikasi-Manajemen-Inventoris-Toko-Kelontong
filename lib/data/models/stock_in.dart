/// Model StockIn — header barang masuk
class StockIn {
  final String id;
  final DateTime date;
  final String? vendorId;
  final String? vendorName;
  final List<StockInItem> items;
  final String? proofImagePath;

  StockIn({
    required this.id,
    required this.date,
    this.vendorId,
    this.vendorName,
    required this.items,
    this.proofImagePath,
  });

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
}

class StockInItem {
  final String productId;
  final String productName;
  final int quantity;
  final double purchasePrice;

  StockInItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.purchasePrice,
  });

  double get subtotal => quantity * purchasePrice;
}