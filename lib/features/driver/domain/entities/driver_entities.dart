import 'package:equatable/equatable.dart';

class DeliveryOrder extends Equatable {
  final String id;
  final String orderNumber;
  final String status;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String? customerRegion;
  final String? storeName;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUrl;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String? paymentStatus; // 'Unpaid' | 'Partial' | 'Paid'
  final DateTime createdAt;
  final String? notes;
  final List<DeliveryOrderItem> items;

  const DeliveryOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    this.customerRegion,
    this.storeName,
    this.latitude,
    this.longitude,
    this.googleMapsUrl,
    required this.totalAmount,
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.paymentStatus,
    required this.createdAt,
    this.notes,
    this.items = const [],
  });

  @override
  List<Object?> get props => [id];
}

class DeliveryOrderItem extends Equatable {
  final String productName;
  final int quantity;
  final double price;
  final double discount;
  final double subTotal;

  const DeliveryOrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
    this.discount = 0,
    this.subTotal = 0,
  });

  @override
  List<Object?> get props => [productName, quantity];
}

/// ملخص أداء السائق من /api/mobile/driver/summary
class DriverSummary extends Equatable {
  final int totalAssigned;
  final int completed;
  final int awaitingDelivery;
  final int rejected;
  final double completionRate;

  const DriverSummary({
    required this.totalAssigned,
    required this.completed,
    required this.awaitingDelivery,
    required this.rejected,
    required this.completionRate,
  });

  @override
  List<Object?> get props =>
      [totalAssigned, completed, awaitingDelivery, rejected, completionRate];
}
