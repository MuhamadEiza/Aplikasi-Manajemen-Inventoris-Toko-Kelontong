import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';

/// Form Tambah/Edit Produk
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
  final _barcodeController = TextEditingController();
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
      _barcodeController.text = p.barcode ?? '';
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
    _barcodeController.dispose();
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

  /// Generate barcode dummy berdasarkan timestamp
  void _generateBarcode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    // Ambil 13 digit terakhir
    final barcode = timestamp.substring(timestamp.length - 13);
    setState(() {
      _barcodeController.text = barcode;
    });
  }

  /// Placeholder scan barcode (aktif di UAS)
  void _scanBarcode() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Scan Barcode'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitur scan kamera akan aktif setelah UAS.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Untuk saat ini, silakan:',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 4),
            Text(
              '• Ketik barcode manual di field',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '• Atau klik "Generate" untuk barcode otomatis',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
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
            _isEdit
                ? 'Produk berhasil diubah'
                : 'Produk berhasil ditambahkan',
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

              // ============ BARCODE SECTION (BARU) ============
              _sectionTitle('Barcode Produk'),
              const SizedBox(height: 4),
              const Text(
                'Kode barcode untuk scan cepat',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _barcodeController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Kode Barcode (opsional)',
                  hintText: 'Contoh: 8992388101010',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.qr_code),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: 'Scan (UAS)',
                    onPressed: _scanBarcode,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Tombol Generate
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _generateBarcode,
                      icon: const Icon(Icons.autorenew, size: 18),
                      label: const Text(
                        'Generate Otomatis',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              // Preview barcode
              if (_barcodeController.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.divider.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Preview Barcode',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: _barcodeController.text,
                        width: double.infinity,
                        height: 70,
                        drawText: true,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

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
                  final beli =
                      double.tryParse(_purchasePriceController.text) ?? 0;
                  final jual = double.tryParse(v) ?? 0;
                  if (jual < beli) return 'Harga jual < harga beli';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Margin preview
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