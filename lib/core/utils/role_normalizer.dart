import '../constants/employee_roles.dart';

/// تطبيع أدوار JWT القادمة من الخادم إلى شكل يفهمه التطبيق.
class RoleNormalizer {
  RoleNormalizer._();

  static const String individualRepresentative = 'IndividualRepresentative';
  static const String wholesaleRepresentative = 'WholesaleRepresentative';

  /// يوسّع الأدوار المركّبة (IndividualRepresentative…) إلى Representative + وسم.
  static List<String> normalize(Iterable<String> roles) {
    final result = <String>[];
    for (final r in roles) {
      final t = r.trim();
      if (t.isEmpty) continue;
      if (!result.any((e) => e.toLowerCase() == t.toLowerCase())) {
        result.add(t);
      }
    }

    void ensure(String role) {
      if (!result.any((e) => e.toLowerCase() == role.toLowerCase())) {
        result.add(role);
      }
    }

    if (result.any((r) => r == individualRepresentative)) {
      ensure(EmployeeRoles.representative);
      ensure(EmployeeRoles.individual);
    }
    if (result.any((r) => r == wholesaleRepresentative)) {
      ensure(EmployeeRoles.representative);
      ensure(EmployeeRoles.wholesale);
    }

    // مندوب قديم بدون وسم → افتراضياً مفرد
    if (result.contains(EmployeeRoles.representative) &&
        !result.contains(EmployeeRoles.individual) &&
        !result.contains(EmployeeRoles.wholesale)) {
      ensure(EmployeeRoles.individual);
    }

    return result;
  }

  /// يختار activeRole المناسب للتوجيه بعد تسجيل الدخول.
  static String pickActiveRole(List<String> normalized, String primaryRole) {
    final pickable = EmployeeRoles.pickableWorkspaceRoles(normalized);
    if (pickable.isNotEmpty) return pickable.first;

    if (primaryRole == individualRepresentative ||
        primaryRole == wholesaleRepresentative) {
      return EmployeeRoles.representative;
    }
    return primaryRole;
  }
}
