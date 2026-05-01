// واجهة مستودع المصادقة — طبقة المجال
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> loginCustomer({required String username, required String password});
  Future<Either<Failure, User>> loginDriver({required String username, required String password});
  Future<Either<Failure, User>> loginRepresentative({required String username, required String password});
  Future<Either<Failure, User>> loginAdmin({required String username, required String password});
  /// تسجيل دخول موحّد للموظفين (سائق/مندوب/مشرف/مدير مبيعات/أدمن)
  Future<Either<Failure, User>> loginEmployee({required String username, required String password});
  Future<Either<Failure, void>> registerCustomer({
    required String fullName,
    required String username,
    required String password,
    required String phone,
    required String address,
    String? representativeId,
  });
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, void>> changePassword({required String oldPassword, required String newPassword});
  Future<void> logout();
}
