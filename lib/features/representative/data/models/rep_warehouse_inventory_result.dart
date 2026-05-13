// نتيجة GET مخزون المندوب — عناصر + معرفات المستودعات إن وُجدت في الرد
class RepWarehouseInventoryResult {
  final List<Map<String, dynamic>> items;
  final int? mainWarehouseId;
  final int? subWarehouseId;

  const RepWarehouseInventoryResult({
    required this.items,
    this.mainWarehouseId,
    this.subWarehouseId,
  });

  static int? _parseId(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  /// استنتاج معرف المستودع من أول بند (عند غياب الحقول في الجذر).
  int? warehouseIdFromFirstItem() {
    if (items.isEmpty) return null;
    final row = items.first;
    return _parseId(row['warehouseId'] ??
        row['warehouseID'] ??
        row['fromWarehouseId'] ??
        row['toWarehouseId']);
  }

  factory RepWarehouseInventoryResult.fromResponse(
    dynamic responseRoot, {
    required bool fromMainWarehouse,
  }) {
    if (responseRoot is! Map) {
      return const RepWarehouseInventoryResult(items: []);
    }
    final data = responseRoot['data'] ?? responseRoot;

    List<Map<String, dynamic>> items = const [];
    if (data is List) {
      items = data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else if (data is Map) {
      final raw = data['items'];
      if (raw is List) {
        items = raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

    int? mainId;
    int? subId;
    if (data is Map) {
      final mainNested = data['mainWarehouse'];
      final mainNestedId =
          mainNested is Map ? mainNested['id'] : null;
      mainId = _parseId(data['mainWarehouseId'] ??
          mainNestedId ??
          data['fromWarehouseId']);
      subId = _parseId(data['subWarehouseId'] ??
          data['representativeWarehouseId'] ??
          data['myWarehouseId'] ??
          data['toWarehouseId'] ??
          data['repWarehouseId']);
    }

    final inferred =
        items.isEmpty ? null : _parseIdFromRow(items.first);
    if (fromMainWarehouse) {
      mainId ??= inferred;
    } else {
      subId ??= inferred;
    }

    return RepWarehouseInventoryResult(
      items: items,
      mainWarehouseId: mainId,
      subWarehouseId: subId,
    );
  }

  static int? _parseIdFromRow(Map<String, dynamic> row) {
    return _parseId(row['warehouseId'] ?? row['warehouseID']);
  }
}
