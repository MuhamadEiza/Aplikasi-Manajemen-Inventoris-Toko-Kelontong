import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import 'product_repository.dart';

class SupabaseProductRepository implements ProductRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      // Mengambil semua data dari tabel 'products'
      final response = await _supabase
          .from('products')
          .select()
          .order('name', ascending: true);

      // Jika response kosong, return list kosong
      if (response == null) return [];

      return (response as List).map((data) {
        return Product(
          id: data['id']?.toString() ?? '',
          name: data['name']?.toString() ?? 'Tanpa Nama',
          category: data['category']?.toString() ?? 'Lainnya',
          unit: data['unit']?.toString() ?? 'pcs',
          purchasePrice: (data['purchase_price'] as num?)?.toDouble() ?? 0.0,
          sellingPrice: (data['selling_price'] as num?)?.toDouble() ?? 0.0,
          currentStock: (data['current_stock'] as num?)?.toInt() ?? 0,
          minimumStock: (data['minimum_stock'] as num?)?.toInt() ?? 0,
          barcode: data['barcode']?.toString(),
        );
      }).toList();
    } catch (e) {
      // Jika terjadi error (misal RLS memblokir), print error ke console
      print('ERROR GET PRODUCTS: $e');
      return [];
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _supabase.from('products').select().eq('id', id).maybeSingle();
      if (response == null) return null;

      return Product(
        id: response['id']?.toString() ?? '',
        name: response['name']?.toString() ?? 'Tanpa Nama',
        category: response['category']?.toString() ?? 'Lainnya',
        unit: response['unit']?.toString() ?? 'pcs',
        purchasePrice: (response['purchase_price'] as num?)?.toDouble() ?? 0.0,
        sellingPrice: (response['selling_price'] as num?)?.toDouble() ?? 0.0,
        currentStock: (response['current_stock'] as num?)?.toInt() ?? 0,
        minimumStock: (response['minimum_stock'] as num?)?.toInt() ?? 0,
        barcode: response['barcode']?.toString(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addProduct(Product product) async {
    await _supabase.from('products').insert({
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'unit': product.unit,
      'purchase_price': product.purchasePrice,
      'selling_price': product.sellingPrice,
      'current_stock': product.currentStock,
      'minimum_stock': product.minimumStock,
      'barcode': product.barcode,
    });
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _supabase.from('products').update({
      'name': product.name,
      'category': product.category,
      'purchase_price': product.purchasePrice,
      'selling_price': product.sellingPrice,
      'current_stock': product.currentStock,
      'minimum_stock': product.minimumStock,
      'barcode': product.barcode,
    }).eq('id', product.id);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _supabase.from('products').delete().eq('id', id);
  }
}