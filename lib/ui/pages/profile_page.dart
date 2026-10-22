import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/vendor_provider.dart';
import '../widgets/menu_tile.dart';
import 'login_page.dart';

/// Halaman Profil — info akun + menu + logout
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final vendorProvider = context.watch<VendorProvider>();
    final stockProvider = context.watch<StockProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ============ CARD PROFIL USER ============
            _profileCard(auth),

            const SizedBox(height: 16),

            // ============ CARD INFO TOKO ============
            _storeCard(),

            const SizedBox(height: 16),

            // ============ STATISTIK SINGKAT ============
            _sectionTitle('Ringkasan Data'),
            const SizedBox(height: 8),
            _statsCard(
              totalProducts: productProvider.products.length,
              totalVendors: vendorProvider.vendors.length,
              totalTransactions:
                  stockProvider.stockInList.length + stockProvider.stockOutList.length,
            ),

            const SizedBox(height: 16),

            // ============ MENU PENGATURAN ============
            _sectionTitle('Pengaturan'),
            const SizedBox(height: 8),

            MenuTile(
              icon: Icons.person_outline,
              title: 'Edit Profil',
              subtitle: 'Nama, email, nomor HP',
              onTap: () => _showComingSoon(context, 'Edit Profil'),
            ),
            MenuTile(
              icon: Icons.store_outlined,
              title: 'Informasi Toko',
              subtitle: 'Nama, alamat, jam operasional',
              onTap: () => _showComingSoon(context, 'Informasi Toko'),
            ),

            // Menu khusus Admin
            if (auth.isAdmin)
              MenuTile(
                icon: Icons.people_outline,
                title: 'Kelola Karyawan',
                subtitle: 'Tambah & atur akses staff',
                onTap: () => _showComingSoon(context, 'Kelola Karyawan'),
              ),

            MenuTile(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi',
              subtitle: 'Peringatan stok menipis',
              onTap: () => _showComingSoon(context, 'Notifikasi'),
            ),

            const SizedBox(height: 16),

            // ============ MENU BANTUAN ============
            _sectionTitle('Bantuan & Info'),
            const SizedBox(height: 8),

            MenuTile(
              icon: Icons.help_outline,
              title: 'Bantuan & Tutorial',
              subtitle: 'Panduan penggunaan aplikasi',
              onTap: () => _showComingSoon(context, 'Bantuan'),
            ),
            MenuTile(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              subtitle: 'WarungStock v1.0.0 (UTS Build)',
              onTap: () => _showAboutDialog(context),
            ),

            const SizedBox(height: 24),

            // ============ TOMBOL LOGOUT ============
            _logoutButton(context, auth),

            const SizedBox(height: 24),

            // ============ FOOTER ============
            Center(
              child: Text(
                'WarungStock v1.0.0 (UTS Build)',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==================== PROFILE CARD ====================
  Widget _profileCard(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Text(
              (auth.name ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.name ?? 'Pengguna',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.email ?? '-',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Role: ${auth.role}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STORE CARD ====================
  Widget _storeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toko Berkah Sejahtera',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Toko Kelontong • Bandung',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Jl. Pasar Baru No. 45, Bandung',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== STATS CARD ====================
  Widget _statsCard({
    required int totalProducts,
    required int totalVendors,
    required int totalTransactions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              Icons.inventory_2,
              '$totalProducts',
              'Produk',
              AppColors.primary,
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.divider.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _statItem(
              Icons.local_shipping,
              '$totalVendors',
              'Vendor',
              AppColors.accent,
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.divider.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _statItem(
              Icons.swap_horiz,
              '$totalTransactions',
              'Transaksi',
              AppColors.safe,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ==================== LOGOUT BUTTON ====================
  Widget _logoutButton(BuildContext context, AuthProvider auth) {
    return OutlinedButton.icon(
      onPressed: () => _showLogoutDialog(context, auth),
      icon: const Icon(Icons.logout, color: AppColors.out),
      label: const Text(
        'KELUAR DARI AKUN',
        style: TextStyle(
          color: AppColors.out,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.out, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.out),
            SizedBox(width: 8),
            Text('Keluar Akun?'),
          ],
        ),
        content: const Text(
          'Anda yakin ingin keluar dari akun ini? Anda perlu login kembali untuk mengakses aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.out,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  // ==================== ABOUT DIALOG ====================
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text('Tentang Aplikasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.storefront,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'WarungStock',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'v1.0.0 (UTS Build)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aplikasi Manajemen Inventaris Toko Kelontong yang membantu pemilik toko mencatat stok masuk/keluar dari vendor, mengelola harga beli-jual, dan melakukan opname.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dibuat untuk tugas kuliah UI — semester ini.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER ====================
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — akan dibuat di step berikutnya'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}