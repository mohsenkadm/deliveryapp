import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

/// مصدر بيانات المصادقة عن بُعد
class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  /// تسجيل دخول العميل — { phone, password }
  Future<AuthResponse> loginCustomer(LoginRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.loginCustomer,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data['data'] ?? response.data);
  }

  /// يستخدم نفس endpoint: POST /api/admin/login
  /// الدور يُحدَّد من حقل role في الاستجابة
  Future<AuthResponse> loginEmployee(LoginRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.loginEmployee,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data['data'] ?? response.data);
  }

  /// تسجيل عميل جديد (ذاتي)
  Future<void> registerCustomer(RegisterRequest request) async {
    await _dioClient.post(
      ApiConstants.registerCustomer,
      data: request.toJson(),
    );
  }

  /// جلب الملف الشخصي للعميل
  Future<UserModel> getCustomerProfile() async {
    final response = await _dioClient.get(ApiConstants.customerProfile);
    return UserModel.fromJson(response.data['data'] ?? response.data);
  }

  /// تغيير كلمة المرور
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dioClient.post(
      ApiConstants.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      await _dioClient.post(ApiConstants.logout);
    } catch (_) {
      // تجاهل أخطاء API عند الخروج — يتم مسح الجلسة محلياً
    }
  }
}
