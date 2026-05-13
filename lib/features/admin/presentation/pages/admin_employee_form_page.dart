// نموذج موحَّد لإضافة/تعديل موظف (Admin)
// يدعم: تعدد الأدوار (Roles CSV)، المناطق (AssignedAreas CSV)،
// نوع الموظف/المندوب، الفرع، السيارة، رفع صور (الهوية والصورة الشخصية)
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/employee_roles.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class AdminEmployeeFormPage extends StatefulWidget {
  const AdminEmployeeFormPage({super.key});

  @override
  State<AdminEmployeeFormPage> createState() => _AdminEmployeeFormPageState();
}

class _AdminEmployeeFormPageState extends State<AdminEmployeeFormPage> {
  late final AdminRemoteDataSource _ds;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Controllers
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _carNumber = TextEditingController();
  final _carType = TextEditingController();
  final _region = TextEditingController();
  final _branch = TextEditingController();
  final _areaInput = TextEditingController();

  // State
  bool _isActive = true;
  String _employeeType = 'Individual';
  String? _representativeType;
  String? _branchId;
  final Set<String> _selectedRoles = <String>{};
  final List<String> _areas = <String>[];
  File? _idImage;
  File? _photoImage;
  String? _existingIdImageUrl;
  String? _existingPhotoUrl;

  // Loaded data
  bool _loading = true;
  bool _submitting = false;
  List<Map<String, dynamic>> _branches = const [];

  Map<String, dynamic>? get _existing =>
      Get.arguments is Map<String, dynamic>
          ? Get.arguments as Map<String, dynamic>
          : null;
  bool get _isEdit => _existing != null;

  @override
  void initState() {
    super.initState();
    _ds = AdminRemoteDataSource(Get.find<DioClient>());
    _hydrate();
    _loadBranches();
  }

  void _hydrate() {
    final c = _existing;
    if (c == null) return;
    _fullName.text = (c['fullName'] ?? '').toString();
    _phone.text = (c['phone'] ?? '').toString();
    _address.text = (c['address'] ?? '').toString();
    _username.text = (c['username'] ?? '').toString();
    _carNumber.text = (c['carNumber'] ?? '').toString();
    _carType.text = (c['carType'] ?? '').toString();
    _region.text = (c['region'] ?? '').toString();
    _branch.text = (c['branch'] ?? '').toString();
    _isActive = c['isActive'] != false;
    _employeeType = (c['employeeType'] ?? 'Individual').toString();
    _representativeType = c['representativeType']?.toString();
    _branchId = c['branchId']?.toString();
    _existingIdImageUrl = c['idImagePath']?.toString();
    _existingPhotoUrl = c['photoPath']?.toString();

    final rolesRaw = c['roles'] ?? c['rolesList'] ?? '';
    if (rolesRaw is List) {
      _selectedRoles
          .addAll(rolesRaw.map((e) => e.toString()).where((e) => e.isNotEmpty));
    } else if (rolesRaw is String && rolesRaw.isNotEmpty) {
      _selectedRoles.addAll(rolesRaw.split(',').map((e) => e.trim()));
    }

    final areasRaw = c['assignedAreas'] ?? c['areasList'] ?? '';
    if (areasRaw is List) {
      _areas.addAll(areasRaw.map((e) => e.toString()));
    } else if (areasRaw is String && areasRaw.isNotEmpty) {
      _areas.addAll(areasRaw.split(',').map((e) => e.trim()));
    }
  }

