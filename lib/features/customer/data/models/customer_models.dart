// نماذج بيانات العميل — المنتجات، التصنيفات، الطلبات، الديون
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
    super.deliveryFee,
    super.notes,
    required super.createdAt,
    super.items,
    super.driverName,
    super.customerName,
    super.customerAddress,
    super.customerPhone,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber'] ?? json['invoiceNumber'] ?? '',
      status: json['status'] ?? 'Pending',
      totalAmount: (json['totalAmount'] ?? json['total'] ?? 0).toDouble(),
      deliveryFee: json['deliveryFee']?.toDouble(),
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e))
              .toList() ??
          [],
      driverName: json['driverName'],
      customerName: json['customerName'],
      customerAddress: json['customerAddress'],
      customerPhone: json['customerPhone'],
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
      productId: json['productId']?.toString() ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? json['unitPrice'] ?? 0).toDouble(),
      total: (json['total'] ?? json['subtotal'] ?? 0).toDouble(),
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
      status: json['status'] ?? '',
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