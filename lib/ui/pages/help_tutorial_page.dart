import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HelpTutorialPage extends StatelessWidget {
  const HelpTutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bantuan & Tutorial'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alur Penggunaan Aplikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ikuti langkah berurutan di bawah ini agar pencatatan inventaris toko kamu berjalan lancar dan akurat.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // LANGKAH 1
            _buildStepCard(
              step: '1',
              title: 'Daftarkan Vendor Terlebih Dahulu',
              description: 'Sebelum memasukkan barang, kamu harus mendaftarkan Vendor (Pemasok/Supplier) di menu Vendor. Vendor ini yang nantinya akan dicatat sebagai asal muasal barang kamu.',
              icon: Icons.store,
              color: Colors.blue,
            ),

            // LANGKAH 2
            _buildStepCard(
              step: '2',
              title: 'Input Barang Masuk',
              description: 'Setelah Vendor terdaftar, buka menu "Masuk" untuk mencatat barang yang baru datang. Di sini kamu memilih Vendor penyuplai, nama barang, jumlah, dan harga belinya. Stok barang akan otomatis bertambah.',
              icon: Icons.add_box,
              color: Colors.green,
            ),

            // LANGKAH 3
            _buildStepCard(
              step: '3',
              title: 'Catat Barang Keluar (Penjualan)',
              description: 'Menu "Keluar" digunakan untuk mencatat barang yang terjual atau keluar dari toko. Syarat utamanya: Barang harus sudah di-input di langkah ke-2. Sistem akan memotong stok secara otomatis.',
              icon: Icons.remove_circle,
              color: Colors.orange,
            ),

            // LANGKAH 4
            _buildStepCard(
              step: '4',
              title: 'Lakukan Opname Stok',
              description: 'Menu "Opname" berfungsi untuk mengecek dan menyesuaikan jumlah stok fisik di toko dengan catatan di aplikasi. Jika ada barang rusak atau hilang, kamu bisa menyesuaikan stoknya di sini.',
              icon: Icons.fact_check,
              color: Colors.purple,
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tips: Selalu cek Ringkasan Data di halaman Profil untuk melihat total Produk, Vendor, dan Transaksi yang sudah tercatat.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Langkah $step',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}