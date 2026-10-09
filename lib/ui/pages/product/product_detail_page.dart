import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/product.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/status_badge.dart';
import 'product_form_page.dart';

/// Halaman Detail Produk
class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Edit hanya untuk Admin
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductFormPage(product: product),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============ HEADER ============
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      product.name[0],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StatusBadge(status: product.stockStatus),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ============ INFO HARGA ============
            _sectionTitle('Informasi Harga'),
            const SizedBox(height: 8),
            _infoCard([
              _infoRow('Harga Beli',
                  CurrencyFormatter.formatRupiah(product.purchasePrice)),
              _infoRow('Harga Jual',
                  CurrencyFormatter.formatRupiah(product.sellingPrice),
                  valueColor: AppColors.primary, isBold: true),
              _infoRow('Margin (Rp)',
                  CurrencyFormatter.formatRupiah(product.marginRupiah),
                  valueColor: AppColors.safe),
              _infoRow('Margin (%)',
                  CurrencyFormatter.formatPersen(product.marginPercent),
                  valueColor: AppColors.safe),
            ]),
            const SizedBox(height: 16),

            // ============ INFO STOK ============
            _sectionTitle('Informasi Stok'),
            const SizedBox(height: 8),
            _infoCard([
              _infoRow('Stok Saat Ini', '${product.currentStock} ${product.unit}',
                  isBold: true),
              _infoRow('Stok Minimum', '${product.minimumStock} ${product.unit}'),
              _infoRow('Satuan', product.unit),
            ]),
            const SizedBox(height: 16),

            // ============ TOMBOL AKSI ============
            if (auth.isAdmin) ...[
              OutlinedButton.icon(
                onPressed: () => _showDeleteDialog(context),
                icon: const Icon(Icons.delete, color: AppColors.out),
                label: const Text(
                  'Hapus Produk',
                  style: TextStyle(color: AppColors.out),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.out),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 0),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              )),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await context
                  .read<ProductProvider>()
                  .deleteProduct(product.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.out)),
          ),
        ],
      ),
    );
  }
}