// وسيط الأدوار — التحقق من صلاحية الدور قبل التوجيه
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class RoleMiddleware extends GetMiddleware {
  final String allowedRole;

  RoleMiddleware({required this.allowedRole});

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.isLoggedIn) {
      return const RouteSettings(name: '/role-selection');
    }
    if (authService.userRole != allowedRole) {
      return RouteSettings(name: authService.getHomeRoute());
    }
    return null;
  }
}
