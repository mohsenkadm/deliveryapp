// Enums مرجعية تطابق الأنواع المعرّفة على جانب الخادم في DeliverySystem.API.
// تُستخدم لقراءة القيم من الردود وإرسالها في الطلبات.

/// حالة الفاتورة — نسخة مطابقة لـ `InvoiceStatus`
class InvoiceStatus {
  InvoiceStatus._();

  static const String pending = 'Pending';                   // 0 — معلق
  static const String accepted = 'Accepted';                 // 1 — مقبول
  static const String warehouseProcessing = 'WarehouseProcessing'; // 2 — جاري التجهيز
  static const String awaitingDelivery = 'AwaitingDelivery'; // 3 — في التوصيل
  static const String delivered = 'Delivered';               // 4 — تم التسليم
  static const String completed = 'Completed';               // 5 — مكتمل
  static const String rejected = 'Rejected';                 // 6 — مرفوض
  static const String deferred = 'Deferred';                 // 7 — مؤجل

  static const List<String> all = [
    pending,
    accepted,
    warehouseProcessing,
    awaitingDelivery,
    delivered,
    completed,
    rejected,
    deferred,
  ];

  /// تسمية عربية مختصرة
  static String labelAr(String status) {
    switch (status) {
      case pending:
        return 'معلق';
      case accepted:
        return 'مقبول';
      case warehouseProcessing:
        return 'جاري التجهيز';
      case awaitingDelivery:
        return 'في التوصيل';
      case delivered:
        return 'تم التسليم';
      case completed:
        return 'مكتمل';
      case rejected:
        return 'مرفوض';
      case deferred:
        return 'مؤجل';
      default:
        return status;
    }
  }
}

/// نوع الدفعة
class PaymentType {
  PaymentType._();
  static const String customerToRepresentative = 'CustomerToRepresentative';
  static const String customerToDriver = 'CustomerToDriver';
  static const String representativeToCompany = 'RepresentativeToCompany';
  static const String driverToCompany = 'DriverToCompany';
}

/// نوع أمر النقل بين المستودعات
class TransferOrderType {
  TransferOrderType._();
  static const String outboundToRepWarehouse = 'OutboundToRepWarehouse';
  static const String returnToMainWarehouse = 'ReturnToMainWarehouse';
}

/// حالة أمر النقل
class TransferOrderStatus {
  TransferOrderStatus._();
  static const String pending = 'Pending';
  static const String approved = 'Approved';
  static const String rejected = 'Rejected';
  static const String completed = 'Completed';
}

/// الجهة المستهدفة من الإشعار
class NotificationTarget {
  NotificationTarget._();
  static const String admin = 'Admin';
  static const String salesManager = 'SalesManager';
  static const String supervisor = 'Supervisor';
  static const String driver = 'Driver';
  static const String representative = 'Representative';
  static const String customer = 'Customer';
  static const String employee = 'Employee';
}

/// مصدر الفاتورة
class InvoiceSource {
  InvoiceSource._();
  static const String customer = 'Customer';
  static const String representative = 'Representative';
  static const String admin = 'Admin';
}
