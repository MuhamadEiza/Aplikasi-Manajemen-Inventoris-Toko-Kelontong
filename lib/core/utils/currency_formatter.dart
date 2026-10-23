import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Format angka menjadi format mata uang Rupiah (contoh: 3000 -> "Rp 3.000")
  static String formatRupiah(num value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  // Format objek DateTime menjadi string tanggal (contoh: "18 Jun 2026")
  static String formatTanggal(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  // Format angka desimal menjadi string persen (contoh: 0.2 -> "20%")
  static String formatPersen(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }
}