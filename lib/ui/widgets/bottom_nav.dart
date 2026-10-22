import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Bottom Navigation — menu berubah sesuai role
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final String role;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Menu berbeda per role
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2),
        label: 'Masuk',
      ),
     const BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2),
        label: 'Keluar',
      ),
     
      // Opname hanya untuk Admin
      if (role == 'Admin')
        const BottomNavigationBarItem(
          icon: Icon(Icons.fact_check),
          label: 'Opname',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex > items.length - 1 ? 0 : currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      items: items,
    );
  }
}