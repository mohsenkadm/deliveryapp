// تنفيذ مستودع المصادقة — طبقة البيانات مع Either<Failure, T>
//
// متوافق مع DeliverySystem.API (3 نقاط دخول):
// - loginAdmin → /api/auth/admin     → UserKind.admin
// - loginCustomer → /api/auth/customer → UserKind.customer
// - loginEmployee → /api/auth/employee → UserKind.employee (قد يحمل عدة أدوار)
import 'package:dartz/dartz.dart';
import 'package:get/get.dart' hide Response;
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  // ── العميل ──
  @override
  Future<Either<Failure, User>> loginCustomer({
    required String username,
    required String password,
  }) =>
      _performLogin(
        UserKind.customer,
        () => _remoteDataSource.loginCustomer(
          LoginRequest(username: username, password: password),
        ),
      );

  // ── الأدمن ──
  @override
  Future<Either<Failure, User>> loginAdmin({
    required String username,
    required String password,
  }) =>
      _performLogin(
        UserKind.admin,
        () => _remoteDataSource.loginAdmin(
          LoginRequest(username: username, password: password),
        ),
      );

  // ── الموظفون (لكل تركيبات الأدوار) ──
  @override
  Future<Either<Failure, User>> loginEmployee({
    required String username,
    required String password,
  }) =>
      _performLogin(
        UserKind.employee,
        () => _remoteDataSource.loginEmployee(
          LoginRequest(username: username, password: password),
        ),
      );

  // أسماء قديمة محفوظة — جميعها تستخدم نفس نقطة دخول الموظف.
  @override
  Future<Either<Failure, User>> loginDriver({
    required String username,
    required String password,
  }) =>
      loginEmployee(username: username, password: password);

  @override
  Future<Either<Failure, User>> loginRepresentative({
    required String username,
    required String password,
  }) =>
      loginEmployee(username: username, password: password);

  Future<Either<Failure, User>> _performLogin(
    UserKind kind,
    Future<dynamic> Function() loginCall,
  ) async {
    try {
      final authResponse = await loginCall();
      final UserModel user = authResponse.user as UserModel;

      final authService = Get.find<AuthService>();
      await authService.saveSession(
        token: authResponse.accessToken,
        role: user.role,
        roles: user.roles.isNotEmpty ? user.roles : [user.role],
        userId: user.id,
        userName: user.fullName,
        kind: kind,
      );
      return Right(user);
    } on UnauthorizedException {
      return const Left(
          AuthFailure('اسم المستخدم أو كلمة المرور غير صحيحة'));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
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
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final user = await _remoteDataSource.getCurrentProfile();
      return Right(user);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    // غير مدعوم في الواجهة الحالية — يُعاد فشل واضح حتى لا يكسر الواجهة.
    return const Left(
        ServerFailure('تغيير كلمة المرور غير مدعوم في هذه النسخة من الخادم'));
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    final authService = Get.find<AuthService>();
    await authService.logout();
  }
}
