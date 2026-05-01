// أنواع الفشل — تُستخدم مع Either<Failure, T> في طبقة المستودعات
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'خطأ في الخادم']);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure([super.message = 'خطأ في الاتصال بالإنترنت']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'خطأ في المصادقة']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'خطأ في التخزين المحلي']);
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;
  const ValidationFailure([super.message = 'خطأ في البيانات المدخلة', this.errors]);

  @override
  List<Object> get props => [message, errors ?? {}];
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'حدث خطأ غير متوقع']);
}
