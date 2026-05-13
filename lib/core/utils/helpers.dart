import 'package:flutter/material.dart';

/// قيم حالة الفاتورة (InvoiceStatus enum مطابق للباك-إند)
class InvoiceStatusHelper {
  InvoiceStatusHelper._();

  /// التسمية العربية الأساسية لكل حالة — مطابقة لِما يعيده الباك-إند في `statusText`.
  static const Map<String, String> _arabicLabels = {
    'Pending': 'قيد الانتظار',
    'Accepted': 'مقبولة',
    'WarehouseProcessing': 'قيد التجهيز في المستودع',
    'AwaitingDelivery': 'في انتظار التوصيل',
    'Delivered': 'تم التسليم',
    'Completed': 'مكتملة',
    'Rejected': 'مرفوضة',
    'Deferred': 'مؤجلة',
  };

  /// أسماء عربية بديلة شائعة (من الواجهة القديمة أو ردود مختلفة) — للمطابقة العكسية.
  static const Map<String, String> _arabicAliases = {
    'معلق': 'Pending',
    'معلقة': 'Pending',
    'قيد الانتظار': 'Pending',
    'مقبول': 'Accepted',
    'مقبولة': 'Accepted',
    'جاري التجهيز': 'WarehouseProcessing',
    'قيد التجهيز': 'WarehouseProcessing',
    'قيد التجهيز في المستودع': 'WarehouseProcessing',
    'في التوصيل': 'AwaitingDelivery',
    'في انتظار التوصيل': 'AwaitingDelivery',
    'انتظار التوصيل': 'AwaitingDelivery',
    'تم التسليم': 'Delivered',
    'تم التوصيل': 'Delivered',
    'مكتمل': 'Completed',
    'مكتملة': 'Completed',
    'مرفوض': 'Rejected',
    'مرفوضة': 'Rejected',
    'مؤجل': 'Deferred',
    'مؤجلة': 'Deferred',
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

  /// تحويل قيمة الحالة القادمة من الباك-إند (int enum أو نص) إلى نص موحَّد.
  /// ترتيب enum InvoiceStatus في الباك-إند (مطابق لما يعيده الخادم):
  ///   0=Pending, 1=Deferred, 2=AwaitingDelivery, 3=Completed,
  ///   4=Rejected, 5=Accepted, 6=WarehouseProcessing, 7=Delivered
  static const List<String> _enumOrder = [
    'Pending',           // 0
    'Deferred',          // 1
    'AwaitingDelivery',  // 2
    'Completed',         // 3
    'Rejected',          // 4
    'Accepted',          // 5
    'WarehouseProcessing', // 6
    'Delivered',         // 7
  ];

  /// تحويل المفتاح الإنجليزي إلى الرقم في جسم `PATCH /api/mobile/driver/orders/{id}/status`
  /// (أو تحديثات الحالة الموحَّدة الأخرى التي تستخدم نفس ترتيب الـ enum).
  static int? toInt(String status) {
    final i = _enumOrder.indexOf(status);
    return i < 0 ? null : i;
  }

  static String parse(dynamic value, {String fallback = 'Pending'}) {
    if (value == null) return fallback;
    final s = value.toString().trim();
    if (s.isEmpty) return fallback;
    // نص إنجليزي مطابق للـ enum
    if (_enumOrder.contains(s)) return s;
    // نص عربي قادم من statusText — نعكس الخريطة الأساسية ثم البدائل
    for (final entry in _arabicLabels.entries) {
      if (entry.value == s) return entry.key;
    }
    if (_arabicAliases.containsKey(s)) return _arabicAliases[s]!;
    // كحلٍّ أخير: قيمة رقمية. ترتيب enum الباك-إند قد يختلف عن ترتيبنا،
    // لذا لا نعتمد عليه إلا عند غياب statusText تماماً.
    final asInt = value is int ? value : int.tryParse(s);
    if (asInt != null && asInt >= 0 && asInt < _enumOrder.length) {
      return _enumOrder[asInt];
    }
    return fallback;
  }

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
