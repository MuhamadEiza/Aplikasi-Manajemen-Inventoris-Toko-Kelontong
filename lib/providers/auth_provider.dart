import 'package:flutter/material.dart';

/// Provider untuk Auth & Role
/// Menyimpan status login + role user (Admin/Staff/Customer)
class AuthProvider extends ChangeNotifier {
  String? _role;
  String? _name;
  String? _email;

  // Getter
  String? get role => _role;
  String? get name => _name;
  String? get email => _email;

  bool get isLoggedIn => _role != null;
  bool get isAdmin => _role == 'Admin';
  bool get isStaff => _role == 'Staff';

  /// Login — simpan role & nama user
  void login({
    required String role,
    required String email,
    String? name,
  }) {
    _role = role;
    _email = email;
    _name = name ??
        (role == 'Admin'
            ? 'Admin Toko'
            : role == 'Staff'
                ? 'Staff Toko'
                : 'Customer');
    notifyListeners();
  }

  /// Logout — hapus semua data user
  void logout() {
    _role = null;
    _email = null;
    _name = null;
    notifyListeners();
  }
}