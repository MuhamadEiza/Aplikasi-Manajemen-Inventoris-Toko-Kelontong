import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/stock_in.dart';
import '../../../data/models/stock_out.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/stock_provider.dart';
import '../../../providers/vendor_provider.dart';

/// Form Input Transaksi (Stock In / Stock Out)
class TransactionFormPage extends StatefulWidget {
  final bool isStockIn;

  const TransactionFormPage({super.key, required this.isStockIn});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  String? _selectedVendorId;
  String? _selectedProductId;
  String? _selectedPaymentMethod = 'Cash';
  
  // State untuk mencegah double click
  bool _isSaving = false;

  final _barcodeController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  final _proofNoteController = TextEditingController();

  // Controller Khusus Barang Masuk (Input Manual)
  final _manualNameController = TextEditingController();
  final _manualCategoryController = TextEditingController(text: 'Sembako');
  final _manualPriceController = TextEditingController();

  // Simulasi upload bukti
  String? _proofPath;

  // List item
  final List<Map<String, dynamic>> _items = [];

  @override
  void dispose() {
    _barcodeController.dispose();
    _qtyController.dispose();
    _noteController.dispose();
    _proofNoteController.dispose();
    _manualNameController.dispose();
    _manualCategoryController.dispose();
    _manualPriceController.dispose();
    super.dispose();
  }

  double get _total => _items.fold(
    0,
    (sum, item) => sum + ((item['qty'] as int) * (item['price'] as double)),
  );

