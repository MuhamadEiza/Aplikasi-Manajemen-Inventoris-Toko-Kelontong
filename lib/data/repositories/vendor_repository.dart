import '../models/vendor.dart';

abstract class VendorRepository {
  Future<List<Vendor>> getAllVendors();
  Future<void> addVendor(Vendor vendor);
}