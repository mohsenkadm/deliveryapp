import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_parser.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

/// مصدر بيانات المصادقة عن بُعد — متوافق مع الواجهة الموحّدة الجديدة.
class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<AuthResponse> _login(String path, LoginRequest req) async {
    final response = await _dioClient.post(path, data: req.toJson());
    final data = parseApi<Map<String, dynamic>>(response, (d) {
      if (d is Map) return Map<String, dynamic>.from(d);
      return <String, dynamic>{};
    });
    return AuthResponse.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : data);
  }

  Future<AuthResponse> loginAdmin(LoginRequest request) =>
      _login(ApiConstants.loginAdmin, request);

  Future<AuthResponse> loginCustomer(LoginRequest request) =>
      _login(ApiConstants.loginCustomer, request);

  Future<AuthResponse> loginEmployee(LoginRequest request) =>
      _login(ApiConstants.loginEmployee, request);

  Future<AuthResponse> loginRepresentativeEmployee(LoginRequest r) =>
      loginEmployee(r);

  Future<void> registerCustomer(RegisterRequest request) async {
    parseApiVoid(await _dioClient.post(
      ApiConstants.registerCustomer,
      data: request.toJson(),
    ));
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dioClient.get(ApiConstants.me);
    return parseApiMap(response);
  }

  Future<UserModel> getCurrentProfile() async {
    final me = await getMe();
    final profile = (me['profile'] is Map)
        ? Map<String, dynamic>.from(me['profile'] as Map)
        : me;
    return UserModel.fromJson(profile);
  }

  @Deprecated('استخدم getCurrentProfile() المبني على /api/me')
  Future<UserModel> getCustomerProfile() => getCurrentProfile();

  Future<void> deleteMyAccount(String id) async {
    parseApiVoid(await _dioClient.delete(ApiConstants.customerById(id)));
  }

  Future<void> logout() async {}
}
