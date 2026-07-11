/// دفعة — PaymentDto
class PaymentDto {
  final int id;
  final int? invoiceId;
  final String? invoiceNumber;
  final int? customerId;
  final String? customerName;
  final int? paidByEmployeeId;
  final String? paidByEmployeeName;
  final int? receivedByEmployeeId;
  final String? receivedByEmployeeName;
  final double amount;
  final int type;
  final String? typeText;
  final String? notes;
  final bool isVerified;
  final DateTime? paidAt;

  const PaymentDto({
    required this.id,
    this.invoiceId,
    this.invoiceNumber,
    this.customerId,
    this.customerName,
    this.paidByEmployeeId,
    this.paidByEmployeeName,
    this.receivedByEmployeeId,
    this.receivedByEmployeeName,
    required this.amount,
    required this.type,
    this.typeText,
    this.notes,
    this.isVerified = false,
    this.paidAt,
  });

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
    int i(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    return PaymentDto(
      id: i(json['id']),
      invoiceId: json['invoiceId'] != null ? i(json['invoiceId']) : null,
      invoiceNumber: json['invoiceNumber']?.toString(),
      customerId:
          json['customerId'] != null ? i(json['customerId']) : null,
      customerName: json['customerName']?.toString(),
      paidByEmployeeId: json['paidByEmployeeId'] != null
          ? i(json['paidByEmployeeId'])
          : null,
      paidByEmployeeName: json['paidByEmployeeName']?.toString(),
      receivedByEmployeeId: json['receivedByEmployeeId'] != null
          ? i(json['receivedByEmployeeId'])
          : null,
      receivedByEmployeeName: json['receivedByEmployeeName']?.toString(),
      amount: d(json['amount']),
      type: i(json['type']),
      typeText: json['typeText']?.toString(),
      notes: json['notes']?.toString(),
      isVerified: json['isVerified'] == true,
      paidAt: DateTime.tryParse((json['paidAt'] ?? '').toString()),
    );
  }
}
