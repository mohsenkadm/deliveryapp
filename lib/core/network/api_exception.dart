// استثناءات API — أنواع الأخطاء الممكنة من الخادم
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
      : super(message: message ?? 'غير مصرح لك بالدخول', statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException({String? message})
      : super(message: message ?? 'غير موجود', statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({String? message})
      : super(message: message ?? 'خطأ في الخادم', statusCode: 500);
}

class ConnectionException extends ApiException {
  ConnectionException({String? message})
      : super(message: message ?? 'خطأ في الاتصال بالإنترنت');
}
