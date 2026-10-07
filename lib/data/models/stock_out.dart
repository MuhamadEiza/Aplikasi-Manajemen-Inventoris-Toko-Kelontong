/// Model StockOut — header barang keluar
class StockOut {
  final String id;
  final DateTime date;
  final String? customerId;
  final String? customerName;
  final List<StockOutItem> items;
  final String? proofImagePath;

  StockOut({
    required this.id,
    required this.date,
    this.customerId,
    this.customerName,
    required this.items,
    this.proofImagePath,
  });

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  double get totalProfit => items.fold(0, (sum, item) => sum + item.profit);
}

class StockOutItem {
  final String productId;
  final String productName;
  final int quantity;
  final double sellingPrice;
  final double purchasePrice;

  StockOutItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.sellingPrice,
    required this.purchasePrice,
  });

  double get subtotal => quantity * sellingPrice;
  double get profit => (sellingPrice - purchasePrice) * quantity;
}