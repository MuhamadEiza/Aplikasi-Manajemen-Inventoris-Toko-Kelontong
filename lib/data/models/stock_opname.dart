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

  double get totalDifferenceValue =>
      items.fold(0, (sum, item) => sum + item.differenceValue);
}

class StockOpnameItem {
  final String productId;
  final String productName;
  final int systemStock;
  final int physicalStock;
  final String? note;
  final double purchasePrice;

  StockOpnameItem({
    required this.productId,
    required this.productName,
    required this.systemStock,
    required this.physicalStock,
    this.note,
    required this.purchasePrice,
  });

  int get difference => physicalStock - systemStock;
  double get differenceValue => difference * purchasePrice;
}