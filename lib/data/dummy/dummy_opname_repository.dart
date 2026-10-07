import '../models/stock_opname.dart';
import '../repositories/opname_repository.dart';

class DummyOpnameRepository implements OpnameRepository {
  final List<StockOpname> _opname = [
    StockOpname(
      id: 'op001', date: DateTime(2026, 6, 18),
      items: [
        StockOpnameItem(productId: 'p001', productName: 'Indomie Goreng',
          systemStock: 110, physicalStock: 108, note: 'Barang rusak',
          purchasePrice: 2500),
        StockOpnameItem(productId: 'p003', productName: 'Beras Premium',
          systemStock: 8, physicalStock: 7, note: 'Tumpah',
          purchasePrice: 12000),
      ],
    ),
  ];

  @override
  Future<List<StockOpname>> getAllOpname() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_opname);
  }

  @override
  Future<void> addOpname(StockOpname opname) async {
    _opname.insert(0, opname);
  }
}