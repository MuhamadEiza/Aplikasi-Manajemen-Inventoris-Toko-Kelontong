import '../models/stock_in.dart';
import '../models/stock_out.dart';

/// INTERFACE (Kontrak) untuk akses data Transaksi Stok (Masuk & Keluar).
/// Tujuan: Memisahkan logika UI dari sumber data.
/// Saat aplikasi terhubung ke backend (UAS), kita cukup mengganti implementasi
/// dari Dummy menjadi API, tanpa mengubah halaman UI transaksi.
abstract class StockRepository {
  // === Kontrak Barang Masuk (Stock In) ===

  /// Kontrak untuk mengambil riwayat semua barang masuk.
  Future<List<StockIn>> getAllStockIn();

  /// Kontrak untuk menyimpan data barang masuk baru.
  Future<void> addStockIn(StockIn stockIn);

  /// Kontrak untuk mengubah data barang masuk (Edit).
  Future<void> updateStockIn(StockIn stockIn);

  /// Kontrak untuk menghapus data barang masuk.
  Future<void> deleteStockIn(String id);

  // === Kontrak Barang Keluar (Stock Out) ===

  /// Kontrak untuk mengambil riwayat semua barang keluar.
  Future<List<StockOut>> getAllStockOut();

  /// Kontrak untuk menyimpan data barang keluar baru.
  Future<void> addStockOut(StockOut stockOut);

  /// Kontrak untuk menghapus data barang keluar.
  Future<void> deleteStockOut(String id);
}