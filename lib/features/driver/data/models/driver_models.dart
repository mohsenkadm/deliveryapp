// نماذج بيانات السائق — طلبات التوصيل وملخص الأداء
import '../../domain/entities/driver_entities.dart';

class DeliveryOrderModel extends DeliveryOrder {
  const DeliveryOrderModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.customerName,
    required super.customerPhone,
    required super.customerAddress,
    super.customerRegion,
    super.storeName,
    super.latitude,
    super.longitude,
    super.googleMapsUrl,
    required super.totalAmount,
    required super.createdAt,
    super.notes,
    super.items,
  });

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>? ?? json;
    return DeliveryOrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber:
          json['invoiceNumber'] ?? json['orderNumber'] ?? '',
      status: json['status'] ?? '',
      customerName: customer['fullName'] ?? customer['customerName'] ?? '',
      customerPhone: customer['phone'] ?? customer['customerPhone'] ?? '',
      customerAddress: customer['address'] ?? customer['customerAddress'] ?? '',
      customerRegion: customer['region'],
      storeName: customer['storeName'],
      latitude: (customer['latitude'] ?? json['latitude'])?.toDouble(),
      longitude: (customer['longitude'] ?? json['longitude'])?.toDouble(),
      googleMapsUrl:
          customer['googleMapsUrl'] ?? json['googleMapsUrl'],
      totalAmount: (json['totalAmount'] ?? json['total'] ?? 0).toDouble(),
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      notes: json['notes'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => DeliveryOrderItemModel.fromJson(e))
          .toList(),
    );
  }
}

class DeliveryOrderItemModel extends DeliveryOrderItem {
  const DeliveryOrderItemModel({
    required super.productName,
    required super.quantity,
    required super.price,
  });

  factory DeliveryOrderItemModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderItemModel(
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? json['unitPrice'] ?? 0).toDouble(),
    );
  }
}

class DriverSummaryModel extends DriverSummary {
  const DriverSummaryModel({
    required super.totalAssigned,
    required super.completed,
    required super.awaitingDelivery,
    required super.rejected,
    required super.completionRate,
  });

  factory DriverSummaryModel.fromJson(Map<String, dynamic> json) {
    return DriverSummaryModel(
      totalAssigned: json['totalAssigned'] ?? 0,
      completed: json['completed'] ?? 0,
      awaitingDelivery: json['awaitingDelivery'] ?? 0,
      rejected: json['rejected'] ?? 0,
      completionRate: (json['completionRate'] ?? 0).toDouble(),
    );
  }
}
