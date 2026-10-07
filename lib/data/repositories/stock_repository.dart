import '../models/stock_in.dart';
import '../models/stock_out.dart';

abstract class StockRepository {
  Future<List<StockIn>> getAllStockIn();
  Future<void> addStockIn(StockIn stockIn);
  Future<List<StockOut>> getAllStockOut();
  Future<void> addStockOut(StockOut stockOut);
}