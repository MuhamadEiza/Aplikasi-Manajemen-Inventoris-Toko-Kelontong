import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/product_provider.dart';

/// Halaman Kartu Stok — dengan fitur Search & Filter Kategori
class StockCardPage extends StatefulWidget {
  const StockCardPage({super.key});

  @override
  State<StockCardPage> createState() => _StockCardPageState();
}

class _StockCardPageState extends State<StockCardPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  // Daftar kategori untuk filter (sesuai dengan form input)
  final List<String> _categories = [
    'Semua',
    'Makanan Instan',
    'Minuman',
    'Snack',
    'Sembako',
    'Bumbu Dapur',
    'Perawatan Tubuh',
    'Kebersihan',
    'Rokok',
    'Alat Tulis',
    'Lainnya',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    var products = productProvider.products;

    // ==========================================
    // LOGIKA FILTER & SEARCH
    // ==========================================
    
    // 1. Filter berdasarkan Kategori
    if (_selectedCategory != 'Semua') {
      products = products
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    // 2. Filter berdasarkan Ketikan Search
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      products = products.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query);
        // Bisa juga mencari berdasarkan barcode jika ada
        final barcodeMatch = p.barcode?.toLowerCase().contains(query) ?? false;
        return nameMatch || barcodeMatch;
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kartu Stok'),
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
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau barcode...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
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
                const SizedBox(height: 10),

                // Filter Kategori (Horizontal Scroll)
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isActive = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? Colors.white : AppColors.textPrimary,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isActive,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
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

          // ============ LIST PRODUK ============
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: products.length,
                        itemBuilder: (context, i) {
                          final p = products[i];
                          
                          // Warna status stok
                          Color statusColor = p.stockStatus == 'SAFE' 
                              ? AppColors.safe 
                              : p.stockStatus == 'LOW' 
                                  ? AppColors.low 
                                  : AppColors.out;

                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppColors.divider.withValues(alpha: 0.3)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(
                                  p.name[0].toUpperCase(),
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  // Tampilkan Kategori
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      p.category,
                                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Stok: ${p.currentStock} ${p.unit}'),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  p.currentStock == 0 ? 'HABIS' : '${p.currentStock}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
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
              child: const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Produk tidak ditemukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coba ubah filter kategori atau kata kunci pencarian',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}