import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount, {String currency = 'USD'}) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: currency == 'USD' ? 'USD ' : 'VNĐ ',
      decimalDigits: currency == 'VND' ? 0 : 2,
    );
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatArea(double sqm) {
    if (sqm >= 10000) {
      return '${(sqm / 10000).toStringAsFixed(2)} ha';
    }
    return '${sqm.toStringAsFixed(0)} m²';
  }

  static String formatLeaseRate(double usdPerSqmPerMonth) {
    return '\$${usdPerSqmPerMonth.toStringAsFixed(2)}/m²/tháng';
  }
}
