import 'package:get/get.dart';
import '../constants/storage_keys.dart';
import 'storage_service.dart';

// خدمة المصادقة — إدارة حالة تسجيل الدخول والجلسة
class AuthService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();

  final _isLoggedIn = false.obs;
  bool get isLoggedIn => _isLoggedIn.value;

  final _userRole = ''.obs;
  String get userRole => _userRole.value;

  final _userName = ''.obs;
  String get userName => _userName.value;

  final _userId = ''.obs;
  String get userId => _userId.value;

  Map<String, String>? get currentUser => isLoggedIn
      ? {'fullName': userName, 'phone': '', 'address': '', 'userId': userId}
      : null;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await _storageService.getToken();
    _isLoggedIn.value = token != null && token.isNotEmpty;
    _userRole.value = _storageService.userRole ?? '';
    _userName.value = _storageService.userName ?? '';
    _userId.value = _storageService.userId ?? '';
  }

  Future<void> saveSession({
    required String token,
    required String refreshToken,
    required String role,
    required String userId,
    required String userName,
  }) async {
    await _storageService.saveToken(token);
    await _storageService.saveRefreshToken(refreshToken);
    await _storageService.saveUserRole(role);
    await _storageService.saveUserId(userId);
    await _storageService.saveUserName(userName);

    _isLoggedIn.value = true;
    _userRole.value = role;
    _userId.value = userId;
    _userName.value = userName;
  }

  /// تسجيل الخروج ومسح بيانات الجلسة
  Future<void> logout() async {
    await _storageService.clearTokens();
    await _storageService.remove(StorageKeys.userRole);
    await _storageService.remove(StorageKeys.userId);
    await _storageService.remove(StorageKeys.userName);
    _isLoggedIn.value = false;
    _userRole.value = '';
    _userId.value = '';
    _userName.value = '';
  }

  String getHomeRoute() {
    switch (_userRole.value) {
      case 'Customer':
        return '/customer';
      case 'Driver':
        return '/driver';
      case 'Representative':
        return '/representative';
      case 'Admin':
        return '/admin';
      default:
        return '/role-selection';
    }
  }
}
