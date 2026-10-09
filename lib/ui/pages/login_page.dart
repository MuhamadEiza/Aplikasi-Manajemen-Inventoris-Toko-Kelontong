import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dashboard_page.dart';

/// Login Page — pilih role Admin/Staff/Customer
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'admin@warung.com');
  final _passwordController = TextEditingController(text: '123456');
  String _selectedRole = 'Admin';

 void _login() {
  // Validasi sederhana
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email dan password wajib diisi')),
    );
    return;
  }

  // Simpan ke AuthProvider
  context.read<AuthProvider>().login(
    role: _selectedRole,
    email: _emailController.text,
  );

  // Redirect ke Dashboard
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const DashboardPage()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.storefront, size: 80, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'WarungStock',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk untuk kelola toko Anda',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),

              // Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email / No. HP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),

              // Role dropdown
              DropdownButtonFormField<String>(
                 initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Masuk Sebagai',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: const [
                  DropdownMenuItem(value: 'Admin', child: Text('Admin / Pemilik')),
                  DropdownMenuItem(value: 'Staff', child: Text('Staff / Karyawan')),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              const SizedBox(height: 24),

              // Tombol Masuk
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('MASUK', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}