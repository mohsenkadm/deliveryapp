import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'ar',
      symbol: 'د.ع',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String number(num value) {
    final formatter = NumberFormat('#,##0', 'ar');
    return formatter.format(value);
  }

  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ar').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy hh:mm a', 'ar').format(date);
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} سنة';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} شهر';
    if (diff.inDays > 0) return '${diff.inDays} يوم';
    if (diff.inHours > 0) return '${diff.inHours} ساعة';
    if (diff.inMinutes > 0) return '${diff.inMinutes} دقيقة';
    return 'الآن';
  }

  // Convenience aliases used across the codebase
  static String formatCurrency(double amount) => currency(amount);
  static String formatDate(DateTime date) => Formatters.date(date);
  static String toApiDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);
}
