import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';

/// Halaman Daftar Produk — dengan search by nama/barcode
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  bool _isBarcodeMode = false; // deteksi apakah query numeric

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

  /// Cek apakah query terlihat seperti barcode (hanya angka, minimal 8 digit)
  bool _looksLikeBarcode(String query) {
    if (query.length < 8) return false;
    return RegExp(r'^\d+$').hasMatch(query);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final auth = context.watch<AuthProvider>();

    // Filter kategori dulu
    var filtered = productProvider.filterByCategory(_selectedCategory);

    // Filter search (nama ATAU barcode)
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      filtered = filtered.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query.toLowerCase());
        final barcodeMatch = p.barcode?.contains(query) ?? false;
        return nameMatch || barcodeMatch;
      }).toList();
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
          // ============ SEARCH & FILTER ============
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _isBarcodeMode = _looksLikeBarcode(value);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau barcode...',
                    prefixIcon: Icon(
                      _isBarcodeMode ? Icons.qr_code : Icons.search,
                      color: _isBarcodeMode
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _isBarcodeMode = false;
                              });
                            },
                          )
                        : null,
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

                // Info banner kalau mode barcode
                if (_isBarcodeMode) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.qr_code,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Mencari dengan kode barcode...',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Filter kategori (hanya tampil kalau bukan mode barcode)
                if (!_isBarcodeMode)
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        final isActive = cat == _selectedCategory;
                        return ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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

          // ============ INFO HASIL ============
          if (_searchController.text.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              color: AppColors.background,
              child: Text(
                '${filtered.length} produk ditemukan',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

          // ============ LIST PRODUK ============
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
    final isSearching = _searchController.text.isNotEmpty;

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
              child: Icon(
                isSearching
                    ? (_isBarcodeMode ? Icons.qr_code_2 : Icons.search_off)
                    : Icons.inventory_2_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'Produk tidak ditemukan' : 'Tidak ada produk',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? (_isBarcodeMode
                      ? 'Barcode "${_searchController.text}" tidak terdaftar'
                      : 'Coba kata kunci lain atau ubah filter kategori')
                  : 'Coba ubah filter atau tambah produk baru',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}