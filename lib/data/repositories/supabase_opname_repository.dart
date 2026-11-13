import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stock_opname.dart';
import 'opname_repository.dart';

class SupabaseOpnameRepository implements OpnameRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<StockOpname>> getAllOpname() async {
    final response = await _supabase
        .from('stock_opname')
        .select('*, stock_opname_items(*)')
        .order('date', ascending: false);

    return (response as List).map((data) {
      final itemsData = data['stock_opname_items'] as List;
      return StockOpname(
        id: data['id'],
        date: DateTime.parse(data['date']),
        note: data['note'],
        items: itemsData.map((item) {
          return StockOpnameItem(
            productId: item['product_id'],
            productName: item['product_name'],
            systemStock: item['system_stock'],
            physicalStock: item['physical_stock'],
            note: item['note'],
            purchasePrice: (item['purchase_price'] as num).toDouble(),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Future<void> addOpname(StockOpname opname) async {
    // 1. Simpan Header
    final headerRes = await _supabase.from('stock_opname').insert({
      'id': opname.id,
      'date': opname.date.toIso8601String(),
      'note': opname.note,
    }).select().single();

    final newOpnameId = headerRes['id'];

    // 2. Simpan Detail Item & Update Stok Fisik ke Tabel Produk
    for (var item in opname.items) {
      // Simpan ke detail opname
      await _supabase.from('stock_opname_items').insert({
        'opname_id': newOpnameId,
        'product_id': item.productId,
        'product_name': item.productName,
        'system_stock': item.systemStock,
        'physical_stock': item.physicalStock,
        'difference': item.difference,
        'note': item.note,
        'purchase_price': item.purchasePrice,
      });

      // SINKRONISASI: Ubah stok di tabel products menjadi stok fisik (hasil hitung)
      await _supabase.from('products').update({
        'current_stock': item.physicalStock,
      }).eq('id', item.productId);
    }
  }
}