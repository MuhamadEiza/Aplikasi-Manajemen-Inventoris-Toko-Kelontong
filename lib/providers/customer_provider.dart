import 'package:flutter/material.dart';
import '../data/models/customer.dart';
import '../data/repositories/customer_repository.dart';

/// Provider untuk Customer / Pelanggan
class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _repository;

  List<Customer> _customers = [];
  bool _isLoading = false;

  CustomerProvider(this._repository);

  // Getter
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  /// Load semua customer
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    _customers = await _repository.getAllCustomers();

    _isLoading = false;
    notifyListeners();
  }

  /// Tambah customer
  Future<void> addCustomer(Customer customer) async {
    await _repository.addCustomer(customer);
    await loadAll();
  }

  /// Cari customer by ID
  Customer? getById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
