import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

/// مصدر بيانات المصادقة عن بُعد — متوافق مع الواجهة الموحّدة الجديدة.
///
/// يوجد ثلاث نقاط دخول فقط:
/// - POST /api/auth/admin
/// - POST /api/auth/customer
/// - POST /api/auth/employee   (يعمل لأي مزيج من أدوار الموظفين)
///
/// كل الردود مغلّفة بـ ApiResponse<T> { success, messageAr, messageEn, data }.
class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<AuthResponse> _login(String path, LoginRequest req) async {
    final response = await _dioClient.post(path, data: req.toJson());
    final body = response.data;
    if (body is Map && body['success'] == false) {
      throw ApiException(
        message: (body['messageAr'] ?? body['messageEn'] ?? 'فشل تسجيل الدخول')
            .toString(),
        statusCode: response.statusCode,
      );
    }
    final data = (body is Map && body['data'] is Map)
        ? Map<String, dynamic>.from(body['data'] as Map)
        : Map<String, dynamic>.from(body as Map);
    return AuthResponse.fromJson(data);
  }

  /// تسجيل دخول الأدمن — POST /api/auth/admin
  Future<AuthResponse> loginAdmin(LoginRequest request) =>
      _login(ApiConstants.loginAdmin, request);

  /// تسجيل دخول العميل — POST /api/auth/customer
  Future<AuthResponse> loginCustomer(LoginRequest request) =>
      _login(ApiConstants.loginCustomer, request);

  /// تسجيل دخول الموظف — POST /api/auth/employee
  /// يعمل لجميع تركيبات الأدوار (Driver / Representative / Supervisor / Manager …).
  Future<AuthResponse> loginEmployee(LoginRequest request) =>
      _login(ApiConstants.loginEmployee, request);

  // ── أسماء قديمة محفوظة للتوافق ──
  Future<AuthResponse> loginRepresentativeEmployee(LoginRequest r) =>
      loginEmployee(r);

  /// تسجيل عميل جديد (ذاتي) — ينشأ الحساب بحالة "بانتظار الموافقة".
  Future<void> registerCustomer(RegisterRequest request) async {
    await _dioClient.post(
      ApiConstants.registerCustomer,
      data: request.toJson(),
    );
  }

  /// GET /api/me — الملف الشخصي للمستخدم الحالي بأي دور (Admin/Customer/Employee)
  /// يُرجع `{ kind, profile }` حسب الواجهة الموحّدة.
  Future<Map<String, dynamic>> getMe() async {
    final response = await _dioClient.get(ApiConstants.me);
    final data = (response.data is Map && response.data['data'] is Map)
        ? Map<String, dynamic>.from(response.data['data'] as Map)
        : Map<String, dynamic>.from(response.data as Map);
    return data;
  }

  /// الملف الشخصي كـ `UserModel` — يستخرج `profile` من /api/me ويبنيه.
  Future<UserModel> getCurrentProfile() async {
    final me = await getMe();
    final profile = (me['profile'] is Map)
        ? Map<String, dynamic>.from(me['profile'] as Map)
        : me;
    return UserModel.fromJson(profile);
  }

  // اسم قديم محفوظ للتوافق مع الكود الموجود.
  @Deprecated('استخدم getCurrentProfile() المبني على /api/me')
  Future<UserModel> getCustomerProfile() => getCurrentProfile();

  /// تسجيل الخروج — لا توجد نقطة على الخادم، التنفيذ محلياً فقط.
  Future<void> logout() async {
    // لا يوجد POST /logout في الواجهة الحالية. يكفي مسح التوكن محلياً
    // (يقوم به AuthService.logout()).
  }
}
