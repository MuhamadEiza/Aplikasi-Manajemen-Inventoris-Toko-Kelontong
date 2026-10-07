import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Badge status stok (SAFE / MODERATE / LOW / OUT)
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'SAFE':
        return AppColors.safe;
      case 'MODERATE':
        return AppColors.moderate;
      case 'LOW':
        return AppColors.low;
      case 'OUT':
        return AppColors.out;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _label {
    switch (status) {
      case 'SAFE':
        return '🟢 Aman';
      case 'MODERATE':
        return '🟡 Sedang';
      case 'LOW':
        return '🟠 Menipis';
      case 'OUT':
        return '🔴 Habis';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color, width: 1),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _color,
        ),
      ),
    );
  }
}