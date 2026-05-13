import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String? imageUrl;
  final String categoryId;
  final String? categoryName;
  final int stockQuantity;
  final bool isAvailable;
  // حقول إضافية من API
  final String? code;
  final double? wholesalePrice;
  final double? discountPercentage;
  final String? cartonType;
  final int? baseQuantity;
  // حقول انتهاء الصلاحية
  final DateTime? expirationDate;
  final bool isNearExpiry;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    this.imageUrl,
    required this.categoryId,
    this.categoryName,
    this.stockQuantity = 0,
    this.isAvailable = true,
    this.code,
    this.wholesalePrice,
    this.discountPercentage,
    this.cartonType,
    this.baseQuantity,
    this.expirationDate,
    this.isNearExpiry = false,
  });

  @override
  List<Object?> get props => [id];
}

class Category extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final int productCount;

  const Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.productCount = 0,
  });

  @override
  List<Object?> get props => [id];
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => (product.discountPrice ?? product.price) * quantity;
}

class Order extends Equatable {
  final String id;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String? paymentStatus; // 'Unpaid' | 'Partial' | 'Paid'
  final double? deliveryFee;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItem> items;
  final String? driverName;
  final String? customerName;
  final String? customerAddress;
  final String? customerPhone;
  // جدولة التسليم
  final String? deliveryScheduleType; // 'Immediate' | 'Scheduled'
  final DateTime? scheduledDeliveryDate;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.paymentStatus,
    this.deliveryFee,
    this.notes,
    required this.createdAt,
    this.items = const [],
    this.driverName,
    this.customerName,
    this.customerAddress,
    this.customerPhone,
    this.deliveryScheduleType,
    this.scheduledDeliveryDate,
  });

  @override
  List<Object?> get props => [id];
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double discount;
  final double total;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.discount = 0,
    required this.total,
  });
}

class Debt {
  final String id;
  final String invoiceNumber;
  final double amount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime dueDate;
  final String status;

  const Debt({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.dueDate,
    required this.status,
  });
}
