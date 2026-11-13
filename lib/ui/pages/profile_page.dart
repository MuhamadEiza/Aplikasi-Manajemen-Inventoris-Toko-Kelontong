import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/menu_tile.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';
import 'help_tutorial_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  // Future untuk Data User (Nama, Email, Role)
  late Future<Map<String, dynamic>> _userProfileFuture;
  
  // Future untuk Data Toko
  late Future<Map<String, dynamic>> _storeDataFuture;
  
  // Future untuk Ringkasan Data
  late Future<Map<String, int>> _summaryDataFuture;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // Fungsi untuk memuat semua data sekaligus
  void _loadAllData() {
    _userProfileFuture = _fetchUserProfile();
    _storeDataFuture = _fetchStoreData();
    _summaryDataFuture = _fetchSummaryData();
  }

  // 1. Ambil Data User yang Login (Untuk Kartu Profil)
  Future<Map<String, dynamic>> _fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User belum login");

    return await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
  }

  // 2. Ambil Data Toko
  Future<Map<String, dynamic>> _fetchStoreData() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User belum login");

    final currentUserProfile = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();
        
    final isAdmin = currentUserProfile['role'] == 'Admin';

    if (isAdmin) {
      final myProfile = await supabase
          .from('profiles')
          .select('store_name, store_address')
          .eq('id', user.id)
          .single();
          
      if (myProfile['store_name'] != null && myProfile['store_name'].toString().isNotEmpty) {
        return myProfile;
      }
    }

    final adminStore = await supabase
        .from('profiles')
        .select('store_name, store_address')
        .eq('role', 'Admin')
        .limit(1)
        .maybeSingle();
        
    if (adminStore != null) {
      return adminStore;
    }
    
    return {'store_name': 'Nama Toko Belum Diatur', 'store_address': 'Alamat Belum Diatur'};
  }

  // 3. Ambil Data Hitungan (Ringkasan)
  Future<Map<String, int>> _fetchSummaryData() async {
    final productsRes = await supabase.from('products').select('*').count(CountOption.exact);
    final vendorsRes = await supabase.from('vendors').select('*').count(CountOption.exact);
    final stockOutRes = await supabase.from('stock_out').select('*').count(CountOption.exact);

    return {
      'products': productsRes.count,
      'vendors': vendorsRes.count,
      'transactions': stockOutRes.count,
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CARD PROFIL USER (Sekarang Dinamis)
            _profileCard(),
            const SizedBox(height: 16),

            // CARD INFO TOKO
            _storeCard(),
            const SizedBox(height: 16),

            // STATISTIK SINGKAT
            _sectionTitle('Ringkasan Data'),
            const SizedBox(height: 8),
            _statsCard(), 

            const SizedBox(height: 16),

            // MENU PENGATURAN
            _sectionTitle('Pengaturan'),
            const SizedBox(height: 8),

            MenuTile(
              icon: Icons.person_outline,
              title: 'Edit Profil',
              subtitle: 'Nama, email, nomor HP',
              onTap: () async {
                // Tangkap hasil (true/false) dari halaman edit
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
                
                // Jika hasilnya true (berhasil simpan), refresh semua data dari database
                if (result == true && mounted) {
                  setState(() {
                    _loadAllData();
                  });
                }
              },
            ),
            
            const SizedBox(height: 16),

            // MENU BANTUAN
            _sectionTitle('Bantuan & Info'),
            const SizedBox(height: 8),

            MenuTile(
              icon: Icons.help_outline,
              title: 'Bantuan & Tutorial',
              subtitle: 'Panduan penggunaan aplikasi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpTutorialPage()),
                );
              },
            ),
            MenuTile(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              subtitle: 'WarungStock v1.0.1 (UAS Build)',
              onTap: () => _showAboutDialog(context),
            ),

            const SizedBox(height: 24),
            _logoutButton(context, auth),
            const SizedBox(height: 24),

            const Center(
              child: Text(
                'WarungStock v1.0.1 (UAS Build)',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==================== PROFILE CARD (DINAMIS) ====================
  Widget _profileCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Gagal memuat profil', style: TextStyle(color: Colors.red));
        }

        final data = snapshot.data!;
        final name = data['name'] ?? 'Pengguna';
        final email = data['email'] ?? '-';
        final role = data['role'] ?? 'Staff';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'Role: $role',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== STORE CARD ====================
  Widget _storeCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _storeDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: const Text('Gagal memuat data toko.', style: TextStyle(color: Colors.red)),
          );
        }

        final data = snapshot.data!;
        final storeName = data['store_name'] ?? 'Nama Toko Belum Diatur';
        final storeAddress = data['store_address'] ?? 'Alamat Belum Diatur';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.storefront, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Toko Kelontong',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      storeAddress,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== STATS CARD ====================
  Widget _statsCard() {
    return FutureBuilder<Map<String, int>>(
      future: _summaryDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
           return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: const Text('Gagal memuat ringkasan data.', style: TextStyle(color: Colors.red)),
          );
        }

        final data = snapshot.data!;
        final totalProducts = data['products'] ?? 0;
        final totalVendors = data['vendors'] ?? 0;
        final totalTransactions = data['transactions'] ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Expanded(child: _statItem(Icons.inventory_2, '$totalProducts', 'Produk', AppColors.primary)),
              Container(height: 40, width: 1, color: AppColors.divider.withValues(alpha: 0.3)),
              Expanded(child: _statItem(Icons.local_shipping, '$totalVendors', 'Vendor', AppColors.accent)),
              Container(height: 40, width: 1, color: AppColors.divider.withValues(alpha: 0.3)),
              Expanded(child: _statItem(Icons.swap_horiz, '$totalTransactions', 'Transaksi', AppColors.safe)),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  // ==================== LOGOUT BUTTON ====================
  Widget _logoutButton(BuildContext context, AuthProvider auth) {
    return OutlinedButton.icon(
      onPressed: () => _showLogoutDialog(context, auth),
      icon: const Icon(Icons.logout, color: AppColors.out),
      label: const Text('KELUAR DARI AKUN', style: TextStyle(color: AppColors.out, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.out, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.out),
            SizedBox(width: 8),
            Text('Keluar Akun?'),
          ],
        ),
        content: const Text('Anda yakin ingin keluar dari akun ini? Anda perlu login kembali untuk mengakses aplikasi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.out),
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  // ==================== ABOUT DIALOG ====================
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Tentang Aplikasi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Icon(Icons.storefront, size: 48, color: AppColors.primary)),
            SizedBox(height: 12),
            Center(child: Text('WarungStock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            SizedBox(height: 4),
            Center(child: Text('v1.0.1 (UAS Build)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
            SizedBox(height: 16),
            Text('Aplikasi Manajemen Inventaris Toko Kelontong yang membantu pemilik toko mencatat stok masuk/keluar dari vendor, mengelola harga beli-jual, dan melakukan opname.', style: TextStyle(fontSize: 12)),
            SizedBox(height: 12),
            Text('Dibuat untuk tugas kuliah PPB — semester ini.', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  // ==================== HELPER ====================
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    );
  }
}