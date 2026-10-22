import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/stock_in.dart';
import '../../../data/models/stock_out.dart';

/// Detail Transaksi (Stock In / Stock Out) + Bukti
class TransactionDetailPage extends StatelessWidget {
  final StockIn? stockIn;
  final StockOut? stockOut;

  const TransactionDetailPage({
    super.key,
    this.stockIn,
    this.stockOut,
  }) : assert(stockIn != null || stockOut != null);

  bool get _isStockIn => stockIn != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isStockIn ? 'Detail Barang Masuk' : 'Detail Barang Keluar',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
                color: _isStockIn ? AppColors.safe : AppColors.low,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    _isStockIn ? Icons.add_circle : Icons.remove_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isStockIn ? 'Barang Masuk' : 'Barang Keluar',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isStockIn
                              ? (stockIn!.vendorName ?? 'Vendor')
                              : 'Penjualan',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatTanggal(
                            _isStockIn ? stockIn!.date : stockOut!.date,
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ============ DETAIL ITEM ============
            _sectionTitle('Detail Item'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  if (_isStockIn)
                    ...stockIn!.items.asMap().entries.map(
                          (e) => _itemRow(
                            no: e.key + 1,
                            name: e.value.productName,
                            qty: e.value.quantity,
                            price: e.value.purchasePrice,
                            subtotal: e.value.subtotal,
                          ),
                        )
                  else
                    ...stockOut!.items.asMap().entries.map(
                          (e) => _itemRow(
                            no: e.key + 1,
                            name: e.value.productName,
                            qty: e.value.quantity,
                            price: e.value.sellingPrice,
                            subtotal: e.value.subtotal,
                            profit: e.value.profit,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ============ RINGKASAN ============
            _sectionTitle('Ringkasan'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  _summaryRow(
                    'Total',
                    CurrencyFormatter.formatRupiah(
                      _isStockIn ? stockIn!.total : stockOut!.total,
                    ),
                    isBold: true,
                    color: AppColors.primary,
                  ),
                  if (!_isStockIn) ...[
                    const SizedBox(height: 8),
                    _summaryRow(
                      'Total Untung',
                      CurrencyFormatter.formatRupiah(stockOut!.totalProfit),
                      isBold: true,
                      color: AppColors.safe,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _summaryRow(
                    'Jumlah Item',
                    '${_isStockIn ? stockIn!.totalProducts : stockOut!.totalProducts} item',
                  ),
                  const SizedBox(height: 8),
                  _summaryRow(
                    'Total Unit',
                    '${_isStockIn ? stockIn!.totalQuantity : stockOut!.totalQuantity} unit',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ============ BUKTI ============
            _sectionTitle('Bukti Transaksi'),
            const SizedBox(height: 8),
            _proofSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _itemRow({
    required int no,
    required String name,
    required int qty,
    required double price,
    required double subtotal,
    double? profit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '$no',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.formatRupiah(subtotal),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Row(
              children: [
                Text(
                  '$qty × ${CurrencyFormatter.formatRupiah(price)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (profit != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• Untung ${CurrencyFormatter.formatRupiah(profit)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.safe,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _proofSection() {
    final proofPath = _isStockIn
        ? stockIn!.proofImagePath
        : stockOut!.proofImagePath;

    if (proofPath == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.image_not_supported,
                color: AppColors.textSecondary, size: 20),
            SizedBox(width: 10),
            Text(
              'Tidak ada bukti terlampir',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.safe.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.safe.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.3),
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 48, color: AppColors.primary),
                  SizedBox(height: 8),
                  Text(
                    'Foto Bukti (Simulasi)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.safe, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  proofPath,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ],
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
}