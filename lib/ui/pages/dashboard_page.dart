import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/stock_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/bottom_nav.dart';

/// Dashboard — halaman utama setelah login
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Kalau belum login, redirect ke Login (safety)
    if (!auth.isLoggedIn) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Tampilkan halaman sesuai index bottom nav
    return Scaffold(
      body: _buildBody(_currentIndex, auth.role ?? 'Admin'),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex > (_maxIndex(auth.role ?? 'Admin')) 
            ? 0 
            : _currentIndex,
        role: auth.role ?? 'Admin',
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  int _maxIndex(String role) => role == 'Admin' ? 4 : 3;

  Widget _buildBody(int index, String role) {
    switch (index) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildPlaceholder('Produk', Icons.inventory_2);
      case 2:
        return _buildPlaceholder('Transaksi', Icons.swap_horiz);
      case 3:
        if (role == 'Admin') {
          return _buildPlaceholder('Opname', Icons.fact_check);
        }
        return _buildPlaceholder('Profil', Icons.person);
      case 4:
        return _buildPlaceholder('Profil', Icons.person);
      default:
        return _buildHomeTab();
    }
  }

  // ==================== TAB HOME ====================
  Widget _buildHomeTab() {
    final productProvider = context.watch<ProductProvider>();
    final stockProvider = context.watch<StockProvider>();
    final auth = context.watch<AuthProvider>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await productProvider.loadProducts();
          await stockProvider.loadAll();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============ HEADER ============
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Halo,',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        auth.name ?? 'Pengguna',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Role: ${auth.role}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (auth.name ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ============ 4 KARTU RINGKASAN ============
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  SummaryCard(
                    icon: Icons.inventory_2,
                    title: 'Total Barang',
                    value: '${productProvider.products.length} jenis',
                    color: AppColors.primary,
                  ),
                  SummaryCard(
                    icon: Icons.warning_amber,
                    title: 'Stok Menipis',
                    value: '${productProvider.lowStockCount} barang',
                    color: AppColors.low,
                  ),
                  SummaryCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Nilai Inventaris',
                    value: CurrencyFormatter.formatRupiah(
                      productProvider.totalInventoryValue,
                    ),
                    color: AppColors.accent,
                  ),
                  SummaryCard(
                    icon: Icons.trending_up,
                    title: 'Untung Hari Ini',
                    value: CurrencyFormatter.formatRupiah(
                      stockProvider.todayProfit,
                    ),
                    color: AppColors.safe,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ============ TOMBOL AKSI CEPAT ============
              const Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _quickAction(
                      icon: Icons.add_circle,
                      label: 'Barang\nMasuk',
                      color: AppColors.safe,
                      onTap: () => _showComingSoon('Barang Masuk'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _quickAction(
                      icon: Icons.remove_circle,
                      label: 'Barang\nKeluar',
                      color: AppColors.low,
                      onTap: () => _showComingSoon('Barang Keluar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _quickAction(
                      icon: Icons.fact_check,
                      label: 'Opname',
                      color: AppColors.accent,
                      onTap: () => _showComingSoon('Opname'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ============ TOP 3 TERLARIS ============
              const Text(
                'Top Barang Terlaris',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _topItem(1, 'Indomie Goreng', '1.245 pcs'),
                      const Divider(height: 16),
                      _topItem(2, 'Aqua 600ml', '1.180 botol'),
                      const Divider(height: 16),
                      _topItem(3, 'Beras Premium', '980 kg'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ============ PRODUK TERBARU ============
              const Text(
                'Produk Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (productProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ...productProvider.products.take(3).map((p) {
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          p.name[0],
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${CurrencyFormatter.formatRupiah(p.sellingPrice)} • Stok: ${p.currentStock}',
                      ),
                      trailing: Icon(
                        Icons.circle,
                        size: 12,
                        color: _statusColor(p.stockStatus),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'SAFE':
        return AppColors.safe;
      case 'MODERATE':
        return AppColors.moderate;
      case 'LOW':
        return AppColors.low;
      case 'OUT':
        return AppColors.out;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topItem(int rank, String name, String qty) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: rank == 1
                ? AppColors.accent
                : rank == 2
                    ? AppColors.textSecondary
                    : AppColors.low,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          qty,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Halaman $title',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Akan dibuat di step berikutnya',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — akan dibuat di step berikutnya'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}