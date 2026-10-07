import 'package:flutter/material.dart';
import '../data/models/stock_opname.dart';
import '../data/repositories/opname_repository.dart';

/// Provider untuk Stock Opname
class OpnameProvider extends ChangeNotifier {
  final OpnameRepository _repository;

  List<StockOpname> _opnameList = [];
  bool _isLoading = false;

  OpnameProvider(this._repository);

  // Getter
  List<StockOpname> get opnameList => _opnameList;
  bool get isLoading => _isLoading;

  /// Load semua opname
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    _opnameList = await _repository.getAllOpname();

    _isLoading = false;
    notifyListeners();
  }

  /// Tambah opname
  Future<void> addOpname(StockOpname opname) async {
    await _repository.addOpname(opname);
    await loadAll();
  }

  /// Cari opname by ID
  StockOpname? getById(String id) {
    try {
      return _opnameList.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}