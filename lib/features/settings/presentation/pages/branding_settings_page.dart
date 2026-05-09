// صفحة تخصيص الهوية البصرية — اسم النظام، الشعار، الألوان
//
// متاحة للإدارة (Admin) فقط — قابلة للوصول من إعدادات الإدمن.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/branding_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';

class BrandingSettingsPage extends StatelessWidget {
  const BrandingSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final b = Get.find<BrandingService>();
    final nameCtrl = TextEditingController(text: b.appName.value);
    final sloganCtrl = TextEditingController(text: b.companySlogan.value);
    final addressCtrl = TextEditingController(text: b.companyAddress.value);
    final phoneCtrl = TextEditingController(text: b.companyPhone.value);

    return Scaffold(
      appBar: AppBar(
        title: Text('الهوية البصرية',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'استعادة الافتراضي',
            onPressed: () async {
              final ok = await Get.dialog<bool>(AlertDialog(
                title: Text('تأكيد الاستعادة',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                content: Text('سيتم استعادة جميع إعدادات الهوية الافتراضية.',
                    style: GoogleFonts.cairo()),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('إلغاء')),
                  TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('استعادة')),
                ],
              ));
              if (ok == true) {
                await b.resetToDefaults();
                nameCtrl.text = b.appName.value;
                sloganCtrl.clear();
                addressCtrl.clear();
                phoneCtrl.clear();
                SnackbarHelper.showSuccess('تم استعادة الإعدادات الافتراضية');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('شعار النظام'),
          Obx(() => _LogoPicker(
                logoPath: b.logoPath.value,
                onPick: () async {
                  final picker = ImagePicker();
                  final file = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 90);
                  if (file != null) {
                    await b.setLogoPath(file.path);
                    SnackbarHelper.showSuccess('تم تحديث الشعار');
                  }
                },
                onClear: () async {
                  await b.setLogoPath(null);
                  SnackbarHelper.showSuccess('تم حذف الشعار');
                },
              )),
          const SizedBox(height: 24),
          _section('اسم النظام'),
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              hintText: 'اسم النظام',
              prefixIcon: const Icon(Icons.label_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (v) => b.setAppName(v.trim()),
          ),
          const SizedBox(height: 24),
          _section('الألوان'),
          Obx(() => _ColorPickerTile(
                label: 'اللون الأساسي',
                value: b.primaryColorValue.value,
                onChanged: b.setPrimaryColor,
              )),
          const SizedBox(height: 12),
          Obx(() => _ColorPickerTile(
                label: 'اللون الثانوي',
                value: b.secondaryColorValue.value,
                onChanged: b.setSecondaryColor,
              )),
          const SizedBox(height: 24),
          _section('بيانات الشركة (تظهر في الفواتير المطبوعة)'),
          TextField(
            controller: sloganCtrl,
            decoration: _decoration('الشعار النصي / Slogan', Icons.short_text),
            onChanged: (v) => b.setCompanySlogan(v.trim()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: addressCtrl,
            decoration: _decoration('عنوان الشركة', Icons.location_on_outlined),
            onChanged: (v) => b.setCompanyAddress(v.trim()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _decoration('هاتف الشركة', Icons.phone_outlined),
            onChanged: (v) => b.setCompanyPhone(v.trim()),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'سيتم تطبيق التغييرات على واجهة التطبيق فوراً، '
                    'وستظهر بيانات الشركة في الفواتير المطبوعة (PDF).',
                    style: GoogleFonts.cairo(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(right: 4, bottom: 8),
        child: Text(
          title,
          style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary),
        ),
      );

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
}

class _LogoPicker extends StatelessWidget {
  final String? logoPath;
  final VoidCallback onPick;
  final VoidCallback onClear;
  const _LogoPicker({this.logoPath, required this.onPick, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoPath != null && logoPath!.isNotEmpty;
    return Row(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.dividerLight),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasLogo
              ? Image.file(File(logoPath!), fit: BoxFit.cover)
              : Icon(Icons.image_outlined,
                  size: 36, color: AppColors.textSecondary.withValues(alpha: 0.5)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text('اختيار شعار'),
                onPressed: onPick,
              ),
              if (hasLogo) const SizedBox(height: 6),
              if (hasLogo)
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('حذف الشعار',
                      style: TextStyle(color: Colors.red)),
                  onPressed: onClear,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorPickerTile extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _ColorPickerTile(
      {required this.label, required this.value, required this.onChanged});

  static const _palette = <int>[
    0xFF2E7DFF, 0xFF4D9FFF, 0xFF1B5E20, 0xFF2E7D32, 0xFF388E3C,
    0xFFFF7A00, 0xFFE65100, 0xFFD32F2F, 0xFFC62828, 0xFF6A1B9A,
    0xFF4527A0, 0xFF283593, 0xFF00838F, 0xFF00695C, 0xFF455A64,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Color(value),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black12),
                ),
              ),
              const SizedBox(width: 10),
              Text(label,
                  style: GoogleFonts.cairo(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _palette.map((c) {
              final selected = c == value;
              return GestureDetector(
                onTap: () => onChanged(c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.black : Colors.black12,
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
