import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../controllers/admin_controllers.dart';

/// نموذج موحَّد لإضافة/تعديل عميل (Admin).
/// - في وضع الإنشاء: يمر بدون arguments.
/// - في وضع التعديل: يمرَّر `Map<String, dynamic>` للعميل عبر `Get.arguments`.
class AdminCustomerFormPage extends StatefulWidget {
  const AdminCustomerFormPage({super.key});

  @override
  State<AdminCustomerFormPage> createState() => _AdminCustomerFormPageState();
}

class _AdminCustomerFormPageState extends State<AdminCustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _storeName = TextEditingController();
  final _region = TextEditingController();
  final _description = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();

  String _clientType = 'Individual';
  bool _submitting = false;
  String? _branchId;
  List<Map<String, dynamic>> _branches = const [];

  late final AdminRemoteDataSource _ds =
      AdminRemoteDataSource(Get.find<DioClient>());

  AdminCustomersController get _controller =>
      Get.find<AdminCustomersController>();

  Map<String, dynamic>? get _existing =>
      Get.arguments is Map<String, dynamic> ? Get.arguments as Map<String, dynamic> : null;

  bool get _isEdit => _existing != null;

  @override
  void initState() {
    super.initState();
    final c = _existing;
    if (c != null) {
      _fullName.text = (c['fullName'] ?? c['name'] ?? '').toString();
      _username.text = (c['username'] ?? '').toString();
      _phone.text = (c['phone'] ?? '').toString();
      _address.text = (c['address'] ?? '').toString();
      _storeName.text = (c['storeName'] ?? '').toString();
      _region.text = (c['region'] ?? '').toString();
      _description.text = (c['description'] ?? '').toString();
      _clientType = (c['clientType'] ?? 'Individual').toString();
      if (c['latitude'] != null) _latitude.text = c['latitude'].toString();
      if (c['longitude'] != null) _longitude.text = c['longitude'].toString();
      _branchId = c['branchId']?.toString();
    }
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final list = await _ds.getBranches(isActive: true);
      if (mounted) setState(() => _branches = list);
    } catch (_) {}
  }

  @override
  void dispose() {
    _fullName.dispose();
    _username.dispose();
    _password.dispose();
    _phone.dispose();
    _address.dispose();
    _storeName.dispose();
    _region.dispose();
    _description.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final lat = double.tryParse(_latitude.text.trim());
    final lng = double.tryParse(_longitude.text.trim());
    final payload = <String, dynamic>{
      'fullName': _fullName.text.trim(),
      'phone': _phone.text.trim(),
      'address': _address.text.trim(),
      if (_storeName.text.trim().isNotEmpty) 'storeName': _storeName.text.trim(),
      if (_region.text.trim().isNotEmpty) 'region': _region.text.trim(),
      if (_description.text.trim().isNotEmpty)
        'description': _description.text.trim(),
      'clientType': _clientType,
      if (lat != null) 'latitude': lat,
      if (lng != null) 'longitude': lng,
      if (_branchId != null) 'branchId': int.tryParse(_branchId!) ?? _branchId,
    };

    if (_isEdit) {
      final id = _existing!['id'].toString();
      // اسم المستخدم/كلمة السر اختياريون عند التعديل
      if (_username.text.trim().isNotEmpty) payload['username'] = _username.text.trim();
      if (_password.text.trim().isNotEmpty) payload['password'] = _password.text.trim();
      final ok = await _controller.updateCustomer(id, payload);
      if (ok && mounted) Get.back();
    } else {
      payload['username'] = _username.text.trim();
      payload['password'] = _password.text.trim();
      final ok = await _controller.createCustomer(payload);
      if (ok && mounted) Get.back();
    }

    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل عميل' : 'إضافة عميل',
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
                controller: _phone,
                label: 'رقم الهاتف',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.required,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _address,
                label: 'العنوان',
                prefixIcon: Icons.location_on_outlined,
                validator: Validators.required,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _storeName,
                label: 'اسم المتجر (اختياري)',
                prefixIcon: Icons.store_outlined,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _region,
                label: 'المنطقة (اختياري)',
                prefixIcon: Icons.map_outlined,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _description,
                label: 'وصف (اختياري)',
                prefixIcon: Icons.description_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _username,
                label: _isEdit
                    ? 'اسم المستخدم (اتركه فارغاً للإبقاء)'
                    : 'اسم المستخدم',
                prefixIcon: Icons.account_circle_outlined,
                validator: _isEdit ? null : Validators.required,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _password,
                label: _isEdit
                    ? 'كلمة المرور (اتركها فارغة للإبقاء)'
                    : 'كلمة المرور',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: _isEdit ? null : Validators.required,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.category_outlined, size: 20),
                    const SizedBox(width: 10),
                    Text('نوع العميل:',
                        style: GoogleFonts.cairo(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    ChoiceChip(
                      label: const Text('مفرد'),
                      selected: _clientType == 'Individual',
                      onSelected: (_) =>
                          setState(() => _clientType = 'Individual'),
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('جملة'),
                      selected: _clientType == 'Wholesale',
                      onSelected: (_) =>
                          setState(() => _clientType = 'Wholesale'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _branchId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'الفرع (اختياري)',
                  labelStyle: GoogleFonts.cairo(),
                  prefixIcon:
                      const Icon(Icons.store_mall_directory_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: CustomTextField(
                    controller: _latitude,
                    label: 'خط العرض (Lat)',
                    prefixIcon: Icons.my_location_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _longitude,
                    label: 'خط الطول (Lng)',
                    prefixIcon: Icons.location_searching_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              CustomButton(
                text: _isEdit ? 'حفظ التعديلات' : 'إضافة العميل',
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
