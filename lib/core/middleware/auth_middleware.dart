// وسيط المصادقة — التحقق من تسجيل الدخول قبل التوجيه
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}
