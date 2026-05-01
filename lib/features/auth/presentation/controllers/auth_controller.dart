import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/onesignal_service.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/utils/snackbar_helper.dart';
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

  final formKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

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
      username: usernameController.text.trim(),
      password: passwordController.text,
    );

    isLoading.value = false;
    result.fold(
      (failure) => SnackbarHelper.showError(failure.message),
      (user) {
        _clearFields();
        _linkOneSignal();
        Get.offAllNamed(AppRoutes.customer);
      },
    );
  }

  /// تسجيل دخول موحّد للموظفين — يوجّه حسب الدور المُعاد من الخادم
  Future<void> _loginEmployeeAndRoute() async {
    if (!formKey.currentState!.validate()) return;
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
        // تشغيل اتصال SignalR
        try {
          Get.find<SignalRService>().connect();
        } catch (_) {}
        _routeByRole(user.role);
      },
    );
  }

  void _routeByRole(String role) {
    switch (role.toLowerCase()) {
      case 'driver':
        Get.offAllNamed(AppRoutes.driver);
        break;
      case 'representative':
        Get.offAllNamed(AppRoutes.representative);
        break;
      case 'supervisor':
        Get.offAllNamed(AppRoutes.supervisor);
        break;
      case 'salesmanager':
      case 'sales_manager':
        Get.offAllNamed(AppRoutes.salesManager);
        break;
      case 'admin':
      default:
        Get.offAllNamed(AppRoutes.admin);
    }
  }

  /// تسجيل دخول السائق
  Future<void> loginDriver() => _loginEmployeeAndRoute();

  /// تسجيل دخول المندوب
  Future<void> loginRepresentative() => _loginEmployeeAndRoute();

  /// تسجيل دخول المشرف
  Future<void> loginSupervisor() => _loginEmployeeAndRoute();

  /// تسجيل دخول مدير المبيعات
  Future<void> loginSalesManager() => _loginEmployeeAndRoute();

  /// تسجيل دخول المدير
  Future<void> loginAdmin() => _loginEmployeeAndRoute();

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
    Get.offAllNamed(AppRoutes.roleSelection);
  }
}
