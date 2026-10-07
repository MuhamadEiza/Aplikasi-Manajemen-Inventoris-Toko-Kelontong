import '../models/stock_in.dart';
import '../models/stock_out.dart';
import '../repositories/stock_repository.dart';

class DummyStockRepository implements StockRepository {
  final List<StockIn> _stockIn = [
    StockIn(
      id: 'si001', date: DateTime(2026, 6, 18),
      vendorId: 'v001', vendorName: 'Agen Sembako Jaya',
      items: [
        StockInItem(productId: 'p001', productName: 'Indomie Goreng',
          quantity: 100, purchasePrice: 2500),
      ],
      proofImagePath: 'dummy/nota_001.jpg',
    ),
  ];

  final List<StockOut> _stockOut = [
    StockOut(
      id: 'so001', date: DateTime(2026, 6, 18),
      customerId: 'c001', customerName: 'Bu Sari',
      items: [
        StockOutItem(productId: 'p001', productName: 'Indomie Goreng',
          quantity: 10, sellingPrice: 3000, purchasePrice: 2500),
      ],
      proofImagePath: 'dummy/struk_001.jpg',
    ),
  ];

  @override
  Future<List<StockIn>> getAllStockIn() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_stockIn);
  }

  @override
  Future<void> addStockIn(StockIn stockIn) async {
    _stockIn.insert(0, stockIn);
  }

  @override
  Future<List<StockOut>> getAllStockOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_stockOut);
  }

  @override
  Future<void> addStockOut(StockOut stockOut) async {
    _stockOut.insert(0, stockOut);
  }
}