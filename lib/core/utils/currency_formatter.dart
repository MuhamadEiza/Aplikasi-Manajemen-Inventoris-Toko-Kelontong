import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatRupiah(num value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  static String formatTanggal(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  static String formatPersen(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }
}