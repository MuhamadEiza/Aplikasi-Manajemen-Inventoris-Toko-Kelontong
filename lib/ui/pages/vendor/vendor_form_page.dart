import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/vendor.dart';
import '../../../providers/vendor_provider.dart';

/// Form Tambah/Edit Vendor
class VendorFormPage extends StatefulWidget {
  final Vendor? vendor;

  const VendorFormPage({super.key, this.vendor});

  @override
  State<VendorFormPage> createState() => _VendorFormPageState();
}

class _VendorFormPageState extends State<VendorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Jika mode Edit, isi form dengan data lama
    if (widget.vendor != null) {
      _nameController.text = widget.vendor!.name;
      _addressController.text = widget.vendor!.address ?? '';
      _phoneController.text = widget.vendor!.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final vendor = Vendor(
      id: widget.vendor?.id ?? '', // Jika edit, gunakan ID lama
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (widget.vendor != null) {
      await context.read<VendorProvider>().updateVendor(vendor);
    } else {
      await context.read<VendorProvider>().addVendor(vendor);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.vendor != null ? 'Vendor berhasil diubah' : 'Vendor berhasil ditambahkan'),
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
        title: Text(widget.vendor != null ? 'Edit Vendor' : 'Tambah Vendor'),
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
              _sectionTitle('Info Vendor'),
              const SizedBox(height: 10),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Vendor / Agen *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
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
                validator: (v) => v == null || v.isEmpty ? 'Telepon wajib diisi' : null,
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
                validator: (v) => v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget.vendor != null ? 'SIMPAN PERUBAHAN' : 'SIMPAN VENDOR',
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