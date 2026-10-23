import '../models/vendor.dart';

/// INTERFACE (Kontrak) untuk akses data Vendor / Agen.
/// Tujuan: Menerapkan Repository Pattern. UI hanya berkomunikasi dengan kontrak ini.
/// Saat migrasi ke backend asli (UAS), kita cukup membuat implementasi baru 
/// (misal: ApiVendorRepository) tanpa perlu menyentuh kode UI.
abstract class VendorRepository {
  
  /// Kontrak untuk mengambil seluruh daftar vendor.
  Future<List<Vendor>> getAllVendors();
  
  /// Kontrak untuk menambahkan data vendor baru.
  Future<void> addVendor(Vendor vendor);
}