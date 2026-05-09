import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/employee_roles.dart';

/// شاشة اختيار الـ workspace للموظفين الذين يحملون عدة أدوار في نفس الوقت.
///
/// تُستدعى من `AuthController` بعد نجاح تسجيل دخول الموظف عند `roles.length > 1`.
/// تستقبل قائمة الأدوار عبر `Get.arguments` (List<String>).
///
/// ملاحظة: نفس التوكن يعمل مع كل المساحات (Driver / Representative / …).
class RolePickerPage extends StatelessWidget {
  const RolePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final roles = (Get.arguments is List)
        ? List<String>.from(Get.arguments as List)
        : auth.userRoles;

    // اعرض فقط الأدوار التي لها workspace مخصّص
    final pickable = roles
        .where(EmployeeRoles.mobileWorkspaceRoles.contains)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('اختر مساحة العمل')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'مرحباً ${auth.userName} 👋',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                  'حسابك يحمل أكثر من دور. يمكنك التبديل بينهم لاحقاً من الإعدادات.'),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: pickable.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final role = pickable[index];
                    return _RoleTile(
                      role: role,
                      onTap: () async {
                        await auth.switchActiveRole(role);
                        Get.offAllNamed(AuthService.routeForRole(role));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final String role;
  final VoidCallback onTap;
  const _RoleTile({required this.role, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(_iconFor(role))),
        title: Text(_labelFor(role)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  static String _labelFor(String role) {
    switch (role) {
      case EmployeeRoles.driver:
        return 'سائق';
      case EmployeeRoles.representative:
        return 'مندوب';
      case EmployeeRoles.supervisor:
        return 'مشرف';
      case EmployeeRoles.salesManager:
      case EmployeeRoles.manager:
        return 'مدير المبيعات';
      case EmployeeRoles.customer:
        return 'عميل';
      default:
        return role;
    }
  }

  static IconData _iconFor(String role) {
    switch (role) {
      case EmployeeRoles.driver:
        return Icons.local_shipping;
      case EmployeeRoles.representative:
        return Icons.person_pin_circle;
      case EmployeeRoles.supervisor:
        return Icons.supervisor_account;
      case EmployeeRoles.salesManager:
      case EmployeeRoles.manager:
        return Icons.bar_chart;
      case EmployeeRoles.customer:
        return Icons.shopping_bag;
      default:
        return Icons.work;
    }
  }
}
