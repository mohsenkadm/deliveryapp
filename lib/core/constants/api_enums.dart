// Enums مرجعية تطابق الأنواع المعرّفة على جانب الخادم في DeliverySystem.API.
// أرقام InvoiceStatus تُستمد من InvoiceStatusHelper — المصدر الوحيد للترتيب.

import '../utils/helpers.dart';

/// حالة الفاتورة — أسماء نصية (الأرقام عبر [InvoiceStatusHelper.toInt]).
class InvoiceStatus {
  InvoiceStatus._();

  static const String pending = 'Pending'; // 0
  static const String deferred = 'Deferred'; // 1
  static const String awaitingDelivery = 'AwaitingDelivery'; // 2
  static const String completed = 'Completed'; // 3
  static const String rejected = 'Rejected'; // 4
  static const String accepted = 'Accepted'; // 5
  static const String warehouseProcessing = 'WarehouseProcessing'; // 6
  static const String delivered = 'Delivered'; // 7

  static const List<String> all = [
    pending,
    deferred,
    awaitingDelivery,
    completed,
    rejected,
    accepted,
    warehouseProcessing,
    delivered,
  ];

  static int? toInt(String status) => InvoiceStatusHelper.toInt(status);

  static String labelAr(String status) =>
      InvoiceStatusHelper.label(status);
}

/// حالة الدفع — PaymentStatus enum على الخادم.
class PaymentStatus {
  PaymentStatus._();

  static const int unpaid = 0;
  static const int partialPaid = 1;
  static const int fullPaid = 2;

  static const List<String> labels = ['Unpaid', 'PartialPaid', 'FullPaid'];

  static String fromInt(int? value) {
    if (value == null || value < 0 || value >= labels.length) {
      return 'Unpaid';
    }
    return labels[value];
  }

  static String labelAr(int? value) {
    switch (value) {
      case partialPaid:
        return 'مدفوع جزئياً';
      case fullPaid:
        return 'مدفوع بالكامل';
      default:
        return 'غير مدفوع';
    }
  }
}

/// نوع الدفعة — PaymentType enum (int على الخادم).
class PaymentType {
  PaymentType._();

  static const int customerToDriver = 0;
  static const int customerToRepresentative = 1;
  static const int driverToCompany = 2;
  static const int representativeToCompany = 3;
}

/// نوع أمر النقل بين المستودعات
class TransferOrderType {
  TransferOrderType._();

  static const int outboundToRepWarehouse = 0;
  static const int returnToMainWarehouse = 1;
}

/// حالة أمر النقل — TransferOrderStatus enum على الخادم.
class TransferOrderStatus {
  TransferOrderStatus._();

  static const int pending = 0;
  static const int accountantApproved = 1;
  static const int warehouseProcessing = 2;
  static const int completed = 3;
  static const int rejected = 4;
  static const int returnPending = 5;
  static const int returnApproved = 6;
  static const int returnCompleted = 7;
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
  static const int customer = 0;
  static const int representative = 1;
}
