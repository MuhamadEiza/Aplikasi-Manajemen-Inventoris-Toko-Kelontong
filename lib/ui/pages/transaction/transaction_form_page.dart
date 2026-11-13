import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/product.dart';
import '../../../data/models/stock_in.dart';
import '../../../data/models/stock_out.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/stock_provider.dart';
import '../../../providers/vendor_provider.dart';

class TransactionFormPage extends StatefulWidget {
  final bool isStockIn;
  final StockIn? stockInToEdit;

  const TransactionFormPage({
    super.key,
    required this.isStockIn,
    this.stockInToEdit,
  });

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  String? _selectedVendorId;
  String? _selectedProductId;
  String? _selectedPaymentMethod = 'Cash';

  bool _isSaving = false;

  final _barcodeController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');

  final _manualNameController = TextEditingController();
  final _manualCategoryController = TextEditingController(text: 'Sembako');
  final _manualPriceController = TextEditingController();
  
  // Controller untuk Harga Jual Manual (Barang Keluar)
  final _sellingPriceController = TextEditingController();

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

  String? _proofPath;
  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });

    if (widget.stockInToEdit != null) {
      final data = widget.stockInToEdit!;
      _selectedVendorId = data.vendorId;

      for (var item in data.items) {
        _items.add({
          'productId': item.productId,
          'name': item.productName,
          'category': item.category,
          'qty': item.quantity,
          'price': item.purchasePrice,
          'purchasePrice': item.purchasePrice,
          'unit': 'pcs',
        });
      }

      if (data.items.isNotEmpty) {
        final firstItem = data.items.first;
        _barcodeController.text = firstItem.productId;

        final masterProduct = context.read<ProductProvider>().getById(
          firstItem.productId,
        );

        if (masterProduct != null) {
          _manualNameController.text = masterProduct.name;
          _manualCategoryController.text = masterProduct.category;
        } else {
          _manualNameController.text = firstItem.productName.replaceAll(
            'Produk ID: ',
            '',
          );
          _manualCategoryController.text = firstItem.category;
        }

        _manualPriceController.text = firstItem.purchasePrice.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _qtyController.dispose();
    _manualNameController.dispose();
    _manualCategoryController.dispose();
    _manualPriceController.dispose();
    _sellingPriceController.dispose(); // Dispose controller baru
    super.dispose();
  }

  double get _total => _items.fold(
    0,
    (sum, item) => sum + ((item['qty'] as int) * (item['price'] as double)),
  );

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

    setState(() {
      if (widget.isStockIn) {
        _manualNameController.text = product.name;
        _manualCategoryController.text = product.category;
        _manualPriceController.text = product.purchasePrice.toStringAsFixed(0);
      } else {
        _selectedProductId = product.id;
        _sellingPriceController.text = product.sellingPrice.toStringAsFixed(0); // Isi otomatis
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Produk ditemukan: ${product.name}'),
        backgroundColor: AppColors.safe,
      ),
    );
  }

  void _scanWithCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(title: const Text('Scan Barcode')),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  Navigator.pop(ctx, barcode.rawValue);
                  break;
                }
              }
            },
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _barcodeController.text = result.toString();
      });
      _searchByBarcode();
    }
  }

  void _addItem() {
    final qty = int.tryParse(_qtyController.text.trim()) ?? 1;
    if (qty <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Jumlah minimal 1')));
      return;
    }

    if (widget.isStockIn) {
      if (_manualNameController.text.isEmpty || _manualPriceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama dan Harga wajib diisi')),
        );
        return;
      }

      final price = double.tryParse(_manualPriceController.text) ?? 0;
      final inputName = _manualNameController.text.trim();
      final barcodeInput = _barcodeController.text.trim();

      final productProvider = context.read<ProductProvider>();
      final existingProduct = productProvider.products.firstWhere(
        (p) => p.name.toLowerCase() == inputName.toLowerCase(),
        orElse: () => Product(
          id: '', name: '', category: '', unit: '', 
          purchasePrice: 0, sellingPrice: 0, currentStock: 0, minimumStock: 0
        ),
      );

      final newProductId = existingProduct.id.isNotEmpty
          ? existingProduct.id
          : (barcodeInput.isNotEmpty ? barcodeInput : const Uuid().v4());

      setState(() {
        if (widget.stockInToEdit != null && _items.isNotEmpty) {
          _items[0] = {
            'productId': newProductId,
            'name': inputName,
            'category': _manualCategoryController.text.trim(),
            'qty': qty,
            'price': price,
            'purchasePrice': price,
            'unit': 'pcs',
          };
        } else {
          _items.add({
            'productId': newProductId,
            'name': inputName,
            'category': _manualCategoryController.text.trim(),
            'qty': qty,
            'price': price,
            'purchasePrice': price,
            'unit': 'pcs',
          });
        }

        _qtyController.text = '1';

        if (widget.stockInToEdit == null) {
          _manualNameController.clear();
          _manualPriceController.clear();
          _barcodeController.clear();
        }
      });
    } else {
      if (_selectedProductId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Pilih produk dulu')));
        return;
      }

      final product = context.read<ProductProvider>().getById(_selectedProductId!);
      if (product == null) return;

      // AMBIL HARGA JUAL DARI INPUT MANUAL
      final customSellingPrice = double.tryParse(_sellingPriceController.text) ?? product.sellingPrice;

      setState(() {
        _items.add({
          'productId': product.id,
          'name': product.name,
          'category': product.category,
          'qty': qty,
          'price': customSellingPrice, // Gunakan harga jual manual
          'purchasePrice': product.purchasePrice,
          'unit': product.unit,
        });
        _qtyController.text = '1';
        _selectedProductId = null;
        _barcodeController.clear();
        _sellingPriceController.clear(); // Kosongkan setelah ditambahkan
      });
    }
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tambahkan minimal 1 item')));
      return;
    }

    if (widget.isStockIn && _selectedVendorId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih vendor dulu')));
      return;
    }

    final provider = context.read<StockProvider>();
    final id = widget.stockInToEdit?.id ?? '${widget.isStockIn ? 'si' : 'so'}${DateTime.now().millisecondsSinceEpoch}';

    try {
      if (widget.isStockIn) {
        final vendor = context.read<VendorProvider>().getById(_selectedVendorId!);
        final stockIn = StockIn(
          id: id,
          date: DateTime.now(),
          vendorId: _selectedVendorId,
          vendorName: vendor?.name ?? 'Vendor tidak diketahui',
          items: _items.map((item) => StockInItem(
            productId: item['productId'],
            productName: item['name'],
            category: item['category'] ?? 'Sembako',
            quantity: item['qty'],
            purchasePrice: item['price'],
          )).toList(),
          proofImagePath: _proofPath,
          initialStock: _items.isNotEmpty ? _items.first['qty'] : 0,
        );
        if (widget.stockInToEdit != null) {
          await provider.updateStockIn(stockIn);
        } else {
          await provider.addStockIn(stockIn);
        }
        
        if (mounted) await context.read<ProductProvider>().loadProducts();
      } else {
        final stockOut = StockOut(
          id: id,
          date: DateTime.now(),
          items: _items.map((item) => StockOutItem(
            productId: item['productId'],
            productName: item['name'],
            quantity: item['qty'],
            sellingPrice: item['price'],
            purchasePrice: item['purchasePrice'],
          )).toList(),
          paymentMethod: _selectedPaymentMethod,
          proofImagePath: _proofPath,
        );
        await provider.addStockOut(stockOut);

        if (mounted) await context.read<ProductProvider>().loadProducts();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaksi berhasil disimpan'), backgroundColor: AppColors.safe),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.out),
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
        title: Text(
          widget.stockInToEdit != null
              ? 'Edit Barang Masuk'
              : (widget.isStockIn ? 'Barang Masuk' : 'Barang Keluar'),
        ),
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
                initialValue: vendorProvider.vendors.any((v) => v.id == _selectedVendorId) ? _selectedVendorId : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                  hintText: 'Pilih vendor',
                ),
                items: vendorProvider.vendors.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name))).toList(),
                onChanged: (v) => setState(() => _selectedVendorId = v),
              ),
              const SizedBox(height: 20),
            ],

            // ============ SCAN BARCODE ============
            _sectionTitle('Scan / Barcode'),
            const SizedBox(height: 8),
            TextField(
              controller: _barcodeController,
              keyboardType: TextInputType.text,
              onSubmitted: (_) => _searchByBarcode(),
              decoration: InputDecoration(
                hintText: 'Ketik / scan barcode (atau UUID)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.search), onPressed: _searchByBarcode),
                    IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanWithCamera),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ============ FORM PRODUK ============
            if (widget.isStockIn) ...[
              _sectionTitle('Informasi Produk'),
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
                    child: DropdownButtonFormField<String>(
                      initialValue: _categories.contains(_manualCategoryController.text) ? _manualCategoryController.text : 'Sembako',
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                      items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _manualCategoryController.text = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _manualPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Harga Beli', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ] else ...[
              _sectionTitle('Pilih Produk (Dropdown)'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: productProvider.products.any((p) => p.id == _selectedProductId) ? _selectedProductId : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                  hintText: 'Pilih produk',
                ),
                items: productProvider.products.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text('${p.name} (Stok: ${p.currentStock} ${p.unit})', overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedProductId = v;
                    if (v != null) {
                      final selectedProduct = productProvider.getById(v);
                      if (selectedProduct != null) {
                        _barcodeController.text = selectedProduct.id;
                        _sellingPriceController.text = selectedProduct.sellingPrice.toStringAsFixed(0);
                      }
                    } else {
                      _barcodeController.clear();
                      _sellingPriceController.clear();
                    }
                  });
                },
              ),
              
              // ==========================================
              // TAMBAHAN INPUT HARGA JUAL MANUAL
              // ==========================================
              const SizedBox(height: 16),
              _sectionTitle('Harga Jual (Bisa Diedit)'),
              const SizedBox(height: 8),
              TextField(
                controller: _sellingPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga Jual Akhir',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sell),
                  hintText: 'Ubah harga jual jika perlu',
                ),
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
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _addItem,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Tambah Item', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${item['qty']} pcs × ${CurrencyFormatter.formatRupiah(item['price'])}'),
                    trailing: IconButton(icon: const Icon(Icons.close, color: AppColors.out), onPressed: () => _removeItem(i)),
                  ),
                );
              }),
            ],

            // ============ TOTAL ============
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(CurrencyFormatter.formatRupiah(_total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ============ TOMBOL SIMPAN ============
            ElevatedButton(
              onPressed: (_items.isEmpty || _isSaving) ? null : () async {
                setState(() => _isSaving = true);
                await _save();
                if (mounted) setState(() => _isSaving = false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), disabledBackgroundColor: AppColors.divider),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      widget.stockInToEdit != null
                          ? 'SIMPAN PERUBAHAN'
                          : (widget.isStockIn ? 'SIMPAN BARANG MASUK' : 'SIMPAN BARANG KELUAR'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    );
  }
}