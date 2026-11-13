import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/stock_in.dart';
import '../models/stock_out.dart';
import 'stock_repository.dart';

class SupabaseStockRepository implements StockRepository {
  final _supabase = Supabase.instance.client;

  // ==========================================
  // 1. BARANG MASUK (Stock In)
  // ==========================================
  @override
  Future<List<StockIn>> getAllStockIn() async {
    final response = await _supabase
        .from('stock_in')
        .select('*, stock_in_items(*)')
        .order('date', ascending: false);

    return (response as List).map((data) {
      final itemsData = data['stock_in_items'] as List;
      return StockIn(
        id: data['id'],
        date: DateTime.parse(data['date']),
        vendorId: data['vendor_id'],
        vendorName: data['vendor_name'],
        proofImagePath: data['proof_image_path'],
        initialStock: itemsData.isNotEmpty ? itemsData.first['quantity'] : 0,
        items: itemsData.map((item) {
          return StockInItem(
            productId: item['product_id'],
            productName: item['product_name'] ?? 'Tanpa Nama',
            category: item['category'] ?? 'Sembako',
            quantity: item['quantity'],
            purchasePrice: (item['purchase_price'] as num).toDouble(),
          );
        }).toList(),
      );
    }).toList();
  }

   @override
  Future<void> addStockIn(StockIn stockIn) async {
    // 1. Simpan Header
    final headerRes = await _supabase
        .from('stock_in')
        .insert({
          'id': stockIn.id,
          'date': stockIn.date.toIso8601String(),
          'vendor_id': stockIn.vendorId,
          'vendor_name': stockIn.vendorName,
          'proof_image_path': stockIn.proofImagePath,
        })
        .select()
        .single();

    final newStockInId = headerRes['id'];

    // 2. Simpan Item dan Produk satu per satu (TUNGGU SELESAI)
    for (var item in stockIn.items) {
      // Simpan ke Master Produk
      await _supabase.from('products').upsert({
        'id': item.productId,
        'name': item.productName,
        'category': item.category,
        'unit': 'pcs',
        'purchase_price': item.purchasePrice,
        'selling_price': item.purchasePrice * 1.2,
        'initial_stock': item.quantity,
        'current_stock': item.quantity,
        'minimum_stock': 5,
      }, onConflict: 'id');

      // Simpan ke Detail Transaksi
      await _supabase.from('stock_in_items').insert({
        'stock_in_id': newStockInId,
        'product_id': item.productId,
        'product_name': item.productName,
        'category': item.category,
        'quantity': item.quantity,
        'purchase_price': item.purchasePrice,
      });
    }
  }
  @override
  Future<void> updateStockIn(StockIn stockIn) async {
    await _supabase
        .from('stock_in')
        .update({
          'vendor_id': stockIn.vendorId,
          'vendor_name': stockIn.vendorName,
          'proof_image_path': stockIn.proofImagePath,
        })
        .eq('id', stockIn.id);

    await _supabase
        .from('stock_in_items')
        .delete()
        .eq('stock_in_id', stockIn.id);

    final itemsToInsert = stockIn.items.map((item) {
      return {
        'stock_in_id': stockIn.id,
        'product_id': item.productId,
        'product_name': item.productName,
        'category': item.category, // <-- Update kategori
        'quantity': item.quantity,
        'purchase_price': item.purchasePrice,
      };
    }).toList();

    await _supabase.from('stock_in_items').insert(itemsToInsert);

    for (var item in stockIn.items) {
      await _supabase.from('products').upsert({
        'id': item.productId,
        'name': item.productName,
        'category': item.category, // <-- Update kategori
        'unit': 'pcs',
        'purchase_price': item.purchasePrice,
        'selling_price': item.purchasePrice * 1.2,
        'current_stock': item.quantity,
        'minimum_stock': 5,
      }, onConflict: 'id');
    }
  }

  @override
  Future<void> deleteStockIn(String id) async {
    await _supabase.from('stock_in').delete().eq('id', id);
  }

  // ==========================================
  // 2. BARANG KELUAR (Stock Out)
  // ==========================================
  @override
  Future<List<StockOut>> getAllStockOut() async {
    final response = await _supabase
        .from('stock_out')
        .select('*, stock_out_items(*)')
        .order('date', ascending: false);

    return (response as List).map((data) {
      final itemsData = data['stock_out_items'] as List;
      return StockOut(
        id: data['id'],
        date: DateTime.parse(data['date']),
        paymentMethod: data['payment_method'],
        proofImagePath: data['proof_image_path'],
        items: itemsData.map((item) {
          return StockOutItem(
            productId: item['product_id'],
            productName: item['product_name'] ?? 'Tanpa Nama',
            quantity: item['quantity'],
            sellingPrice: (item['selling_price'] as num).toDouble(),
            purchasePrice: (item['purchase_price'] as num).toDouble(),
          );
        }).toList(),
      );
    }).toList();
  }

    @override
  Future<void> addStockOut(StockOut stockOut) async {
    // 1. Simpan Header Transaksi
    final headerRes = await _supabase
        .from('stock_out')
        .insert({
          'id': stockOut.id,
          'date': stockOut.date.toIso8601String(),
          'payment_method': stockOut.paymentMethod,
          'proof_image_path': stockOut.proofImagePath,
        })
        .select()
        .single();

    final newStockOutId = headerRes['id'];

    // 2. Simpan Detail Item
    final itemsToInsert = stockOut.items.map((item) {
      return {
        'stock_out_id': newStockOutId,
        'product_id': item.productId,
        'product_name': item.productName,
        'quantity': item.quantity,
        'selling_price': item.sellingPrice,
        'purchase_price': item.purchasePrice,
      };
    }).toList();

    await _supabase.from('stock_out_items').insert(itemsToInsert);

    // 3. KURANGI STOK DI MASTER PRODUK
    for (var item in stockOut.items) {
      // Ambil stok saat ini
      final productData = await _supabase
          .from('products')
          .select('current_stock')
          .eq('id', item.productId)
          .maybeSingle();

      if (productData != null) {
        int currentStock = (productData['current_stock'] as num?)?.toInt() ?? 0;
        int newStock = currentStock - item.quantity;

        // Jangan biarkan stok minus (jika ingin mencegah minus)
        if (newStock < 0) newStock = 0;

        // Update stok baru ke database
        await _supabase
            .from('products')
            .update({'current_stock': newStock}).eq('id', item.productId);
      }
    }
  }

  @override
  Future<void> deleteStockOut(String id) async {
    await _supabase.from('stock_out').delete().eq('id', id);
  }
}
