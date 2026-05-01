// خدمة الترجمة — دعم اللغة العربية
import 'dart:ui';
import 'package:get/get.dart';
import 'ar.dart';

class TranslationService extends Translations {
  static const locale = Locale('ar');
  static const fallbackLocale = Locale('ar');

  @override
  Map<String, Map<String, String>> get keys => {
        'ar': ar,
      };
}
