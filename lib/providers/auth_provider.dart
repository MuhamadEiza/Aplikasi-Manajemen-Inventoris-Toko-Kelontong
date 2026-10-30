import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  String? _role;
  String? _name;
  String? _email;
  bool _isLoading = false;

  String? get role => _role;
  String? get name => _name;
  String? get email => _email;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _role != null;
  bool get isAdmin => _role == 'Admin';
  bool get isStaff => _role == 'Staff';

  final _supabase = Supabase.instance.client;

  /// Fungsi Login ke Supabase
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Proses Autentikasi
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // 2. Ambil Role & Nama dari tabel 'profiles'
        final profileData = await _supabase
            .from('profiles')
            .select('name, role')
            .eq('id', response.user!.id)
            .single();

        _email = email;
        _name = profileData['name'];
        _role = profileData['role']; // Otomatis dapat 'Admin' atau 'Staff'
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Gagal mengambil data profil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fungsi Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _role = null;
    _email = null;
    _name = null;
    notifyListeners();
  }
}