import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/stock_provider.dart';
import 'transaction_form_page.dart';
import 'transaction_detail_page.dart';

/// Halaman Transaksi — 2 Tab: Barang Masuk & Barang Keluar
class TransactionPage extends StatefulWidget {
  /// 0 = Barang Masuk, 1 = Barang Keluar
  final int initialTab;

  const TransactionPage({super.key, this.initialTab = 0});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Barang Masuk'),
            Tab(icon: Icon(Icons.remove_circle_outline), text: 'Barang Keluar'),
          ],
        ),
      ),
      body: stockProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStockInTab(stockProvider),
                _buildStockOutTab(stockProvider),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final isStockIn = _tabController.index == 0;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionFormPage(isStockIn: isStockIn),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(
          _tabController.index == 0 ? 'Barang Masuk' : 'Barang Keluar',
        ),
      ),
    );
  }

  Widget _buildStockInTab(StockProvider provider) {
    final list = provider.stockInList;
    if (list.isEmpty) {
      return _emptyState(
        icon: Icons.add_circle_outline,
        title: 'Belum ada barang masuk',
        subtitle: 'Tap tombol di bawah untuk catat barang masuk dari vendor',
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadAll(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final si = list[i];
          return _transactionCard(
            isStockIn: true,
            date: si.date,
            title: si.vendorName ?? 'Vendor tidak diketahui',
            itemCount: si.totalProducts,
            totalQty: si.totalQuantity,
            total: si.total,
            hasProof: si.proofImagePath != null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionDetailPage(stockIn: si),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStockOutTab(StockProvider provider) {
    final list = provider.stockOutList;
    if (list.isEmpty) {
      return _emptyState(
        icon: Icons.remove_circle_outline,
        title: 'Belum ada barang keluar',
        subtitle: 'Tap tombol di bawah untuk catat penjualan',
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadAll(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final so = list[i];
          return _transactionCard(
            isStockIn: false,
            date: so.date,
            title: 'Penjualan',
            itemCount: so.totalProducts,
            totalQty: so.totalQuantity,
            total: so.total,
            profit: so.totalProfit,
            hasProof: so.proofImagePath != null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionDetailPage(stockOut: so),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _transactionCard({
    required bool isStockIn,
    required DateTime date,
    required String title,
    required int itemCount,
    required int totalQty,
    required double total,
    double? profit,
    required bool hasProof,
    required VoidCallback onTap,
  }) {
    final color = isStockIn ? AppColors.safe : AppColors.low;
    final icon = isStockIn ? Icons.add_circle : Icons.remove_circle;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.formatTanggal(date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasProof)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.image,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  _infoChip(Icons.inventory_2, '$itemCount item'),
                  const SizedBox(width: 8),
                  _infoChip(Icons.numbers, '$totalQty unit'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatRupiah(total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (profit != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Untung',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatRupiah(profit),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.safe,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}