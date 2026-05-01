// ثوابت التطبيق العامة — الأدوار، الإعدادات، التنسيقات
class AppConstants {
  AppConstants._();

  static const String appName = 'تطبيق التوصيل';
  static const String appVersion = '1.0.0';

  // الأدوار
  static const String roleCustomer = 'Customer';
  static const String roleDriver = 'Driver';
  static const String roleRepresentative = 'Representative';
  static const String roleAdmin = 'Admin';

  // ترقيم الصفحات
  static const int defaultPageSize = 20;

  // مهلة الاتصال
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // تنسيقات التاريخ
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy hh:mm a';
}
