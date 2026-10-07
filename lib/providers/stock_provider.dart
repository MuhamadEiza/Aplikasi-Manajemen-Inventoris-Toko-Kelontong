import 'package:flutter/material.dart';
import '../data/models/stock_in.dart';
import '../data/models/stock_out.dart';
import '../data/repositories/stock_repository.dart';

/// Provider untuk Stock In & Stock Out
class StockProvider extends ChangeNotifier {
  final StockRepository _repository;

  List<StockIn> _stockInList = [];
  List<StockOut> _stockOutList = [];
  bool _isLoading = false;

  StockProvider(this._repository);

  // Getter
  List<StockIn> get stockInList => _stockInList;
  List<StockOut> get stockOutList => _stockOutList;
  bool get isLoading => _isLoading;

  /// Total untung hari ini
  double get todayProfit {
    final today = DateTime.now();
    return _stockOutList
        .where((s) =>
            s.date.year == today.year &&
            s.date.month == today.month &&
            s.date.day == today.day)
        .fold(0, (sum, s) => sum + s.totalProfit);
  }

  /// Total penjualan hari ini
  double get todaySales {
    final today = DateTime.now();
    return _stockOutList
        .where((s) =>
            s.date.year == today.year &&
            s.date.month == today.month &&
            s.date.day == today.day)
        .fold(0, (sum, s) => sum + s.total);
  }

  /// Total untung bulan ini
  double get monthlyProfit {
    final now = DateTime.now();
    return _stockOutList
        .where((s) => s.date.year == now.year && s.date.month == now.month)
        .fold(0, (sum, s) => sum + s.totalProfit);
  }

  /// Load semua stock in & out
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    _stockInList = await _repository.getAllStockIn();
    _stockOutList = await _repository.getAllStockOut();

    _isLoading = false;
    notifyListeners();
  }

  /// Tambah stock in
  Future<void> addStockIn(StockIn stockIn) async {
    await _repository.addStockIn(stockIn);
    await loadAll();
  }

  /// Tambah stock out
  Future<void> addStockOut(StockOut stockOut) async {
    await _repository.addStockOut(stockOut);
    await loadAll();
  }
}