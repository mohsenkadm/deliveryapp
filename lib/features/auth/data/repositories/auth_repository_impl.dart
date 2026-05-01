// تنفيذ مستودع المصادقة — طبقة البيانات مع Either<Failure, T>
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import 'package:get/get.dart' hide Response;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, User>> loginCustomer({
    required String username,
    required String password,
  }) async {
    return _performLogin(
      () => _remoteDataSource.loginCustomer(
          LoginRequest(username: username, password: password)),
    );
  }

  /// تسجيل دخول الموظفين — يستخدم /api/admin/login لجميع الأدوار
  @override
  Future<Either<Failure, User>> loginDriver({
    required String username,
    required String password,
  }) async {
    return _performLogin(
      () => _remoteDataSource.loginEmployee(
          LoginRequest(username: username, password: password)),
    );
  }

  @override
  Future<Either<Failure, User>> loginRepresentative({
    required String username,
    required String password,
  }) async {
    return _performLogin(
      () => _remoteDataSource.loginEmployee(
          LoginRequest(username: username, password: password)),
    );
  }

  @override
  Future<Either<Failure, User>> loginAdmin({
    required String username,
    required String password,
  }) async {
    return _performLogin(
      () => _remoteDataSource.loginEmployee(
          LoginRequest(username: username, password: password)),
    );
  }

  @override
  Future<Either<Failure, User>> loginEmployee({
    required String username,
    required String password,
  }) async {
    return _performLogin(
      () => _remoteDataSource.loginEmployee(
          LoginRequest(username: username, password: password)),
    );
  }

  Future<Either<Failure, User>> _performLogin(
    Future<dynamic> Function() loginCall,
  ) async {
    try {
      final authResponse = await loginCall();
      final authService = Get.find<AuthService>();
      await authService.saveSession(
        token: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        role: authResponse.user.role,
        userId: authResponse.user.id,
        userName: authResponse.user.fullName,
      );
      return Right(authResponse.user);
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        return const Left(AuthFailure('اسم المستخدم أو كلمة المرور غير صحيحة'));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> registerCustomer({
    required String fullName,
    required String username,
    required String password,
    required String phone,
    required String address,
    String? representativeId,
  }) async {
    try {
      await _remoteDataSource.registerCustomer(RegisterRequest(
        fullName: fullName,
        username: username,
        password: password,
        phone: phone,
        address: address,
        representativeId: representativeId,
      ));
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final user = await _remoteDataSource.getCustomerProfile();
      return Right(user);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    final authService = Get.find<AuthService>();
    await authService.logout();
  }
}
