import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vendor.dart';
import 'vendor_repository.dart';


/// IMPLEMENTASI Supabase untuk Vendor.
/// Menghubungkan aplikasi dengan tabel 'vendors' di database.
class SupabaseVendorRepository implements VendorRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Vendor>> getAllVendors() async {
    // Mengambil semua data dari tabel vendors
    final response = await _supabase.from('vendors').select().order('name');
    
    return (response as List).map((data) {
      return Vendor(
        id: data['id'],
        name: data['name'],
        address: data['address'],
        phone: data['phone'],
      );
    }).toList();
  }

  @override
  Future<void> addVendor(Vendor vendor) async {
    // Menyimpan vendor baru ke Supabase
    await _supabase.from('vendors').insert({
      'name': vendor.name,
      'address': vendor.address,
      'phone': vendor.phone,
    });
  }
  @override
  Future<void> updateVendor(Vendor vendor) async {
    await _supabase.from('vendors').update({
      'name': vendor.name,
      'address': vendor.address,
      'phone': vendor.phone,
    }).eq('id', vendor.id);
  }

  // TAMBAHKAN FUNGSI DELETE
  @override
  Future<void> deleteVendor(String id) async {
    await _supabase.from('vendors').delete().eq('id', id);
  }
}
