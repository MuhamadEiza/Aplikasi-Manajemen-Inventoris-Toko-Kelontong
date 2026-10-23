import '../models/vendor.dart';
import '../repositories/vendor_repository.dart';

/// Implementasi data DUMMY untuk Vendor / Agen.
/// Tujuan: Mensimulasikan data master vendor (pemasok) sebelum database asli terhubung di UAS.
class DummyVendorRepository implements VendorRepository {
  
  // Data hardcode (palsu) yang meniru isi tabel 'vendors'.
  // Berisi 3 contoh vendor beserta kategori barang yang mereka suplai.
  final List<Vendor> _vendors = [
    Vendor(id: 'v001', name: 'Agen Sembako Jaya',
      address: 'Jl. Pasar Baru No. 12, Bandung', phone: '0812-3456-7890',
      suppliedCategories: ['Sembako', 'Makanan Instan']),
    Vendor(id: 'v002', name: 'Agen Minuman Segar',
      address: 'Jl. Merdeka No. 45, Bandung', phone: '0813-9876-5432',
      suppliedCategories: ['Minuman']),
    Vendor(id: 'v003', name: 'CV Snack Nusantara',
      address: 'Jl. Industri No. 8, Cimahi', phone: '0821-1111-2222',
      suppliedCategories: ['Snack', 'Makanan Instan']),
  ];

  @override
  Future<List<Vendor>> getAllVendors() async {
    // Simulasi jeda loading (300ms) agar UI transisi terlihat natural.
    await Future.delayed(const Duration(milliseconds: 300));
    
    // List.from() mengembalikan salinan (copy) agar UI tidak memodifikasi data asli secara langsung.
    return List.from(_vendors);
  }

  @override
  Future<void> addVendor(Vendor vendor) async { 
    // Menambahkan objek vendor baru ke dalam list.
    _vendors.add(vendor); 
  }
}