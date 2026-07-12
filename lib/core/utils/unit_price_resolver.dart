/// يستخرج سعر الوحدة من ردّ المنتج — يفضّل `unitPrice` الذي يحدده الخادم
/// حسب نوع المندوب/العميل (جملة أو مفرد).
double resolveUnitPrice(Map<String, dynamic> json) {
  final unit = json['unitPrice'];
  if (unit is num && unit > 0) return unit.toDouble();
  final parsed = double.tryParse(unit?.toString() ?? '');
  if (parsed != null && parsed > 0) return parsed;

  // توافق مع ردود قديمة
  for (final key in [
    'retailPrice',
    'price',
    'salePrice',
    'wholesalePrice',
    'bulkPrice',
    'tradePrice',
    'wholesaleUnitPrice',
  ]) {
    final v = json[key];
    if (v is num && v > 0) return v.toDouble();
    final d = double.tryParse(v?.toString() ?? '');
    if (d != null && d > 0) return d;
  }

  final nested = json['product'];
  if (nested is Map) {
    return resolveUnitPrice(Map<String, dynamic>.from(nested));
  }

  return 0;
}
