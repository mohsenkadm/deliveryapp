import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/storage_keys.dart';

/// متحكم المظهر — الوضع الداكن/الفاتح ولون التمييز
class ThemeController extends GetxController {
  final _storage = GetStorage();
  final isDarkMode = false.obs;
  final accentColor = 0xFF1B5E20.obs; // اللون الافتراضي — أخضر داكن

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.read(StorageKeys.isDarkMode) ?? false;
    accentColor.value = _storage.read(StorageKeys.accentColor) ?? 0xFF1B5E20;
  }

  /// تبديل الوضع الداكن/الفاتح
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.write(StorageKeys.isDarkMode, isDarkMode.value);
    Get.changeThemeMode(themeMode);
    update();
  }

  /// تعيين الوضع الداكن أو الفاتح
  void setDarkMode(bool value) {
    isDarkMode.value = value;
    _storage.write(StorageKeys.isDarkMode, value);
    Get.changeThemeMode(themeMode);
    update();
  }

  /// تعيين لون التمييز المختار
  void setAccentColor(int colorValue) {
    accentColor.value = colorValue;
    _storage.write(StorageKeys.accentColor, colorValue);
    update();
  }
}
