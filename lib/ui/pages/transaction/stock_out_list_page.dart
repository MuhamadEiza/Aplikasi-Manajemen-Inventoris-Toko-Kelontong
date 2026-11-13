import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/stock_provider.dart';
import 'transaction_form_page.dart';
import 'transaction_detail_page.dart';
import '../../../providers/product_provider.dart';

// 1. UBAH MENJADI STATEFUL WIDGET
class StockOutListPage extends StatefulWidget {
  const StockOutListPage({super.key});

  @override
  State<StockOutListPage> createState() => _StockOutListPageState();
}

class _StockOutListPageState extends State<StockOutListPage> {
  
  // 2. TAMBAHKAN INITSTATE DI SINI
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();
    final list = provider.stockOutList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Barang Keluar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => provider.loadAll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final so = list[i];
                      return _buildTransactionCard(
                        context: context,
                        isStockIn: false,
                        date: so.date,
                        title: 'Penjualan',
                        // Menampilkan nama item
                        subtitle: so.items.map((e) => e.productName).join(', '),
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
                        onDelete: () {
                          _showDeleteDialog(context, provider, so.id);
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TransactionFormPage(isStockIn: false),
            ),
          );
          
          if (context.mounted) {
            await provider.loadAll();
            await context.read<ProductProvider>().loadProducts(); 
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Barang Keluar'),
      ),    
    );
  }

  Widget _buildEmptyState() {
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
              child: const Icon(Icons.remove_circle_outline, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada barang keluar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap tombol di bawah untuk catat penjualan',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, StockProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text('Yakin ingin menghapus transaksi barang keluar ini? Data yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteStockOut(id); 
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi berhasil dihapus'), backgroundColor: AppColors.safe),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.out)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET CARD
// ============================================================================
Widget _buildTransactionCard({
  required BuildContext context,
  required bool isStockIn,
  required DateTime date,
  required String title,
  String? subtitle,
  required int itemCount,
  required int totalQty,
  required double total,
  double? profit,
  required bool hasProof,
  required VoidCallback onTap,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // ============ TAMPILAN NAMA ITEM ============
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.formatTanggal(date),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: AppColors.accent),
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (onDelete != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: AppColors.out),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  )
                else if (hasProof)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.image, size: 16, color: AppColors.primary),
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
                    const Text('Total', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    Text(
                      CurrencyFormatter.formatRupiah(total),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                    ),
                  ],
                ),
                if (profit != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Untung', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        CurrencyFormatter.formatRupiah(profit),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.safe),
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
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    ),
  );
}