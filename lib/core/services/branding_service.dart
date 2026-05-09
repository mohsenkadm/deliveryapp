// خدمة الهوية البصرية — تخصيص اسم التطبيق وشعاره وألوانه
//
// تتيح للإدارة تخصيص:
//   - اسم النظام الظاهر في الواجهات والفواتير
//   - شعار النظام (مسار محلي أو URL)
//   - اللون الأساسي (Primary)
//   - اللون الثانوي (Secondary)
//
// تُحفظ القيم في GetStorage وتُستخدم في الثيم والفواتير المطبوعة.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BrandingService extends GetxService {
  static const _kAppName = 'branding_app_name';
  static const _kLogoPath = 'branding_logo_path';
  static const _kPrimary = 'branding_primary_color';
  static const _kSecondary = 'branding_secondary_color';
  static const _kCompanySlogan = 'branding_company_slogan';
  static const _kCompanyAddress = 'branding_company_address';
  static const _kCompanyPhone = 'branding_company_phone';

  // ── القيم الافتراضية ──
  static const String defaultAppName = 'تطبيق التوصيل';
  static const int defaultPrimary = 0xFF2E7DFF;
  static const int defaultSecondary = 0xFFFF7A00;

  late final GetStorage _box;

  // متغيرات مراقبة (Reactive)
  final appName = defaultAppName.obs;
  final logoPath = RxnString();
  final primaryColorValue = defaultPrimary.obs;
  final secondaryColorValue = defaultSecondary.obs;
  final companySlogan = ''.obs;
  final companyAddress = ''.obs;
  final companyPhone = ''.obs;

  Future<BrandingService> init() async {
    _box = GetStorage();
    appName.value = _box.read<String>(_kAppName) ?? defaultAppName;
    logoPath.value = _box.read<String>(_kLogoPath);
    primaryColorValue.value = _box.read<int>(_kPrimary) ?? defaultPrimary;
    secondaryColorValue.value =
        _box.read<int>(_kSecondary) ?? defaultSecondary;
    companySlogan.value = _box.read<String>(_kCompanySlogan) ?? '';
    companyAddress.value = _box.read<String>(_kCompanyAddress) ?? '';
    companyPhone.value = _box.read<String>(_kCompanyPhone) ?? '';
    return this;
  }

  Color get primaryColor => Color(primaryColorValue.value);
  Color get secondaryColor => Color(secondaryColorValue.value);

  Future<void> setAppName(String name) async {
    appName.value = name.isEmpty ? defaultAppName : name;
    await _box.write(_kAppName, appName.value);
  }

  Future<void> setLogoPath(String? path) async {
    logoPath.value = path;
    if (path == null || path.isEmpty) {
      await _box.remove(_kLogoPath);
    } else {
      await _box.write(_kLogoPath, path);
    }
  }

  Future<void> setPrimaryColor(int value) async {
    primaryColorValue.value = value;
    await _box.write(_kPrimary, value);
  }

  Future<void> setSecondaryColor(int value) async {
    secondaryColorValue.value = value;
    await _box.write(_kSecondary, value);
  }

  Future<void> setCompanySlogan(String v) async {
    companySlogan.value = v;
    await _box.write(_kCompanySlogan, v);
  }

  Future<void> setCompanyAddress(String v) async {
    companyAddress.value = v;
    await _box.write(_kCompanyAddress, v);
  }

  Future<void> setCompanyPhone(String v) async {
    companyPhone.value = v;
    await _box.write(_kCompanyPhone, v);
  }

  /// تطبيق إعدادات النظام القادمة من السيرفر (SystemSettingsDto)
  /// يحدّث الحقول المعرّفة فقط ويكتب في GetStorage.
  Future<void> syncFromServer(Map<String, dynamic> dto) async {
    final name = dto['systemName']?.toString();
    if (name != null && name.isNotEmpty) await setAppName(name);

    final logo = dto['logoPath']?.toString();
    if (logo != null && logo.isNotEmpty) await setLogoPath(logo);

    final color = dto['primaryColor']?.toString();
    if (color != null && color.isNotEmpty) {
      final parsed = _parseHexColor(color);
      if (parsed != null) await setPrimaryColor(parsed);
    }

    final phone = dto['contactPhone']?.toString();
    if (phone != null) await setCompanyPhone(phone);

    final address = dto['address']?.toString();
    if (address != null) await setCompanyAddress(address);

    final footer = dto['footerText']?.toString();
    if (footer != null && footer.isNotEmpty) await setCompanySlogan(footer);
  }

  static int? _parseHexColor(String hex) {
    var s = hex.trim().replaceAll('#', '');
    if (s.length == 6) s = 'FF$s';
    if (s.length != 8) return null;
    return int.tryParse(s, radix: 16);
  }

  Future<void> resetToDefaults() async {
    await _box.remove(_kAppName);
    await _box.remove(_kLogoPath);
    await _box.remove(_kPrimary);
    await _box.remove(_kSecondary);
    await _box.remove(_kCompanySlogan);
    await _box.remove(_kCompanyAddress);
    await _box.remove(_kCompanyPhone);
    appName.value = defaultAppName;
    logoPath.value = null;
    primaryColorValue.value = defaultPrimary;
    secondaryColorValue.value = defaultSecondary;
    companySlogan.value = '';
    companyAddress.value = '';
    companyPhone.value = '';
  }
}
