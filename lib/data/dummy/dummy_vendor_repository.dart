import '../models/vendor.dart';
import '../repositories/vendor_repository.dart';

class DummyVendorRepository implements VendorRepository {
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
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_vendors);
  }

  @override
  Future<void> addVendor(Vendor vendor) async { _vendors.add(vendor); }
}