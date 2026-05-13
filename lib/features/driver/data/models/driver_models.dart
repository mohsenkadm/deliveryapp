// نماذج بيانات السائق — طلبات التوصيل وملخص الأداء
import '../../../../core/utils/helpers.dart';
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
    super.paidAmount,
    super.remainingAmount,
    super.paymentStatus,
    required super.createdAt,
    super.notes,
    super.items,
  });

  static const List<String> _paymentStatuses = ['Unpaid', 'Partial', 'Paid'];

  static String? _enumStr(dynamic v, List<String> values) {
    if (v == null) return null;
    if (v is int && v >= 0 && v < values.length) return values[v];
    final s = v.toString();
    final i = int.tryParse(s);
    if (i != null && i >= 0 && i < values.length) return values[i];
    return s;
  }

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>? ?? json;
    final detailsList =
        (json['details'] ?? json['items']) as List<dynamic>? ?? const [];
    return DeliveryOrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber:
          json['invoiceNumber'] ?? json['orderNumber'] ?? '',
      status: InvoiceStatusHelper.parse(json['statusText'] ?? json['status'], fallback: ''),
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
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      paymentStatus: _enumStr(
          json['paymentStatus'] ?? json['paymentStatusText'], _paymentStatuses),
      createdAt: DateTime.tryParse(
              (json['createdAt'] ?? json['orderDate'] ?? '').toString()) ??
          DateTime.now(),
      notes: json['notes'],
      items: detailsList
          .map((e) => DeliveryOrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DeliveryOrderItemModel extends DeliveryOrderItem {
  const DeliveryOrderItemModel({
    required super.productName,
    required super.quantity,
    required super.price,
    super.discount,
    super.subTotal,
  });

  factory DeliveryOrderItemModel.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] ?? 0) as num;
    final unit = (json['unitPrice'] ?? json['price'] ?? 0).toDouble();
    final discount = (json['discount'] ?? 0).toDouble();
    final sub = (json['subTotal'] ?? json['subtotal'] ?? json['total'] ?? (unit * qty - discount))
        .toDouble();
    return DeliveryOrderItemModel(
      productName: json['productName'] ?? '',
      quantity: qty.toInt(),
      price: unit,
      discount: discount,
      subTotal: sub,
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
