import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/opname_provider.dart';
import 'opname_form_page.dart';
import 'opname_detail_page.dart';

/// Halaman Daftar Opname — riwayat opname
class OpnameListPage extends StatelessWidget {
  const OpnameListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final opnameProvider = context.watch<OpnameProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan Opname'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: opnameProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : opnameProvider.opnameList.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: () => opnameProvider.loadAll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: opnameProvider.opnameList.length,
                    itemBuilder: (context, i) {
                      final op = opnameProvider.opnameList[i];
                      final isMinus = op.totalDifferenceValue < 0;
                      final isPlus = op.totalDifferenceValue > 0;

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.divider.withValues(alpha: 0.3),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OpnameDetailPage(opname: op),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.fact_check,
                                        color: AppColors.accent,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Opname ${CurrencyFormatter.formatTanggal(op.date)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${op.items.length} produk diperiksa',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color:
                                                  AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),

                                // Ringkasan selisih
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Total Selisih Unit',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          '${op.totalDifferenceUnit > 0 ? '+' : ''}${op.totalDifferenceUnit} unit',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isMinus
                                                ? AppColors.out
                                                : isPlus
                                                    ? AppColors.safe
                                                    : AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Total Selisih Nilai',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.formatRupiah(
                                            op.totalDifferenceValue,
                                          ),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isMinus
                                                ? AppColors.out
                                                : isPlus
                                                    ? AppColors.safe
                                                    : AppColors.textPrimary,
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
                    },
                  ),
                ),
      floatingActionButton: auth.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OpnameFormPage(),
                  ),
                );
              },
              backgroundColor: AppColors.accent,
              icon: const Icon(Icons.add),
              label: const Text('Opname Baru'),
            )
          : null,
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                size: 48,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada opname',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mulai opname untuk verifikasi stok fisik vs sistem',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}