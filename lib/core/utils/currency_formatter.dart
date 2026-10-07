import 'package:intl/intl.dart';

/// Utility untuk format Rupiah dan tanggal
class CurrencyFormatter {
  /// Format angka ke Rupiah: 3000 → "Rp 3.000"
  static String formatRupiah(num value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  /// Format tanggal: DateTime → "18 Jun 2026"
  static String formatTanggal(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  /// Format persen: 0.2 → "20%"
  static String formatPersen(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }
}