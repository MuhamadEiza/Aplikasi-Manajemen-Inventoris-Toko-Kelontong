import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/vendor.dart';
import '../../../providers/vendor_provider.dart';

/// Form Tambah Vendor
class VendorFormPage extends StatefulWidget {
  const VendorFormPage({super.key});

  @override
  State<VendorFormPage> createState() => _VendorFormPageState();
}

class _VendorFormPageState extends State<VendorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  // Kategori yang disupply (multi-select)
  final List<String> _allCategories = [
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
  final Set<String> _selectedCategories = {};

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 kategori yang disuplai'),
          backgroundColor: AppColors.low,
        ),
      );
      return;
    }

    final vendor = Vendor(
      id: 'v${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      suppliedCategories: _selectedCategories.toList(),
    );

    await context.read<VendorProvider>().addVendor(vendor);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendor berhasil ditambahkan'),
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
        title: const Text('Tambah Vendor'),
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
              // ============ INFO VENDOR ============
              _sectionTitle('Info Vendor'),
              const SizedBox(height: 10),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Vendor / Agen *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Telepon wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alamat *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // ============ KATEGORI SUPPLY ============
              _sectionTitle('Kategori yang Disuplai *'),
              const SizedBox(height: 4),
              const Text(
                'Pilih satu atau lebih',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allCategories.map((cat) {
                  final isSelected = _selectedCategories.contains(cat);
                  return FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(cat);
                        } else {
                          _selectedCategories.remove(cat);
                        }
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.background,
                    checkmarkColor: Colors.white,
                    showCheckmark: false,
                  );
                }).toList(),
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
                child: const Text(
                  'SIMPAN VENDOR',
                  style: TextStyle(
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