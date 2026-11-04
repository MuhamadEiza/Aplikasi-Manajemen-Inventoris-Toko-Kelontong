import 'package:flutter/material.dart';
import '../data/models/vendor.dart';
import '../data/repositories/vendor_repository.dart';

class VendorProvider extends ChangeNotifier {
  final VendorRepository _repository;
  List<Vendor> _vendors = [];
  bool _isLoading = false;

  VendorProvider(this._repository);

  List<Vendor> get vendors => _vendors;
  bool get isLoading => _isLoading;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _vendors = await _repository.getAllVendors();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addVendor(Vendor vendor) async {
    await _repository.addVendor(vendor);
    await loadAll();
  }

  // TAMBAHKAN FUNGSI UPDATE
  Future<void> updateVendor(Vendor vendor) async {
    await _repository.updateVendor(vendor);
    await loadAll();
  }

  // TAMBAHKAN FUNGSI DELETE
  Future<void> deleteVendor(String id) async {
    await _repository.deleteVendor(id);
    await loadAll();
  }

  Vendor? getById(String id) {
    try {
      return _vendors.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Vendor> search(String query) {
    if (query.isEmpty) return _vendors;
    return _vendors
        .where((v) => v.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}