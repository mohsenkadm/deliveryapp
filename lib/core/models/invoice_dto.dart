import '../utils/helpers.dart';

/// تفاصيل سطر فاتورة — InvoiceDetailDto
class InvoiceDetailDto {
  final int id;
  final int productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double discount;
  final double subTotal;

  const InvoiceDetailDto({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.subTotal,
  });

  factory InvoiceDetailDto.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
    int i(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    return InvoiceDetailDto(
      id: i(json['id']),
      productId: i(json['productId'] ?? json['product_id']),
      productName: (json['productName'] ?? json['product']?['name'] ?? '')
          .toString(),
      quantity: d(json['quantity']),
      unitPrice: d(json['unitPrice'] ?? json['price']),
      discount: d(json['discount']),
      subTotal: d(json['subTotal'] ?? json['subtotal'] ?? json['total']),
    );
  }
}

/// فاتورة كاملة — InvoiceDto
class InvoiceDto {
  final int id;
  final String invoiceNumber;
  final DateTime? orderDate;
  final int? customerId;
  final String customerName;
  final int? employeeId;
  final String? employeeName;
  final int? driverId;
  final String? driverName;
  final int? warehouseId;
  final String? warehouseName;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String status;
  final String statusText;
  final int? paymentStatus;
  final String? paymentStatusText;
  final List<InvoiceDetailDto> details;

  const InvoiceDto({
    required this.id,
    required this.invoiceNumber,
    this.orderDate,
    this.customerId,
    required this.customerName,
    this.employeeId,
    this.employeeName,
    this.driverId,
    this.driverName,
    this.warehouseId,
    this.warehouseName,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.statusText,
    this.paymentStatus,
    this.paymentStatusText,
    this.details = const [],
  });

  factory InvoiceDto.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
    int? i(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    final status = InvoiceStatusHelper.parse(
      json['statusText'] ?? json['status'],
      fallback: 'Pending',
    );
    final rawDetails = json['details'] ?? json['items'];
    final details = <InvoiceDetailDto>[];
    if (rawDetails is List) {
      for (final e in rawDetails) {
        if (e is Map) {
          details.add(
              InvoiceDetailDto.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    final total = d(json['totalAmount']);
    final paid = d(json['paidAmount']);
    final remaining = d(json['remainingAmount']);
    final rem = remaining > 0 ? remaining : (total - paid);

    return InvoiceDto(
      id: i(json['id']) ?? 0,
      invoiceNumber: (json['invoiceNumber'] ?? json['orderNumber'] ?? '')
          .toString(),
      orderDate: DateTime.tryParse(
          (json['orderDate'] ?? json['createdAt'] ?? '').toString()),
      customerId: i(json['customerId']),
      customerName: (json['customerName'] ??
              json['customer']?['fullName'] ??
              '')
          .toString(),
      employeeId: i(json['employeeId'] ?? json['salesRepresentativeId']),
      employeeName: (json['employeeName'] ??
              json['salesRepresentativeName'])
          ?.toString(),
      driverId: i(json['driverId']),
      driverName: json['driverName']?.toString(),
      warehouseId: i(json['warehouseId']),
      warehouseName: json['warehouseName']?.toString(),
      totalAmount: total,
      paidAmount: paid,
      remainingAmount: rem,
      status: status,
      statusText: (json['statusText'] ?? InvoiceStatusHelper.label(status))
          .toString(),
      paymentStatus: i(json['paymentStatus']),
      paymentStatusText: json['paymentStatusText']?.toString(),
      details: details,
    );
  }
}
