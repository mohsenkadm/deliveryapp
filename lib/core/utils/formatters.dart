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

  /// تاريخ فاتورة للطباعة — yyyy/MM/dd أو yyyy/MM/dd HH:mm
  static String invoicePrintDate(DateTime date, {bool withTime = false}) {
    if (withTime) {
      return DateFormat('yyyy/MM/dd HH:mm').format(date);
    }
    return DateFormat('yyyy/MM/dd').format(date);
  }

  /// يحاول قراءة orderDate ثم createdAt ويعيد نص طباعة واضح.
  static String invoicePrintDateFromRaw(dynamic orderDate, dynamic createdAt) {
    final raw = orderDate ?? createdAt;
    if (raw == null) return '-';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) {
      final s = raw.toString();
      return s.length >= 10 ? s.substring(0, 10).replaceAll('-', '/') : s;
    }
    final hasTime = raw.toString().contains('T') ||
        RegExp(r'\d{2}:\d{2}').hasMatch(raw.toString());
    return invoicePrintDate(parsed, withTime: hasTime);
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
