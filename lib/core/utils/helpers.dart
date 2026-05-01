import 'package:flutter/material.dart';

/// قيم حالة الفاتورة (InvoiceStatus enum مطابق للباك-إند)
class InvoiceStatusHelper {
  InvoiceStatusHelper._();

  static const Map<String, String> _arabicLabels = {
    'Pending': 'معلق',
    'Accepted': 'مقبول',
    'WarehouseProcessing': 'جاري التجهيز',
    'AwaitingDelivery': 'في التوصيل',
    'Delivered': 'تم التسليم',
    'Completed': 'مكتمل',
    'Rejected': 'مرفوض',
    'Deferred': 'مؤجل',
  };

  static const Map<String, Color> _colors = {
    'Pending': Color(0xFFF59E0B),
    'Accepted': Color(0xFF3B82F6),
    'WarehouseProcessing': Color(0xFF8B5CF6),
    'AwaitingDelivery': Color(0xFF0EA5E9),
    'Delivered': Color(0xFF22C55E),
    'Completed': Color(0xFF059669),
    'Rejected': Color(0xFFDC2626),
    'Deferred': Color(0xFF9CA3AF),
  };

  /// ترتيب الخطوات للمخطط الزمني
  static const List<String> timeline = [
    'Pending',
    'Accepted',
    'WarehouseProcessing',
    'AwaitingDelivery',
    'Delivered',
    'Completed',
  ];

  static String label(String status) =>
      _arabicLabels[status] ?? status;

  static Color color(String status) =>
      _colors[status] ?? const Color(0xFF6B7280);

  /// هل الحالة حالة إيقاف (رفض/تأجيل)؟
  static bool isTerminal(String status) =>
      status == 'Rejected' || status == 'Deferred';

  /// فهرس الحالة في المخطط الزمني (-1 إذا لم تكن ضمن السلسلة)
  static int timelineIndex(String status) => timeline.indexOf(status);
}

class Helpers {
  Helpers._();

  static Color getStatusColor(String status) {
    return InvoiceStatusHelper.color(status);
  }

  static String getStatusText(String status) {
    return InvoiceStatusHelper.label(status);
  }

  static IconData getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return Icons.person;
      case 'driver':
        return Icons.local_shipping;
      case 'representative':
        return Icons.support_agent;
      case 'supervisor':
        return Icons.supervisor_account;
      case 'salesmanager':
      case 'sales_manager':
        return Icons.bar_chart;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  static String getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return 'عميل';
      case 'driver':
        return 'سائق';
      case 'representative':
        return 'مندوب';
      case 'supervisor':
        return 'مشرف';
      case 'salesmanager':
      case 'sales_manager':
        return 'مدير مبيعات';
      case 'admin':
        return 'مدير';
      default:
        return role;
    }
  }
}
