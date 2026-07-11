/// عميل المندوب — RepCustomerDto
class RepCustomerDto {
  final int id;
  final String fullName;
  final String? storeName;
  final String phone;
  final String address;
  final String? region;
  final String clientType;
  final bool isApproved;
  final double balance;

  const RepCustomerDto({
    required this.id,
    required this.fullName,
    this.storeName,
    required this.phone,
    required this.address,
    this.region,
    required this.clientType,
    required this.isApproved,
    required this.balance,
  });

  factory RepCustomerDto.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
    int i(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    return RepCustomerDto(
      id: i(json['id']),
      fullName: (json['fullName'] ?? '').toString(),
      storeName: json['storeName']?.toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      region: json['region']?.toString(),
      clientType: (json['clientType'] ?? 'Individual').toString(),
      isApproved: json['isApproved'] != false,
      balance: d(json['balance']),
    );
  }
}

/// نماذج بيانات المندوب — ذمة، مخازن النقل
class RepLiabilityDto {
  final double collectedFromCustomers;
  final double submittedToCompany;
  final double verifiedSubmitted;
  final double pendingLiability;
  final int pendingSettlementInvoiceCount;

  const RepLiabilityDto({
    required this.collectedFromCustomers,
    required this.submittedToCompany,
    required this.verifiedSubmitted,
    required this.pendingLiability,
    required this.pendingSettlementInvoiceCount,
  });

  factory RepLiabilityDto.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
    return RepLiabilityDto(
      collectedFromCustomers: d(json['collectedFromCustomers']),
      submittedToCompany: d(json['submittedToCompany']),
      verifiedSubmitted: d(json['verifiedSubmitted']),
      pendingLiability: d(json['pendingLiability']),
      pendingSettlementInvoiceCount:
          (json['pendingSettlementInvoiceCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class RepWarehouseOption {
  final int id;
  final String name;
  final bool isSubWarehouse;
  final int? branchId;

  const RepWarehouseOption({
    required this.id,
    required this.name,
    this.isSubWarehouse = false,
    this.branchId,
  });

  factory RepWarehouseOption.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    return RepWarehouseOption(
      id: id is int ? id : int.tryParse(id?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      isSubWarehouse: json['isSubWarehouse'] == true,
      branchId: (json['branchId'] as num?)?.toInt(),
    );
  }
}

class RepTransferWarehousesDto {
  final RepWarehouseOption? subWarehouse;
  final List<RepWarehouseOption> mainWarehouses;

  const RepTransferWarehousesDto({
    this.subWarehouse,
    this.mainWarehouses = const [],
  });

  factory RepTransferWarehousesDto.fromJson(Map<String, dynamic> json) {
    RepWarehouseOption? sub;
    final subRaw = json['subWarehouse'];
    if (subRaw is Map) {
      sub = RepWarehouseOption.fromJson(Map<String, dynamic>.from(subRaw));
    }
    final mainsRaw = json['mainWarehouses'];
    final mains = <RepWarehouseOption>[];
    if (mainsRaw is List) {
      for (final e in mainsRaw) {
        if (e is Map) {
          mains.add(RepWarehouseOption.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return RepTransferWarehousesDto(
      subWarehouse: sub,
      mainWarehouses: mains,
    );
  }
}
