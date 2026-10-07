import '../models/stock_opname.dart';

abstract class OpnameRepository {
  Future<List<StockOpname>> getAllOpname();
  Future<void> addOpname(StockOpname opname);
}