  Future<void> _loadBranches() async {
    try {
      _branches = await _ds.getBranches(isActive: true);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _address.dispose();
    _username.dispose();
    _password.dispose();
    _carNumber.dispose();
    _carType.dispose();
    _region.dispose();
    _branch.dispose();
    _areaInput.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isId) async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      if (isId) {
        _idImage = File(picked.path);
      } else {
        _photoImage = File(picked.path);
      }
    });
  }

  void _addArea() {
    final v = _areaInput.text.trim();
    if (v.isEmpty) return;
    setState(() {
      if (!_areas.contains(v)) _areas.add(v);
      _areaInput.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoles.isEmpty) {
      SnackbarHelper.showError('اختر دوراً واحداً على الأقل');
      return;
    }

    setState(() => _submitting = true);
    try {
      final fields = <String, dynamic>{
        'fullName': _fullName.text.trim(),
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
        'isActive': _isActive,
        'employeeType': _employeeType,
        if (_representativeType != null && _employeeType == 'Representative')
          'representativeType': _representativeType,
        'roles': _selectedRoles.join(','),
        if (_areas.isNotEmpty) 'assignedAreas': _areas.join(','),
        if (_carNumber.text.trim().isNotEmpty)
          'carNumber': _carNumber.text.trim(),
        if (_carType.text.trim().isNotEmpty)
          'carType': _carType.text.trim(),
        if (_region.text.trim().isNotEmpty) 'region': _region.text.trim(),
        if (_branch.text.trim().isNotEmpty) 'branch': _branch.text.trim(),
        if (_branchId != null) 'branchId': int.tryParse(_branchId!) ?? _branchId,
      };

      if (_isEdit) {
        if (_username.text.trim().isNotEmpty) {
          fields['username'] = _username.text.trim();
        }
        if (_password.text.trim().isNotEmpty) {
          fields['password'] = _password.text.trim();
        }
      } else {
        fields['username'] = _username.text.trim();
        fields['password'] = _password.text.trim();
      }

      // Use multipart only if at least one image was picked.
      final hasImages = _idImage != null || _photoImage != null;
      dynamic payload;
      if (hasImages) {
        final formData = dio.FormData();
        fields.forEach((k, v) => formData.fields.add(MapEntry(k, '$v')));
        if (_idImage != null) {
          formData.files.add(MapEntry(
              'idImage', await dio.MultipartFile.fromFile(_idImage!.path)));
        }
        if (_photoImage != null) {
          formData.files.add(MapEntry(
              'photo', await dio.MultipartFile.fromFile(_photoImage!.path)));
        }
        payload = formData;
      } else {
        payload = fields;
      }

      if (_isEdit) {
        await _ds.updateEmployee(_existing!['id'].toString(), payload);
        SnackbarHelper.showSuccess('تم تحديث الموظف');
      } else {
        await _ds.createEmployee(payload);
        SnackbarHelper.showSuccess('تم إنشاء الموظف');
      }
      if (mounted) Get.back(result: true);
    } catch (_) {
      SnackbarHelper.showError(_isEdit ? 'فشل التحديث' : 'فشل الإنشاء');
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل موظف' : 'إضافة موظف',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('البيانات الأساسية'),
                    CustomTextField(
                      controller: _fullName,
                      label: 'الاسم الكامل',
                      prefixIcon: Icons.person_outline,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _phone,
                      label: 'رقم الهاتف',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _address,
                      label: 'العنوان',
                      prefixIcon: Icons.location_on_outlined,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _username,
                      label: _isEdit
                          ? 'اسم المستخدم (اتركه فارغاً للإبقاء)'
                          : 'اسم المستخدم',
                      prefixIcon: Icons.account_circle_outlined,
                      validator: _isEdit ? null : Validators.required,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _password,
                      label: _isEdit
                          ? 'كلمة المرور (اتركها فارغة للإبقاء)'
                          : 'كلمة المرور',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: _isEdit ? null : Validators.password,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      title: Text('فعّال',
                          style:
                              GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                    ),

                    _section('نوع الموظف'),
                    Wrap(spacing: 6, children: [
                      for (final t in const ['Individual', 'Representative', 'Wholesale'])
                        ChoiceChip(
                          label: Text(_typeLabel(t)),
                          selected: _employeeType == t,
                          onSelected: (_) =>
                              setState(() => _employeeType = t),
                        ),
                    ]),
                    if (_employeeType == 'Representative') ...[
                      const SizedBox(height: 8),
                      Text('نوع المندوب',
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Wrap(spacing: 6, children: [
                        ChoiceChip(
                          label: const Text('مفرد'),
                          selected: _representativeType == 'Individual',
                          onSelected: (_) => setState(
                              () => _representativeType = 'Individual'),
                        ),
                        ChoiceChip(
                          label: const Text('جملة'),
                          selected: _representativeType == 'Wholesale',
                          onSelected: (_) => setState(
                              () => _representativeType = 'Wholesale'),
                        ),
                      ]),
                    ],

                    _section('الأدوار (يمكن اختيار أكثر من دور)'),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: EmployeeRoles.all
                          .where((r) =>
                              r != EmployeeRoles.admin &&
                              r != EmployeeRoles.customer)
                          .map((r) => FilterChip(
                                label: Text(_roleLabel(r)),
                                selected: _selectedRoles.contains(r),
                                onSelected: (s) => setState(() {
                                  if (s) {
                                    _selectedRoles.add(r);
                                  } else {
                                    _selectedRoles.remove(r);
                                  }
                                }),
                              ))
                          .toList(),
                    ),

                    _section('المناطق المعينة'),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _areaInput,
                          decoration: InputDecoration(
                            hintText: 'اسم المنطقة (مثلاً: بغداد)',
                            hintStyle: GoogleFonts.cairo(),
                            isDense: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          onSubmitted: (_) => _addArea(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                          onPressed: _addArea,
                          icon: const Icon(Icons.add)),
                    ]),
                    if (_areas.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _areas
                            .map((a) => Chip(
                                  label: Text(a),
                                  onDeleted: () =>
                                      setState(() => _areas.remove(a)),
                                ))
                            .toList(),
                      ),
                    ],

                    _section('الفرع'),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _branchId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'اختر الفرع (اختياري)',
                        hintStyle: GoogleFonts.cairo(),
                        prefixIcon:
                            const Icon(Icons.store_mall_directory_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                            value: null, child: Text('— بدون —')),
                        ..._branches.map((b) => DropdownMenuItem(
                              value: b['id']?.toString(),
                              child: Text((b['name'] ?? '').toString(),
                                  style: GoogleFonts.cairo()),
                            )),
                      ],
                      onChanged: (v) => setState(() => _branchId = v),
                    ),

                    if (_selectedRoles.contains(EmployeeRoles.driver)) ...[
                      _section('بيانات السيارة'),
                      CustomTextField(
                        controller: _carNumber,
                        label: 'رقم السيارة',
                        prefixIcon: Icons.confirmation_number_outlined,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _carType,
                        label: 'نوع السيارة',
                        prefixIcon: Icons.directions_car_outlined,
                      ),
                    ],

                    _section('بيانات إضافية'),
                    CustomTextField(
                      controller: _region,
                      label: 'المنطقة (نص حر)',
                      prefixIcon: Icons.map_outlined,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _branch,
                      label: 'اسم الفرع (نص حر)',
                      prefixIcon: Icons.business_outlined,
                    ),

                    _section('الصور'),
                    Row(children: [
                      Expanded(
                        child: _ImageSlot(
                          label: 'صورة الهوية',
                          file: _idImage,
                          existingUrl: _existingIdImageUrl,
                          onPick: () => _pickImage(true),
                          onClear: () => setState(() => _idImage = null),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ImageSlot(
                          label: 'الصورة الشخصية',
                          file: _photoImage,
                          existingUrl: _existingPhotoUrl,
                          onPick: () => _pickImage(false),
                          onClear: () => setState(() => _photoImage = null),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 24),
                    CustomButton(
                      text: _isEdit ? 'حفظ التعديلات' : 'إنشاء الموظف',
                      onPressed: _submit,
                      isLoading: _submitting,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Text(title,
            style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary)),
      );

  String _typeLabel(String t) {
    switch (t) {
      case 'Representative':
        return 'مندوب';
      case 'Wholesale':
        return 'جملة';
      default:
        return 'مفرد';
    }
  }

  String _roleLabel(String r) {
    const map = {
      'SystemManager': 'مدير النظام',
      'Manager': 'مدير',
      'SalesManager': 'مدير مبيعات',
      'Supervisor': 'مشرف',
      'Representative': 'مندوب',
      'Driver': 'سائق',
      'WarehouseKeeper': 'أمين مستودع',
      'Cashier': 'كاشير',
      'Accountant': 'محاسب',
      'Employee': 'موظف عام',
    };
    return map[r] ?? r;
  }
}

class _ImageSlot extends StatelessWidget {
  final String label;
  final File? file;
  final String? existingUrl;
  final VoidCallback onPick;
  final VoidCallback onClear;
  const _ImageSlot({
    required this.label,
    required this.file,
    required this.existingUrl,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;
    final hasExisting = existingUrl != null && existingUrl!.isNotEmpty;
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.dividerLight, style: BorderStyle.solid),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: hasFile
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(file!, fit: BoxFit.cover),
                    )
                  : hasExisting
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(existingUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _placeholder(label)),
                        )
                      : _placeholder(label),
            ),
            if (hasFile)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onClear,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(String text) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined,
                size: 36, color: AppColors.textSecondary),
            const SizedBox(height: 6),
            Text(text,
                style: GoogleFonts.cairo(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      );
}
