// مفاتيح التخزين المحلي — أسماء المفاتيح للقيم المخزّنة
class StorageKeys {
  StorageKeys._();

  // ── الجلسة (Secure Storage) ──
  static const String accessToken = 'access_token';
  // ملاحظة: refreshToken لم يعد مستخدماً (التوكن يدوم 7 أيام).
  // المفتاح يبقى لتنظيف القيم القديمة فقط.
  static const String refreshToken = 'refresh_token';

  // ── ملف المستخدم (GetStorage) ──
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userFullName = 'user_full_name';
  static const String userEmail = 'user_email';

  /// الدور الأساسي (أول دور في القائمة)
  static const String userRole = 'user_role';

  /// الدور النشط حالياً للموظفين متعددي الأدوار
  static const String activeRole = 'active_role';

  /// قائمة جميع أدوار المستخدم — قائمة CSV (مثال: "Driver,Representative")
  static const String userRoles = 'user_roles';

  /// نوع المستخدم: customer | employee | admin
  static const String userKind = 'user_kind';

  // ── إعدادات التطبيق ──
  static const String isFirstTime = 'is_first_time';
  static const String isDarkMode = 'is_dark_mode';
  static const String languageCode = 'language_code';
  static const String fcmToken = 'fcm_token';
  static const String oneSignalPlayerId = 'onesignal_player_id';
  static const String accentColor = 'accent_color';
}
