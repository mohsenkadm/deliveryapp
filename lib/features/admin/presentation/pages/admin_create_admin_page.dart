// صفحة إضافة أدمن جديد — POST /api/admin/add-admin
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class AdminCreateAdminPage extends StatefulWidget {
  const AdminCreateAdminPage({super.key});

  @override
  State<AdminCreateAdminPage> createState() => _AdminCreateAdminPageState();
}

class _AdminCreateAdminPageState extends State<AdminCreateAdminPage> {
  late final AdminRemoteDataSource _ds;
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
  }

  @override
  void dispose() {
    _fullName.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await _ds.createAdmin({
        'fullName': _fullName.text.trim(),
        'username': _username.text.trim(),
        'password': _password.text.trim(),
      });
      SnackbarHelper.showSuccess('تم إضافة الأدمن');
      if (mounted) Get.back(result: true);
    } catch (_) {
      SnackbarHelper.showError('فشل إضافة الأدمن');
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إضافة مسؤول',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _fullName,
                label: 'الاسم الكامل',
                prefixIcon: Icons.person_outline,
                validator: Validators.required,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _username,
                label: 'اسم المستخدم',
                prefixIcon: Icons.account_circle_outlined,
                validator: Validators.required,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _password,
                label: 'كلمة المرور',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'إضافة المسؤول',
                onPressed: _submit,
                isLoading: _submitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
