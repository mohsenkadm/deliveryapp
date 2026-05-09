// نماذج بيانات العميل — المنتجات، التصنيفات، الطلبات، الديون
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/customer_entities.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    super.discountPrice,
    super.imageUrl,
    required super.categoryId,
    super.categoryName,
    super.stockQuantity,
    super.isAvailable,
    super.code,
    super.wholesalePrice,
    super.discountPercentage,
    super.cartonType,
    super.baseQuantity,
    super.expirationDate,
    super.isNearExpiry,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final retailPrice = (json['retailPrice'] ?? json['price'] ?? 0).toDouble();
    final discount = (json['discountPercentage'] ?? 0).toDouble();
    final discountPrice =
        discount > 0 ? retailPrice * (1 - discount / 100) : null;

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: retailPrice,
      discountPrice: discountPrice,
      imageUrl: json['imagePath'] ?? json['imageUrl'] ?? json['image'],
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName'],
      stockQuantity: json['totalStock'] ?? json['stockQuantity'] ?? 0,
      isAvailable: json['isInStock'] ?? json['isAvailable'] ?? true,
      code: json['code'],
      wholesalePrice: (json['wholesalePrice'] ?? 0).toDouble(),
      discountPercentage: discount,
      cartonType: json['cartonType'],
      baseQuantity: json['baseQuantity'] ?? 1,
      expirationDate: json['expirationDate'] != null
          ? DateTime.tryParse(json['expirationDate'].toString())
          : null,
      isNearExpiry: json['isNearExpiry'] ?? false,
    );
  }
}

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.productCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'],
      productCount: json['productCount'] ?? 0,
    );
  }
}

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.totalAmount,
    super.paidAmount,
    super.remainingAmount,
    super.paymentStatus,
    super.deliveryFee,
    super.notes,
    required super.createdAt,
    super.items,
    super.driverName,
    super.customerName,
    super.customerAddress,
    super.customerPhone,
    super.deliveryScheduleType,
    super.scheduledDeliveryDate,
  });

  static const List<String> _scheduleTypes = ['Immediate', 'Scheduled'];
  static const List<String> _paymentStatuses = ['Unpaid', 'Partial', 'Paid'];

  static String? _enumStr(dynamic v, List<String> values) {
    if (v == null) return null;
    if (v is int && v >= 0 && v < values.length) return values[v];
    final s = v.toString();
    final i = int.tryParse(s);
    if (i != null && i >= 0 && i < values.length) return values[i];
    return s;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber'] ?? json['invoiceNumber'] ?? '',
      status: InvoiceStatusHelper.parse(json['status'] ?? json['statusText']),
      totalAmount: (json['totalAmount'] ?? json['total'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      paymentStatus:
          _enumStr(json['paymentStatus'] ?? json['paymentStatusText'], _paymentStatuses),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      notes: json['notes'],
      createdAt: DateTime.tryParse(
              (json['createdAt'] ?? json['orderDate'] ?? '').toString()) ??
          DateTime.now(),
      items: ((json['items'] ?? json['details']) as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      driverName: json['driverName'],
      customerName: json['customerName'],
      customerAddress: json['customerAddress'],
      customerPhone: json['customerPhone'],
      deliveryScheduleType:
          _enumStr(json['deliveryScheduleType'], _scheduleTypes),
      scheduledDeliveryDate: json['scheduledDeliveryDate'] != null
          ? DateTime.tryParse(json['scheduledDeliveryDate'].toString())
          : null,
    );
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.price,
    required super.total,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: (json['productId'] ?? json['id'])?.toString() ?? '',
      productName: json['productName'] ?? json['name'] ?? '',
      quantity: (json['quantity'] ?? json['qty'] ?? 0) as int,
      price: (json['price'] ?? json['unitPrice'] ?? 0).toDouble(),
      total: (json['total'] ?? json['subtotal'] ?? json['lineTotal'] ?? 0).toDouble(),
    );
  }
}

/// ملخص الديون من /api/mobile/customer/debts
class DebtSummaryModel {
  final double totalDebt;
  final double totalPaid;
  final int totalInvoices;
  final int unpaidInvoices;
  final int pendingInvoices;
  final List<DebtModel> invoices;

  DebtSummaryModel({
    required this.totalDebt,
    required this.totalPaid,
    required this.totalInvoices,
    required this.unpaidInvoices,
    required this.pendingInvoices,
    required this.invoices,
  });

  factory DebtSummaryModel.fromJson(Map<String, dynamic> json) {
    return DebtSummaryModel(
      totalDebt: (json['totalDebt'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      totalInvoices: json['totalInvoices'] ?? 0,
      unpaidInvoices: json['unpaidInvoices'] ?? 0,
      pendingInvoices: json['pendingInvoices'] ?? 0,
      invoices: (json['invoices'] as List<dynamic>? ?? [])
          .map((e) => DebtModel.fromJson(e))
          .toList(),
    );
  }
}

class DebtModel extends Debt {
  const DebtModel({
    required super.id,
    required super.invoiceNumber,
    required super.amount,
    required super.paidAmount,
    required super.remainingAmount,
    required super.dueDate,
    required super.status,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      amount: (json['amount'] ?? json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),
      status: InvoiceStatusHelper.parse(json['status'] ?? json['statusText'], fallback: ''),
    );
  }
}

/// نموذج الإشعار
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}