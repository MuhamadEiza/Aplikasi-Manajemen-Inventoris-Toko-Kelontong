import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';

/// Halaman Daftar Produk
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Makanan Instan',
    'Minuman',
    'Snack',
    'Sembako',
    'Kebersihan',
    'Perawatan Tubuh',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final auth = context.watch<AuthProvider>();

    // Filter produk
    var filtered = productProvider.filterByCategory(_selectedCategory);
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nama barang...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Filter kategori
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isActive = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? Colors.white : AppColors.textPrimary,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isActive,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = cat),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        showCheckmark: false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // List produk
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? _emptyState()
                    : RefreshIndicator(
                        onRefresh: () => productProvider.loadProducts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final p = filtered[i];
                            return ProductCard(
                              product: p,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailPage(product: p),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      // FAB hanya untuk Admin
      floatingActionButton: auth.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductFormPage(),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada produk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba ubah filter atau tambah produk baru',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}