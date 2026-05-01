// استثناءات طبقة البيانات — الخادم، التخزين، المصادقة
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'خطأ في الخادم']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'خطأ في التخزين المحلي']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'خطأ في المصادقة']);
}
