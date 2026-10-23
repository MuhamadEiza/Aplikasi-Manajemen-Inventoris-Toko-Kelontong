import '../models/stock_opname.dart';

/// INTERFACE (Kontrak) untuk akses data Opname.
/// Tujuan: Menjadi "jembatan" agar UI tidak peduli data diambil dari Dummy (UTS) 
/// atau dari API/Database asli (UAS).
/// Saat UAS, kita tinggal membuat class ApiOpnameRepository yang meng-implement 
/// interface ini, tanpa perlu mengubah kode UI sama sekali.
abstract class OpnameRepository {
  
  /// Kontrak untuk mengambil semua riwayat opname.
  Future<List<StockOpname>> getAllOpname();
  
  /// Kontrak untuk menyimpan data opname baru.
  Future<void> addOpname(StockOpname opname);
}