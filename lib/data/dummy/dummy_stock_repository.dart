import '../models/stock_in.dart';
import '../models/stock_out.dart';
import '../repositories/stock_repository.dart';

/// Implementasi data DUMMY untuk transaksi stok (Masuk & Keluar).
/// Tujuan: Mensimulasikan database transaksi agar UI bisa diuji sebelum backend terhubung di UAS.
class DummyStockRepository implements StockRepository {
  
  // ==========================================
  // DATA DUMMY: BARANG MASUK (Stock In)
  // ==========================================
  // Menyimpan riwayat barang masuk dari vendor beserta bukti notanya.
  final List<StockIn> _stockIn = [
    StockIn(
      id: 'si001', date: DateTime(2026, 6, 18),
      vendorId: 'v001', vendorName: 'Agen Sembako Jaya',
      items: [
        StockInItem(productId: 'p001', productName: 'Indomie Goreng',
          quantity: 100, purchasePrice: 2500),
      ],
      proofImagePath: 'dummy/nota_001.jpg',
    ),
  ];

  // ==========================================
  // DATA DUMMY: BARANG KELUAR (Stock Out)
  // ==========================================
  // Menyimpan riwayat penjualan ke pelanggan beserta bukti struk.
  final List<StockOut> _stockOut = [
    StockOut(
      id: 'so001', date: DateTime(2026, 6, 18),
      customerId: 'c001', customerName: 'Bu Sari',
      items: [
        StockOutItem(productId: 'p001', productName: 'Indomie Goreng',
          quantity: 10, sellingPrice: 3000, purchasePrice: 2500),
      ],
      proofImagePath: 'dummy/struk_001.jpg',
    ),
  ];

  // === METHOD UNTUK BARANG MASUK ===

  @override
  Future<List<StockIn>> getAllStockIn() async {
    // Simulasi loading (300ms) dan mengembalikan salinan list (copy) 
    // agar data asli di dalam _stockIn tidak rusak.
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_stockIn);
  }

  @override
  Future<void> addStockIn(StockIn stockIn) async {
    // Menambahkan data barang masuk baru ke urutan paling atas (index 0)
    // agar transaksi terbaru langsung terlihat di halaman UI.
    _stockIn.insert(0, stockIn);
  }

  // === METHOD UNTUK BARANG KELUAR ===

  @override
  Future<List<StockOut>> getAllStockOut() async {
    // Sama seperti Stock In, beri jeda simulasi lalu kembalikan salinan list.
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_stockOut);
  }

  @override
  Future<void> addStockOut(StockOut stockOut) async {
    // Menambahkan data penjualan baru ke urutan paling atas (index 0).
    _stockOut.insert(0, stockOut);
  }
}