import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/stock_opname.dart';
import '../../../providers/opname_provider.dart';
import '../../../providers/product_provider.dart';

/// Form Opname Baru — dengan scan barcode + input stok fisik
class OpnameFormPage extends StatefulWidget {
  const OpnameFormPage({super.key});

  @override
  State<OpnameFormPage> createState() => _OpnameFormPageState();
}

class _OpnameFormPageState extends State<OpnameFormPage> {
  final _barcodeController = TextEditingController();
  final _physicalStockController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedProductId;

  // List item opname
  final List<Map<String, dynamic>> _items = [];

  @override
  void dispose() {
    _barcodeController.dispose();
    _physicalStockController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Cari produk by barcode → auto-fill
  void _searchByBarcode() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    final product = context.read<ProductProvider>().getByBarcode(barcode);

    if (product == null) {
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
        ),
      );
      return;
    }

    setState(() {
      _selectedProductId = product.id;
      _physicalStockController.text = product.currentStock.toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ditemukan: ${product.name} (stok sistem: ${product.currentStock})',
        ),
        backgroundColor: AppColors.safe,
      ),
    );
  }

  /// Placeholder scan kamera
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
        content: const Text(
          'Fitur scan kamera akan aktif setelah UAS.\n\n'
          'Untuk saat ini, silakan ketik barcode manual lalu tekan tombol cari.',
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

  /// Tambah item ke list opname
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

    final physicalStock = int.tryParse(_physicalStockController.text);
    if (physicalStock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok fisik harus berupa angka')),
      );
      return;
    }

    // Cek apakah produk sudah ada di list
    final existingIndex = _items.indexWhere(
      (item) => item['productId'] == product.id,
    );
    if (existingIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk sudah ada di list opname')),
      );
      return;
    }

    setState(() {
      _items.add({
        'productId': product.id,
        'name': product.name,
        'systemStock': product.currentStock,
        'physicalStock': physicalStock,
        'difference': physicalStock - product.currentStock,
        'purchasePrice': product.purchasePrice,
        'unit': product.unit,
      });
      _barcodeController.clear();
      _physicalStockController.clear();
      _noteController.clear();
      _selectedProductId = null;
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 produk')),
      );
      return;
    }

    final opname = StockOpname(
      id: 'op${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      items: _items
          .map(
            (item) => StockOpnameItem(
              productId: item['productId'],
              productName: item['name'],
              systemStock: item['systemStock'],
              physicalStock: item['physicalStock'],
              note: item['note'],
              purchasePrice: item['purchasePrice'],
            ),
          )
          .toList(),
    );

    await context.read<OpnameProvider>().addOpname(opname);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opname berhasil disimpan'),
          backgroundColor: AppColors.safe,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Opname Baru'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ============ TANGGAL ============
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  const Text('Tanggal Opname', style: TextStyle(fontSize: 13)),
                  const Spacer(),
                  Text(
                    _formatDate(DateTime.now()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                        '${p.name} (sistem: ${p.currentStock})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedProductId = v;
                  final p = productProvider.getById(v!);
                  _physicalStockController.text =
                      p?.currentStock.toString() ?? '';
                });
              },
            ),
            const SizedBox(height: 12),

            // ============ INFO STOK SISTEM ============
            if (_selectedProductId != null) ...[
              Builder(
                builder: (context) {
                  final p = productProvider.getById(_selectedProductId!);
                  if (p == null) return const SizedBox();
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Stok sistem: ${p.currentStock} ${p.unit}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            // ============ INPUT STOK FISIK ============
            _sectionTitle('Stok Fisik'),
            const SizedBox(height: 8),
            TextField(
              controller: _physicalStockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah stok fisik di rak',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
                hintText: 'Masukkan jumlah hasil hitung manual',
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Keterangan (opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
                hintText: 'Contoh: barang rusak, tumpah, salah catat',
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('TAMBAH KE LIST OPNAME'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            // ============ LIST ITEM OPNAME ============
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 24),
              _sectionTitle('Produk Diopname (${_items.length})'),
              const SizedBox(height: 8),
              ..._items.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final diff = item['difference'] as int;
                final diffColor = diff < 0
                    ? AppColors.out
                    : diff > 0
                    ? AppColors.safe
                    : AppColors.textSecondary;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.out,
                              ),
                              onPressed: () => _removeItem(i),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _stockInfo(
                              'Sistem',
                              '${item['systemStock']} ${item['unit']}',
                            ),
                            const SizedBox(width: 12),
                            _stockInfo(
                              'Fisik',
                              '${item['physicalStock']} ${item['unit']}',
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: diffColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${diff > 0 ? '+' : ''}$diff',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: diffColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: 24),

            // ============ TOMBOL SIMPAN ============
            ElevatedButton(
              onPressed: _items.isEmpty ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: AppColors.divider,
              ),
              child: const Text(
                'SIMPAN LAPORAN OPNAME',
                style: TextStyle(
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

  Widget _stockInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
