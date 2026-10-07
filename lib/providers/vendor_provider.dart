import 'package:flutter/material.dart';
import '../data/models/vendor.dart';
import '../data/repositories/vendor_repository.dart';

/// Provider untuk Vendor / Agen
class VendorProvider extends ChangeNotifier {
  final VendorRepository _repository;

  List<Vendor> _vendors = [];
  bool _isLoading = false;

  VendorProvider(this._repository);

  // Getter
  List<Vendor> get vendors => _vendors;
  bool get isLoading => _isLoading;

  /// Load semua vendor
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    _vendors = await _repository.getAllVendors();

    _isLoading = false;
    notifyListeners();
  }

  /// Tambah vendor
  Future<void> addVendor(Vendor vendor) async {
    await _repository.addVendor(vendor);
    await loadAll();
  }

  /// Cari vendor by ID
  Vendor? getById(String id) {
    try {
      return _vendors.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Search vendor by nama
  List<Vendor> search(String query) {
    if (query.isEmpty) return _vendors;
    return _vendors
        .where((v) => v.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}