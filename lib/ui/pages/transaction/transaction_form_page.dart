import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/stock_in.dart';
import '../../../data/models/stock_out.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/stock_provider.dart';
import '../../../providers/vendor_provider.dart';

/// Form Input Transaksi (Stock In / Stock Out)
/// v2: tambah field scan barcode
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
  final _barcodeController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  final _proofNoteController = TextEditingController();

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
    super.dispose();
  }

  double get _total => _items.fold(
    0,
    (sum, item) => sum + ((item['qty'] as int) * (item['price'] as double)),
  );

  double get _profit => _items.fold(
    0,
    (sum, item) =>
        sum +
        (((item['price'] as double) - (item['purchasePrice'] as double)) *
            (item['qty'] as int)),
  );

  /// Cari produk by barcode → auto-fill dropdown produk
  void _searchByBarcode() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    final product = context.read<ProductProvider>().getByBarcode(barcode);

    if (product == null) {
      // Barcode tidak ditemukan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Barcode "$barcode" tidak terdaftar')),
            ],
          ),
          backgroundColor: AppColors.out,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Barcode ditemukan → auto-fill produk
    setState(() {
      _selectedProductId = product.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Produk ditemukan: ${product.name}')),
          ],
        ),
        backgroundColor: AppColors.safe,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Placeholder scan kamera (aktif di UAS)
  void _scanWithCamera() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
            Text('Untuk saat ini, silakan:', style: TextStyle(fontSize: 12)),
            SizedBox(height: 4),
            Text(
              '• Ketik barcode manual di field',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '• Lalu tekan tombol cari (icon search)',
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

  void _addItem() {
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih produk dulu')));
      return;
    }

    final product = context.read<ProductProvider>().getById(
      _selectedProductId!,
    );
    if (product == null) return;

    final qty = int.tryParse(_qtyController.text) ?? 1;
    if (qty <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Jumlah minimal 1')));
      return;
    }

    final price = widget.isStockIn
        ? product.purchasePrice
        : product.sellingPrice;

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
        proofImagePath: _proofPath,
      );

      await provider.addStockOut(stockOut);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isStockIn
                ? 'Barang masuk berhasil dicatat'
                : 'Barang keluar berhasil dicatat',
          ),
          backgroundColor: AppColors.safe,
        ),
      );
      Navigator.pop(context);
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
            // ============ VENDOR (khusus Barang Masuk) ============
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
            // if (widget.isStockIn) ...[
            //   _sectionTitle('Vendor / Agen *'),
            //   const SizedBox(height: 8),
            //   TextFormField(
            //     controller: _vendorNameController,
            //     decoration: const InputDecoration(
            //       border: OutlineInputBorder(),
            //       prefixIcon: Icon(Icons.local_shipping),
            //       hintText: 'Ketik nama vendor / agen',
            //     ),
            //   ),
            //   const SizedBox(height: 20),
            // ],
            // ============ SCAN BARCODE ============
            _sectionTitle('Scan / Cari Barcode'),
            const SizedBox(height: 4),
            const Text(
              'Scan barcode untuk auto-pilih produk',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
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
                    if (_barcodeController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: 'Cari produk',
                        onPressed: _searchByBarcode,
                      ),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      tooltip: 'Scan (UAS)',
                      onPressed: _scanWithCamera,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ============ PILIH PRODUK ============
            _sectionTitle('Pilih Produk'),
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
            const SizedBox(height: 10),

            // ============ JUMLAH + TOMBOL TAMBAH ============
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),

            // ============ LIST ITEM ============
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('Item Ditambahkan (${_items.length})'),
              const SizedBox(height: 8),
              ..._items.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    title: Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      '${item['qty']} ${item['unit']} × ${CurrencyFormatter.formatRupiah(item['price'])}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyFormatter.formatRupiah(
                            (item['qty'] as int) * (item['price'] as double),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.out,
                          ),
                          onPressed: () => _removeItem(i),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            // ============ METODE BAYAR (khusus Keluar) ============
            if (!widget.isStockIn && _items.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('Metode Pembayaran'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                ),
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'Transfer', child: Text('Transfer')),
                  DropdownMenuItem(value: 'QRIS', child: Text('QRIS')),
                ],
                onChanged: (v) => setState(() => _selectedPaymentMethod = v),
              ),
            ],

            // ============ BUKTI TRANSAKSI ============
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle(
                widget.isStockIn ? 'Bukti Nota / Faktur' : 'Bukti Struk / Nota',
              ),
              const SizedBox(height: 8),
              _proofUploadBox(),
              const SizedBox(height: 10),
              TextField(
                controller: _proofNoteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan Bukti (opsional)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],

            // ============ TOTAL ============
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total'),
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
                    if (!widget.isStockIn) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Untung'),
                          Text(
                            CurrencyFormatter.formatRupiah(_profit),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.safe,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ============ TOMBOL SIMPAN ============
            ElevatedButton(
              onPressed: _items.isEmpty ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: AppColors.divider,
              ),
              child: Text(
                widget.isStockIn
                    ? 'SIMPAN BARANG MASUK'
                    : 'SIMPAN BARANG KELUAR',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _proofUploadBox() {
    return InkWell(
      onTap: () {
        setState(() {
          _proofPath = _proofPath == null ? 'dummy/proof.jpg' : null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _proofPath == null
                  ? 'Bukti dihapus'
                  : 'Bukti ditambahkan (simulasi)',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: _proofPath == null
              ? AppColors.background
              : AppColors.safe.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _proofPath == null ? AppColors.divider : AppColors.safe,
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _proofPath == null ? Icons.camera_alt : Icons.check_circle,
                size: 32,
                color: _proofPath == null
                    ? AppColors.textSecondary
                    : AppColors.safe,
              ),
              const SizedBox(height: 8),
              Text(
                _proofPath == null
                    ? 'Tap untuk upload bukti'
                    : 'Bukti terlampir ✓',
                style: TextStyle(
                  fontSize: 12,
                  color: _proofPath == null
                      ? AppColors.textSecondary
                      : AppColors.safe,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_proofPath == null)
                const Text(
                  '(simulasi — foto belum diupload)',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
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
