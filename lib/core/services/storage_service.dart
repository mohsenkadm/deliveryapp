// خدمة التخزين المحلي — FlutterSecureStorage للتوكنات، GetStorage للإعدادات
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/storage_keys.dart';

class StorageService extends GetxService {
  late final GetStorage _box;
  late final FlutterSecureStorage _secureStorage;

  GetStorage get box => _box;
  FlutterSecureStorage get secureStorage => _secureStorage;

  Future<StorageService> init() async {
    _box = GetStorage();
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    return this;
  }

  // ── Secure Storage (JWT tokens) ──
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageKeys.accessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: StorageKeys.refreshToken);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _box.erase();
  }

  // ── Regular Storage ──
  T? read<T>(String key) => _box.read<T>(key);
  Future<void> write(String key, dynamic value) => _box.write(key, value);
  Future<void> remove(String key) => _box.remove(key);

  bool get isFirstTime => _box.read(StorageKeys.isFirstTime) ?? true;
  Future<void> setFirstTimeDone() => _box.write(StorageKeys.isFirstTime, false);

  String? get userRole => _box.read(StorageKeys.userRole);
  Future<void> saveUserRole(String role) =>
      _box.write(StorageKeys.userRole, role);

  /// قائمة الأدوار الكاملة (للموظفين متعددي الأدوار)
  List<String> get userRoles {
    final raw = _box.read<String>(StorageKeys.userRoles);
    if (raw == null || raw.isEmpty) {
      final r = userRole;
      return (r == null || r.isEmpty) ? const [] : [r];
    }
    return raw.split(',').where((e) => e.isNotEmpty).toList();
  }

  Future<void> saveUserRoles(List<String> roles) =>
      _box.write(StorageKeys.userRoles, roles.join(','));

  /// الدور النشط حالياً (يختاره المستخدم بعد تسجيل الدخول إن كان متعدد الأدوار)
  String? get activeRole => _box.read(StorageKeys.activeRole);
  Future<void> saveActiveRole(String role) =>
      _box.write(StorageKeys.activeRole, role);

  /// نوع المستخدم: customer | employee | admin
  String? get userKind => _box.read(StorageKeys.userKind);
  Future<void> saveUserKind(String kind) =>
      _box.write(StorageKeys.userKind, kind);

  String? get userId => _box.read(StorageKeys.userId);
  Future<void> saveUserId(String id) => _box.write(StorageKeys.userId, id);

  String? get userName => _box.read(StorageKeys.userName);
  Future<void> saveUserName(String name) =>
      _box.write(StorageKeys.userName, name);
}