  /// Fitur Scan Barcode
  void _searchByBarcode() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    final product = context.read<ProductProvider>().getByBarcode(barcode);

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barcode "$barcode" tidak terdaftar'),
          backgroundColor: AppColors.out,
        ),
      );
      return;
    }

    // Jika ditemukan, otomatis isi form
    if (widget.isStockIn) {
      setState(() {
        _manualNameController.text = product.name;
        _manualCategoryController.text = product.category;
        _manualPriceController.text = product.purchasePrice.toStringAsFixed(0);
      });
    } else {
      setState(() {
        _selectedProductId = product.id;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Produk ditemukan: ${product.name}'),
        backgroundColor: AppColors.safe,
      ),
    );
  }

  /// Placeholder scan kamera
  void _scanWithCamera() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan Barcode'),
        content: const Text(
          'Fitur scan kamera aktif setelah UAS. Sementara ketik barcode manual.',
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

  void _addItem() {
    final qty = int.tryParse(_qtyController.text.trim()) ?? 1;
    if (qty <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Jumlah minimal 1')));
      return;
    }

    if (widget.isStockIn) {
      // === LOGIKA BARANG MASUK (Input Manual) ===
      if (_manualNameController.text.isEmpty ||
          _manualPriceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama dan Harga wajib diisi')),
        );
        return;
      }

      final price = double.tryParse(_manualPriceController.text) ?? 0;
      final newProductId = const Uuid().v4(); // Generate ID baru

      setState(() {
        _items.add({
          'productId': newProductId,
          'name': _manualNameController.text.trim(),
          'qty': qty,
          'price': price,
          'purchasePrice': price,
          'unit': 'pcs',
        });

        // Reset form
        _qtyController.text = '1';
        _manualNameController.clear();
        _manualPriceController.clear();
        _barcodeController.clear();
      });
    } else {
      // === LOGIKA BARANG KELUAR (Dropdown) ===
      if (_selectedProductId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Pilih produk dulu')));
        return;
      }

      final product = context.read<ProductProvider>().getById(
        _selectedProductId!,
      );
      if (product == null) return;

      final price = product.sellingPrice;

      setState(() {
        _items.add({
          'productId': product.id,
          'name': product.name,
          'qty': qty,
          'price': price,
          'purchasePrice': product.purchasePrice,
          'unit': product.unit,
        });
        _qtyController.text = '1';
        _selectedProductId = null;
        _barcodeController.clear();
      });
    }
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tambahkan minimal 1 item')));
      return;
    }

    if (widget.isStockIn && _selectedVendorId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih vendor dulu')));
      return;
    }

    final provider = context.read<StockProvider>();
    final id =
        '${widget.isStockIn ? 'si' : 'so'}${DateTime.now().millisecondsSinceEpoch}';

    try {
      if (widget.isStockIn) {
        final vendor = context.read<VendorProvider>().getById(_selectedVendorId!);
        final stockIn = StockIn(
          id: id,
          date: DateTime.now(),
          vendorId: _selectedVendorId,
          vendorName: vendor?.name,
          items: _items
              .map(
                (item) => StockInItem(
                  productId: item['productId'],
                  productName: item['name'],
                  quantity: item['qty'],
                  purchasePrice: item['price'],
                ),
              )
              .toList(),
          proofImagePath: _proofPath,
        );
        await provider.addStockIn(stockIn);
      } else {
        final stockOut = StockOut(
          id: id,
          date: DateTime.now(),
          items: _items
              .map(
                (item) => StockOutItem(
                  productId: item['productId'],
                  productName: item['name'],
                  quantity: item['qty'],
                  sellingPrice: item['price'],
                  purchasePrice: item['purchasePrice'],
                ),
              )
              .toList(),
          paymentMethod: _selectedPaymentMethod,
          proofImagePath: _proofPath,
        );
        await provider.addStockOut(stockOut);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isStockIn ? 'Barang masuk dicatat' : 'Barang keluar dicatat',
            ),
            backgroundColor: AppColors.safe,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.out,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final vendorProvider = context.watch<VendorProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isStockIn ? 'Barang Masuk' : 'Barang Keluar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ============ VENDOR ============
            if (widget.isStockIn) ...[
              _sectionTitle('Vendor / Agen *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedVendorId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                  hintText: 'Pilih vendor',
                ),
                items: vendorProvider.vendors
                    .map(
                      (v) => DropdownMenuItem(value: v.id, child: Text(v.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedVendorId = v),
              ),
              const SizedBox(height: 20),
            ],

            // ============ SCAN BARCODE ============
            _sectionTitle('Scan / Cari Barcode'),
            const SizedBox(height: 8),
            TextField(
              controller: _barcodeController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _searchByBarcode(),
              decoration: InputDecoration(
                hintText: 'Ketik / scan barcode produk',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchByBarcode,
                    ),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanWithCamera,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ============ FORM PRODUK ============
            if (widget.isStockIn) ...[
              // Khusus Barang Masuk (Manual)
              _sectionTitle('Informasi Produk (Input Manual)'),
              const SizedBox(height: 8),
              TextField(
                controller: _manualNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualCategoryController,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _manualPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga Beli',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Khusus Barang Keluar (Dropdown)
              _sectionTitle('Pilih Produk (Dropdown)'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedProductId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                  hintText: 'Pilih produk',
                ),
                items: productProvider.products
                    .map(
                      (p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          '${p.name} (Stok: ${p.currentStock} ${p.unit})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedProductId = v),
              ),
            ],
            const SizedBox(height: 20),

            // ============ JUMLAH ============
            _sectionTitle('Jumlah (pcs)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _addItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Tambah Item',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // ============ LIST ITEM ============
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 20),
              ..._items.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      '${item['qty']} pcs × ${CurrencyFormatter.formatRupiah(item['price'])}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: AppColors.out),
                      onPressed: () => _removeItem(i),
                    ),
                  ),
                );
              }),
            ],

            // ============ TOTAL ============
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      CurrencyFormatter.formatRupiah(_total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ============ TOMBOL SIMPAN (ANTI-DOBEL) ============
            ElevatedButton(
              onPressed: (_items.isEmpty || _isSaving)
                  ? null
                  : () async {
                      setState(() => _isSaving = true);
                      await _save();
                      if (mounted) setState(() => _isSaving = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: AppColors.divider,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.isStockIn
                          ? 'SIMPAN BARANG MASUK'
                          : 'SIMPAN BARANG KELUAR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
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
}