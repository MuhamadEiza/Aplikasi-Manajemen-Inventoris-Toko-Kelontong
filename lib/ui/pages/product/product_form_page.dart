import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/product.dart';
import '../../../../providers/product_provider.dart';

/// Form Tambah/Edit Produk (1 halaman, tanpa multi-step)
class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();

  String _selectedCategory = 'Makanan Instan';
  String _selectedUnit = 'pcs';

  final List<String> _categories = [
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

  final List<String> _units = ['pcs', 'kg', 'liter', 'botol', 'dus', 'pack'];

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.product!;
      _nameController.text = p.name;
      _selectedCategory = p.category;
      _selectedUnit = p.unit;
      _purchasePriceController.text = p.purchasePrice.toStringAsFixed(0);
      _sellingPriceController.text = p.sellingPrice.toStringAsFixed(0);
      _stockController.text = p.currentStock.toString();
      _minStockController.text = p.minimumStock.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  double get _marginPercent {
    final beli = double.tryParse(_purchasePriceController.text) ?? 0;
    final jual = double.tryParse(_sellingPriceController.text) ?? 0;
    if (beli <= 0) return 0;
    return (jual - beli) / beli;
  }

  double get _marginRupiah {
    final beli = double.tryParse(_purchasePriceController.text) ?? 0;
    final jual = double.tryParse(_sellingPriceController.text) ?? 0;
    return jual - beli;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();

    final product = Product(
      id: _isEdit
          ? widget.product!.id
          : 'p${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      category: _selectedCategory,
      unit: _selectedUnit,
      purchasePrice: double.parse(_purchasePriceController.text),
      sellingPrice: double.parse(_sellingPriceController.text),
      currentStock: int.parse(_stockController.text),
      minimumStock: int.parse(_minStockController.text),
    );

    if (_isEdit) {
      await provider.updateProduct(product);
    } else {
      await provider.addProduct(product);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Produk berhasil diubah' : 'Produk berhasil ditambahkan',
          ),
          backgroundColor: AppColors.safe,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Produk' : 'Tambah Produk'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ============ INFO BARANG ============
              _sectionTitle('Info Barang'),
              const SizedBox(height: 10),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Satuan *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                ),
                items: _units
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedUnit = v!),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand (opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.branding_watermark),
                ),
              ),
              const SizedBox(height: 20),

              // ============ HARGA ============
              _sectionTitle('Harga'),
              const SizedBox(height: 10),

              TextFormField(
                controller: _purchasePriceController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Harga Beli (Rp) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_cart),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Harga beli wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _sellingPriceController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Harga Jual (Rp) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sell),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Harga jual wajib diisi';
                  final beli = double.tryParse(_purchasePriceController.text) ?? 0;
                  final jual = double.tryParse(v) ?? 0;
                  if (jual < beli) return 'Harga jual < harga beli';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Margin preview (read-only)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.safe.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.safe.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Margin',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.safe,
                      ),
                    ),
                    Text(
                      '${CurrencyFormatter.formatRupiah(_marginRupiah)} '
                      '(${CurrencyFormatter.formatPersen(_marginPercent)})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.safe,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ============ STOK ============
              _sectionTitle('Stok'),
              const SizedBox(height: 10),

              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok Saat Ini *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Stok wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _minStockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok Minimum *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning_amber),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Stok minimum wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // ============ TOMBOL SIMPAN ============
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _isEdit ? 'SIMPAN PERUBAHAN' : 'SIMPAN PRODUK',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
}