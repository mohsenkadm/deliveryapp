// إعدادات النظام (مزامنة مع السيرفر) — للأدمن
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/branding_service.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class AdminSystemSettingsPage extends StatefulWidget {
  const AdminSystemSettingsPage({super.key});

  @override
  State<AdminSystemSettingsPage> createState() =>
      _AdminSystemSettingsPageState();
}

class _AdminSystemSettingsPageState extends State<AdminSystemSettingsPage> {
  late final AdminRemoteDataSource _ds;
  late final BrandingService _branding;

  final _systemNameCtrl = TextEditingController();
  final _logoPathCtrl = TextEditingController();
  final _primaryColorCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _footerTextCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    _branding = Get.find<BrandingService>();
    _load();
  }

  @override
  void dispose() {
    _systemNameCtrl.dispose();
    _logoPathCtrl.dispose();
    _primaryColorCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _contactEmailCtrl.dispose();
    _addressCtrl.dispose();
    _footerTextCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _ds.getSystemSettings();
      _systemNameCtrl.text = (data['systemName'] ?? '').toString();
      _logoPathCtrl.text = (data['logoPath'] ?? '').toString();
      _primaryColorCtrl.text = (data['primaryColor'] ?? '').toString();
      _contactPhoneCtrl.text = (data['contactPhone'] ?? '').toString();
      _contactEmailCtrl.text = (data['contactEmail'] ?? '').toString();
      _addressCtrl.text = (data['address'] ?? '').toString();
      _footerTextCtrl.text = (data['footerText'] ?? '').toString();
      // sync into local branding
      await _branding.syncFromServer(data);
    } catch (_) {
      SnackbarHelper.showError('فشل تحميل الإعدادات');
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final body = {
      'systemName': _systemNameCtrl.text.trim(),
      'logoPath': _logoPathCtrl.text.trim(),
      'primaryColor': _primaryColorCtrl.text.trim(),
      'contactPhone': _contactPhoneCtrl.text.trim(),
      'contactEmail': _contactEmailCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'footerText': _footerTextCtrl.text.trim(),
    };
    try {
      await _ds.updateSystemSettings(body);
      await _branding.syncFromServer(body);
      SnackbarHelper.showSuccess('تم حفظ الإعدادات');
    } catch (_) {
      SnackbarHelper.showError('فشل الحفظ');
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات النظام',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('هذه الإعدادات تُحفظ في السيرفر وتُطبَّق على كل المستخدمين',
                      style: GoogleFonts.cairo(
                          fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _systemNameCtrl,
                      label: 'اسم النظام',
                      prefixIcon: Icons.business),
                  const SizedBox(height: 12),
                  CustomTextField(
                      controller: _logoPathCtrl,
                      label: 'مسار الشعار / URL',
                      prefixIcon: Icons.image_outlined),
                  const SizedBox(height: 12),
                  CustomTextField(
                      controller: _primaryColorCtrl,
                      label: 'اللون الأساسي (#RRGGBB)',
                      prefixIcon: Icons.palette_outlined),
                  const SizedBox(height: 12),
                  CustomTextField(
                      controller: _contactPhoneCtrl,
                      label: 'هاتف التواصل',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  CustomTextField(
                      controller: _contactEmailCtrl,
                      label: 'البريد الإلكتروني',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  CustomTextField(
                      controller: _addressCtrl,
                      label: 'العنوان',
                      prefixIcon: Icons.location_on_outlined,
                      maxLines: 2),
                  const SizedBox(height: 12),
                  CustomTextField(
                      controller: _footerTextCtrl,
                      label: 'نص تذييل الفاتورة',
                      prefixIcon: Icons.text_snippet_outlined,
                      maxLines: 2),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'حفظ الإعدادات',
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}
