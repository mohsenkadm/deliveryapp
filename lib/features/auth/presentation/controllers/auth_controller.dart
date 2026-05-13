import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/branding_service.dart';
import '../../../../core/services/onesignal_service.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../admin/data/datasources/admin_remote_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/dio_client.dart';

/// متحكم المصادقة — تسجيل الدخول والتسجيل والخروج لجميع الأدوار
class AuthController extends GetxController {
  late final AuthRepository _repository;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final usernameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();        // نموذج العميل
  final employeeFormKey = GlobalKey<FormState>(); // نموذج الموظف
  final adminFormKey = GlobalKey<FormState>();    // نموذج المسؤول
  final registerFormKey = GlobalKey<FormState>();

  // حقول تسجيل دخول المسؤول (تبويب منفصل)
  final adminUsernameController = TextEditingController();
  final adminPasswordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final adminObscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    final dioClient = Get.find<DioClient>();
    final dataSource = AuthRemoteDataSource(dioClient);
    _repository = AuthRepositoryImpl(dataSource);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    usernameController.dispose();
    confirmPasswordController.dispose();
    adminUsernameController.dispose();
    adminPasswordController.dispose();
    super.onClose();
  }

  void _clearFields() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    phoneController.clear();
    addressController.clear();
    usernameController.clear();
    confirmPasswordController.clear();
    adminUsernameController.clear();
    adminPasswordController.clear();
  }

  /// ربط OneSignal بمعرف المستخدم بعد تسجيل الدخول
  void _linkOneSignal() {
    final authService = Get.find<AuthService>();
    if (authService.userId.isNotEmpty) {
      Get.find<OneSignalService>().setExternalUserId(authService.userId);
    }
  }

  /// تسجيل دخول العميل
  Future<void> loginCustomer() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;

    final result = await _repository.loginCustomer(
      username: phoneController.text.trim(),
      password: passwordController.text,
    );

    isLoading.value = false;
    result.fold(
      (failure) => SnackbarHelper.showError(failure.message),
      (user) {
        _clearFields();
        _linkOneSignal();
        _syncSystemSettings();
        try {
          Get.find<SignalRService>().connect();
        } catch (_) {}
        Get.offAllNamed(AppRoutes.customer);
      },
    );
  }

  /// تسجيل دخول موحّد للموظفين — إذا كان الموظف يحمل عدة أدوار يُوجَّه
  /// إلى شاشة اختيار الـ workspace أولاً.
  Future<void> _loginEmployeeAndRoute() async {
    if (!(employeeFormKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;

    final result = await _repository.loginEmployee(
      username: usernameController.text.trim(),
      password: passwordController.text,
    );

    isLoading.value = false;
    result.fold(
      (failure) => SnackbarHelper.showError(failure.message),
      (user) {
        _clearFields();
        _linkOneSignal();
        try {
          Get.find<SignalRService>().connect();
        } catch (_) {}

        final auth = Get.find<AuthService>();
        if (auth.pickableWorkspaceRoles.length > 1) {
          Get.offAllNamed(AppRoutes.roleSelection, arguments: auth.userRoles);
        } else {
          _routeByRole(auth.activeRole);
        }
      },
    );
  }

  void _routeByRole(String role) {
    _syncSystemSettings();
    Get.offAllNamed(AuthService.routeForRole(role));
  }

  /// مزامنة إعدادات الشركة (الشعار/الألوان/الاسم) بعد تسجيل الدخول.
  /// تستخدم GET /api/settings/company لأي دور مصدَّق.
  void _syncSystemSettings() {
    try {
      final ds = AdminRemoteDataSource(Get.find<DioClient>());
      final branding = Get.find<BrandingService>();
      ds.getCompanySettings().then(branding.syncFromServer).catchError((_) {});
    } catch (_) {}
  }

  /// تسجيل دخول السائق
  Future<void> loginDriver() => _loginEmployeeAndRoute();

  /// تسجيل دخول المندوب
  Future<void> loginRepresentative() => _loginEmployeeAndRoute();

  /// تسجيل دخول المشرف
  Future<void> loginSupervisor() => _loginEmployeeAndRoute();

  /// تسجيل دخول مدير المبيعات
  Future<void> loginSalesManager() => _loginEmployeeAndRoute();

  /// تسجيل دخول الموظف عبر تبويب الموظف (يستخدم /api/representative/login)
  Future<void> loginEmployee() => _loginEmployeeAndRoute();

  /// تسجيل دخول المسؤول (أدمن) — يستخدم /api/admin/login مباشرةً
  Future<void> loginAdmin() async {
    if (!(adminFormKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;

    final result = await _repository.loginAdmin(
      username: adminUsernameController.text.trim(),
      password: adminPasswordController.text,
    );

    isLoading.value = false;
    result.fold(
      (failure) => SnackbarHelper.showError(failure.message),
      (user) {
        _clearFields();
        _linkOneSignal();
        _syncSystemSettings();
        Get.offAllNamed(AppRoutes.admin);
      },
    );
  }

  /// تسجيل عميل جديد
  Future<void> registerCustomer() async {
    if (!registerFormKey.currentState!.validate()) return;
    isLoading.value = true;

    final result = await _repository.registerCustomer(
      fullName: fullNameController.text.trim(),
      username: usernameController.text.trim(),
      password: passwordController.text,
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
    );

    isLoading.value = false;
    result.fold(
      (failure) => SnackbarHelper.showError(failure.message),
      (_) {
        _clearFields();
        Get.offAllNamed(AppRoutes.registrationPending);
      },
    );
  }

  /// تسجيل الخروج مع فصل OneSignal
  Future<void> logout() async {
    isLoading.value = true;
    Get.find<OneSignalService>().removeExternalUserId();
    await _repository.logout();
    isLoading.value = false;
    _clearFields();
    Get.offAllNamed(AppRoutes.login);
  }
}
