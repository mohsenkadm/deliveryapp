import '../constants/api_constants.dart';

/// يبني رابط صورة كامل من مسار نسبي أو مطلق.
/// مثال: `/uploads/customers/x.jpg` → `{baseUrl}/uploads/customers/x.jpg`
String? resolveMediaUrl(String? path) {
  if (path == null) return null;
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = ApiConstants.baseUrl; // ignore: prefer_const_declarations — baseUrl may change per env
  if (trimmed.startsWith('/')) return '$base$trimmed';
  return '$base/$trimmed';
}
