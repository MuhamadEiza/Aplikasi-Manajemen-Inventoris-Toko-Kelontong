import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- Tambahkan ini
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart'; // <-- Tambahkan ini

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _storeNameController;
  late TextEditingController _storeAddressController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _storeNameController = TextEditingController();
    _storeAddressController = TextEditingController();

    _fetchCurrentProfile();
  }

  Future<void> _fetchCurrentProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Ambil data profil user yang sedang login
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      // Jika yang login adalah Staff, ambil data toko dari akun Admin
      // (Agar staff bisa melihat nama toko yang benar, meskipun tidak bisa mengeditnya)
      Map<String, dynamic>? storeData;
      final auth = context.read<AuthProvider>();
      if (!auth.isAdmin) {
         storeData = await supabase
          .from('profiles')
          .select('store_name, store_address')
          .eq('role', 'Admin')
          .limit(1)
          .maybeSingle();
      } else {
        storeData = data; // Kalau admin, pakai data sendiri
      }

      setState(() {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        
        _storeNameController.text = storeData?['store_name'] ?? '';
        _storeAddressController.text = storeData?['store_address'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User tidak ditemukan");
      final auth = context.read<AuthProvider>();

      // Siapkan data yang mau diupdate
      Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      // HANYA update data toko JIKA yang login adalah Admin
      if (auth.isAdmin) {
        updateData['store_name'] = _storeNameController.text.trim();
        updateData['store_address'] = _storeAddressController.text.trim();
      }

      // Eksekusi update ke Supabase
      await supabase.from('profiles').update(updateData).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diupdate!'), backgroundColor: Colors.green),
        );
          Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengupdate: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>(); // Pantau role user

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor HP',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),

                    // ========================================================
                    // SEMBUNYIKAN INFORMASI TOKO JIKA YANG LOGIN BUKAN ADMIN
                    // ========================================================
                    if (auth.isAdmin) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),

                      const Text('Informasi Toko', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _storeNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Toko',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.storefront),
                        ),
                        validator: (value) => value!.isEmpty ? 'Nama toko tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _storeAddressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Lengkap Toko',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) => value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                      ),
                    ],

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('SIMPAN PERUBAHAN', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}