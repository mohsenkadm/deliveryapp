// قائمة الأدوار المحتملة في النظام — مرآة لـ
// `DeliverySystem.Domain.Enums.EmployeeRoles` على الخادم.
//
// يتم تخزين أدوار الموظف كقائمة CSV داخل عمود `Roles` في جدول `Employees`،
// لذا قد يحمل موظف واحد عدة قيم في نفس الوقت (مثال: "Driver,Representative").
// قيمتا `Admin` و`Customer` تأتيان من جدولين منفصلين لكنهما تظهران في حقل
// `roles[]` ضمن استجابة `AuthResponseDto` لأغراض التوجيه على العميل.
class EmployeeRoles {
  EmployeeRoles._();

  static const String admin = 'Admin';
  static const String systemManager = 'SystemManager';
  static const String manager = 'Manager';
  static const String salesManager = 'SalesManager';
  static const String supervisor = 'Supervisor';
  static const String representative = 'Representative';
  static const String driver = 'Driver';
  static const String warehouseKeeper = 'WarehouseKeeper';
  static const String cashier = 'Cashier';
  static const String accountant = 'Accountant';
  static const String employee = 'Employee'; // دور احتياطي عام
  static const String customer = 'Customer';

  /// وسم نوع مندوب في JWT/الخادم — ليس «مساحة عمل» منفصلة عن [representative].
  static const String individual = 'Individual';
  static const String wholesale = 'Wholesale';

  /// أدوار/وسوم لا تملك شاشة توجيه خاصة (تُستخدم مع [representative] فقط).
  static bool isRepresentativeKindTag(String r) {
    final x = r.trim();
    return x == individual || x == wholesale;
  }

  /// أدوار لها تبويب/مسار workspace في تطبيق الجوال.
  static bool isMobileWorkspaceRole(String r) =>
      mobileWorkspaceRoles.contains(r);

  /// أدوار يمكن اختيارها من شاشة المساحة (بدون وسوم المندوب).
  static List<String> pickableWorkspaceRoles(Iterable<String> roles) =>
      roles.where(isMobileWorkspaceRole).toList();

  /// كل الأدوار المعروفة (لقوائم الاختيار في الإدارة الخلفية)
  static const List<String> all = [
    admin,
    systemManager,
    manager,
    salesManager,
    supervisor,
    representative,
    driver,
    warehouseKeeper,
    cashier,
    accountant,
    employee,
    customer,
    individual,
    wholesale,
  ];

  /// الأدوار التي تملك واجهة جوّال خاصة بها (workspace).
  static const List<String> mobileWorkspaceRoles = [
    customer,
    driver,
    representative,
    supervisor,
    manager,
    salesManager,
  ];
}
