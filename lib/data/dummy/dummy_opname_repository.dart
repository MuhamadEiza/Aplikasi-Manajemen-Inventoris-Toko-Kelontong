import '../models/stock_opname.dart';
import '../repositories/opname_repository.dart';

/// Implementasi data DUMMY untuk fitur Opname.
/// Tujuan: Mensimulasikan data laporan opname (stok fisik vs sistem) 
/// sebelum database asli (backend) terhubung di UAS.
class DummyOpnameRepository implements OpnameRepository {
  
  // Data hardcode (palsu) yang meniru isi tabel database.
  // Terdapat 1 contoh riwayat opname yang sudah selesai dilakukan.
  final List<StockOpname> _opname = [
    StockOpname(
      id: 'op001', date: DateTime(2026, 6, 18),
      items: [
        StockOpnameItem(productId: 'p001', productName: 'Indomie Goreng',
          systemStock: 110, physicalStock: 108, note: 'Barang rusak',
          purchasePrice: 2500),
        StockOpnameItem(productId: 'p003', productName: 'Beras Premium',
          systemStock: 8, physicalStock: 7, note: 'Tumpah',
          purchasePrice: 12000),
      ],
    ),
  ];

  @override
  Future<List<StockOpname>> getAllOpname() async {
    // Simulasi loading network (300ms) agar UI terlihat lebih realistis 
    // saat memuat data.
    await Future.delayed(const Duration(milliseconds: 300));
    
    // List.from() digunakan agar UI menerima salinan list (copy), 
    // bukan referensi langsung ke variabel _opname.
    return List.from(_opname);
  }

  @override
  Future<void> addOpname(StockOpname opname) async {
    // Menambahkan data opname baru ke urutan paling atas (index 0)
    // agar riwayat terbaru selalu muncul pertama di list UI.
    _opname.insert(0, opname);
  }
}