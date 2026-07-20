/// يستخرج سعر الوحدة من ردّ المنتج — يفضّل `unitPrice` الذي يحدده الخادم
/// حسب نوع المندوب/العميل (جملة أو مفرد).
///
/// عند غياب `unitPrice` من السيرفر:
/// - مندوب جملة → `wholesalePrice`
/// - مندوب مفرد / عميل مفرد → `retailPrice`
double resolveUnitPrice(
  Map<String, dynamic> json, {
  bool preferWholesale = false,
}) {
  final unit = json['unitPrice'];
  if (unit is num && unit > 0) return unit.toDouble();
  final parsed = double.tryParse(unit?.toString() ?? '');
  if (parsed != null && parsed > 0) return parsed;

  final keys = preferWholesale
      ? const [
          'wholesalePrice',
          'bulkPrice',
          'tradePrice',
          'wholesaleUnitPrice',
        ]
      : const [
          'retailPrice',
          'price',
          'salePrice',
        ];

  for (final key in keys) {
    final v = json[key];
    if (v is num && v > 0) return v.toDouble();
    final d = double.tryParse(v?.toString() ?? '');
    if (d != null && d > 0) return d;
  }

  final nested = json['product'];
  if (nested is Map) {
    return resolveUnitPrice(
      Map<String, dynamic>.from(nested),
      preferWholesale: preferWholesale,
    );
  }

  return 0;
}
