/// سطر تفاصيل أمر النقل
class TransferOrderDetailDto {
  final int productId;
  final String productName;
  final int requestedQuantity;
  final int? approvedQuantity;

  const TransferOrderDetailDto({
    required this.productId,
    required this.productName,
    required this.requestedQuantity,
    this.approvedQuantity,
  });

  factory TransferOrderDetailDto.fromJson(Map<String, dynamic> json) {
    int i(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    return TransferOrderDetailDto(
      productId: i(json['productId']),
      productName: (json['productName'] ?? '').toString(),
      requestedQuantity: i(json['requestedQuantity']),
      approvedQuantity: json['approvedQuantity'] != null
          ? i(json['approvedQuantity'])
          : null,
    );
  }
}

/// أمر نقل — TransferOrderDto
class TransferOrderDto {
  final int id;
  final String orderNumber;
  final int fromWarehouseId;
  final String fromWarehouseName;
  final int toWarehouseId;
  final String toWarehouseName;
  final int? requestedByEmployeeId;
  final int status;
  final int orderType;
  final String statusText;
  final String orderTypeText;
  final String? notes;
  final DateTime? requestedAt;
  final List<TransferOrderDetailDto> details;

  const TransferOrderDto({
    required this.id,
    required this.orderNumber,
    required this.fromWarehouseId,
    required this.fromWarehouseName,
    required this.toWarehouseId,
    required this.toWarehouseName,
    this.requestedByEmployeeId,
    required this.status,
    required this.orderType,
    required this.statusText,
    required this.orderTypeText,
    this.notes,
    this.requestedAt,
    this.details = const [],
  });

  factory TransferOrderDto.fromJson(Map<String, dynamic> json) {
    int i(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    final rawDetails = json['details'];
    final details = <TransferOrderDetailDto>[];
    if (rawDetails is List) {
      for (final e in rawDetails) {
        if (e is Map) {
          details.add(TransferOrderDetailDto.fromJson(
              Map<String, dynamic>.from(e)));
        }
      }
    }
    return TransferOrderDto(
      id: i(json['id']),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      fromWarehouseId: i(json['fromWarehouseId']),
      fromWarehouseName: (json['fromWarehouseName'] ?? '').toString(),
      toWarehouseId: i(json['toWarehouseId']),
      toWarehouseName: (json['toWarehouseName'] ?? '').toString(),
      requestedByEmployeeId: json['requestedByEmployeeId'] != null
          ? i(json['requestedByEmployeeId'])
          : null,
      status: i(json['status']),
      orderType: i(json['orderType']),
      statusText: (json['statusText'] ?? '').toString(),
      orderTypeText: (json['orderTypeText'] ?? '').toString(),
      notes: json['notes']?.toString(),
      requestedAt:
          DateTime.tryParse((json['requestedAt'] ?? '').toString()),
      details: details,
    );
  }
}
