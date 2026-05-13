import 'package:get/get.dart';
import '../constants/storage_keys.dart';
import '../constants/employee_roles.dart';
import 'storage_service.dart';

/// نوع المستخدم المسجَّل دخوله — يساعد على اختيار شاشة البداية وملف الإعدادات.
enum UserKind { admin, customer, employee, unknown }

/// خدمة المصادقة — إدارة حالة الجلسة والأدوار المتعدّدة.
///
/// متوافقة مع DeliverySystem.API:
/// - الموظف الواحد قد يحمل عدة أدوار (مثال: Driver + Representative).
/// - قد يُرجع الخادم وسوم نوع المندوب مع [EmployeeRoles.representative]:
///   [Individual] (مفرد → مستودع فرعي) أو [Wholesale] (جملة → مخزون رئيسي للفواتير).
/// - بعد تسجيل الدخول يخزّن `roles[]` كاملاً ويختار `activeRole` الذي
///   يحدّد الـ workspace الحالي للجوّال (دائماً دوراً له مسار، وليس الوسم فقط).
class AuthService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();

  final _isLoggedIn = false.obs;
  bool get isLoggedIn => _isLoggedIn.value;

  /// الدور النشط حالياً (المستخدم اختاره من شاشة الاختيار، أو الدور الوحيد).
  final _activeRole = ''.obs;
  String get activeRole => _activeRole.value;

  /// الدور الأساسي كما عاد من الخادم (أول قيمة في `roles`).
  final _userRole = ''.obs;
  String get userRole => _userRole.value;

  /// قائمة كل الأدوار للموظف.
  final _userRoles = <String>[].obs;
  List<String> get userRoles => _userRoles.toList();

  final _userName = ''.obs;
  String get userName => _userName.value;

  final _userId = ''.obs;
  String get userId => _userId.value;

  final _userKind = Rx<UserKind>(UserKind.unknown);
  UserKind get userKind => _userKind.value;

  Map<String, String>? get currentUser => isLoggedIn
      ? {
          'fullName': userName,
          'phone': '',
          'address': '',
          'userId': userId,
          'role': activeRole,
        }
      : null;

  /// أكثر من مساحة عمل جوّال يمكن التبديل بينها (بدون وسوم Individual/Wholesale).
  bool get isMultiRole =>
      EmployeeRoles.pickableWorkspaceRoles(_userRoles).length > 1;

  /// أدوار الموظف التي لها شاشة workspace في الجوال.
  List<String> get pickableWorkspaceRoles =>
      EmployeeRoles.pickableWorkspaceRoles(_userRoles);

  /// مندوب جملة: إنشاء فواتير من مخزون المستودع الرئيسي (لا يُعرض تبويب المستودع الفرعي).
  bool get isWholesaleRepresentative =>
      userKind == UserKind.employee &&
      hasRole(EmployeeRoles.representative) &&
      hasRole(EmployeeRoles.wholesale);

  /// مندوب مفرد (وسم Individual مع مندوب).
  bool get isIndividualRepresentative =>
      userKind == UserKind.employee &&
      hasRole(EmployeeRoles.representative) &&
      hasRole(EmployeeRoles.individual);

  /// تبويب المستودع الفرعي وأوامر النقل — يُخفى لمندوب الجملة.
  bool get repShowSubWarehouseTab =>
      userKind == UserKind.employee &&
      hasRole(EmployeeRoles.representative) &&
      !hasRole(EmployeeRoles.wholesale);

  /// هل يحمل المستخدم الدور المحدّد (بأي ترتيب).
  bool hasRole(String r) =>
      _userRoles.any((e) => e.toLowerCase() == r.toLowerCase());

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await _storageService.getToken();
    _isLoggedIn.value = token != null && token.isNotEmpty;
    _userRole.value = _storageService.userRole ?? '';
    _userRoles.value = _storageService.userRoles;
    _activeRole.value =
        _storageService.activeRole ?? _userRole.value;
    _userName.value = _storageService.userName ?? '';
    _userId.value = _storageService.userId ?? '';
    _userKind.value = _kindFromString(_storageService.userKind);
    await _coerceEmployeeActiveRoleIfNeeded();
  }

  /// إذا كان `activeRole` المخزّن وسم Individual/Wholesale أو غير معروف،
  /// اضبطه على أول دور له مسار (مثلاً Representative) حتى لا يُوجَّه المستخدم إلى `/login`.
  Future<void> _coerceEmployeeActiveRoleIfNeeded() async {
    if (_userKind.value != UserKind.employee) return;
    if (routeForRole(_activeRole.value) != '/login') return;
    final pickable = EmployeeRoles.pickableWorkspaceRoles(_userRoles);
    if (pickable.isEmpty) return;
    final fixed = pickable.first;
    _activeRole.value = fixed;
    await _storageService.saveActiveRole(fixed);
  }

  /// حفظ الجلسة بعد نجاح تسجيل الدخول.
  /// - `roles` يجب تمريره كاملاً (CSV من الخادم).
  /// - `activeRole` افتراضياً = أول دور إذا لم يُحدَّد.
  Future<void> saveSession({
    required String token,
    required String role,
    required List<String> roles,
    required String userId,
    required String userName,
    required UserKind kind,
    String? activeRole,
  }) async {
    var selected =
        (activeRole != null && activeRole.isNotEmpty) ? activeRole : role;
    if (kind == UserKind.employee && routeForRole(selected) == '/login') {
      final pickable = EmployeeRoles.pickableWorkspaceRoles(roles);
      if (pickable.isNotEmpty) {
        selected = pickable.first;
      }
    }

    await _storageService.saveToken(token);
    await _storageService.saveUserRole(role);
    await _storageService.saveUserRoles(roles);
    await _storageService.saveActiveRole(selected);
    await _storageService.saveUserId(userId);
    await _storageService.saveUserName(userName);
    await _storageService.saveUserKind(_kindToString(kind));

    _isLoggedIn.value = true;
    _userRole.value = role;
    _userRoles.value = roles;
    _activeRole.value = selected;
    _userId.value = userId;
    _userName.value = userName;
    _userKind.value = kind;
  }

  /// تبديل الـ workspace النشط (للموظفين متعددي الأدوار).
  Future<void> switchActiveRole(String role) async {
    if (!hasRole(role)) return;
    if (!EmployeeRoles.isMobileWorkspaceRole(role)) return;
    _activeRole.value = role;
    await _storageService.saveActiveRole(role);
  }

  /// تسجيل الخروج ومسح بيانات الجلسة محلياً.
  Future<void> logout() async {
    await _storageService.clearTokens();
    await _storageService.remove(StorageKeys.userRole);
    await _storageService.remove(StorageKeys.userRoles);
    await _storageService.remove(StorageKeys.activeRole);
    await _storageService.remove(StorageKeys.userKind);
    await _storageService.remove(StorageKeys.userId);
    await _storageService.remove(StorageKeys.userName);
    _isLoggedIn.value = false;
    _userRole.value = '';
    _userRoles.clear();
    _activeRole.value = '';
    _userId.value = '';
    _userName.value = '';
    _userKind.value = UserKind.unknown;
  }

  /// مسار الشاشة الرئيسية اعتماداً على الدور النشط.
  String getHomeRoute() => routeForRole(_activeRole.value);

  /// مسار الشاشة الرئيسية لدور معيّن — مفيد لشاشة اختيار الـ workspace.
  static String routeForRole(String role) {
    switch (role) {
      case EmployeeRoles.customer:
        return '/customer';
      case EmployeeRoles.driver:
        return '/driver';
      case EmployeeRoles.representative:
        return '/representative';
      case EmployeeRoles.supervisor:
        return '/supervisor';
      case EmployeeRoles.salesManager:
      case EmployeeRoles.manager:
        return '/sales-manager';
      case EmployeeRoles.admin:
      case EmployeeRoles.systemManager:
      case EmployeeRoles.warehouseKeeper:
      case EmployeeRoles.cashier:
      case EmployeeRoles.accountant:
        return '/admin';
      default:
        return '/login';
    }
  }

  static String _kindToString(UserKind k) {
    switch (k) {
      case UserKind.admin:
        return 'admin';
      case UserKind.customer:
        return 'customer';
      case UserKind.employee:
        return 'employee';
      case UserKind.unknown:
        return 'unknown';
    }
  }

  static UserKind _kindFromString(String? s) {
    switch (s) {
      case 'admin':
        return UserKind.admin;
      case 'customer':
        return UserKind.customer;
      case 'employee':
        return UserKind.employee;
      default:
        return UserKind.unknown;
    }
  }
}
