import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/location_picker_map.dart';
import '../controllers/representative_controllers.dart';

class RegisterCustomerPage extends StatefulWidget {
  const RegisterCustomerPage({super.key});

  @override
  State<RegisterCustomerPage> createState() => _RegisterCustomerPageState();
}

class _RegisterCustomerPageState extends State<RegisterCustomerPage> {
  final _picker = ImagePicker();
  final _mapKey = GlobalKey<LocationPickerMapState>();
  RepresentativeHomeController get controller =>
      Get.find<RepresentativeHomeController>();

  XFile? _photo;
  LatLng? _location;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.find<AuthService>().canAddCustomersEffective) {
        SnackbarHelper.showError('غير مصرح لك بإضافة عملاء');
        Get.back();
      }
    });
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file != null) setState(() => _photo = file);
    } catch (_) {
      SnackbarHelper.showError('تعذّر اختيار الصورة');
    }
  }

  Future<void> _submit() async {
    if (!Get.find<AuthService>().canAddCustomersEffective) {
      SnackbarHelper.showError('غير مصرح لك بإضافة عملاء');
      return;
    }
    if (!controller.registerFormKey.currentState!.validate()) return;
    if (_photo == null) {
      SnackbarHelper.showError('يرجى التقاط صورة المتجر');
      return;
    }

    controller.isActing.value = true;
    try {
      // التقاط GPS الحالي لحظة الحفظ — لا نعتمد على إحداثيات قديمة في الذاكرة.
      final mapState = _mapKey.currentState;
      LatLng? point = await mapState?.locateMe(showErrors: true);
      point ??= (_location != null && (mapState?.hasUserLocation ?? false))
          ? _location
          : null;
      if (point == null) {
        SnackbarHelper.showError(
          'يلزم تحديد موقعك الحالي قبل الحفظ. اضغط «تحديد موقعي الآن» أو أعد المحاولة.',
        );
        return;
      }
      setState(() => _location = point);

      await controller.addCustomerWithPhoto(
        fullName: controller.nameController.text.trim(),
        storeName: controller.storeNameController.text.trim(),
        phone: controller.phoneController.text.trim(),
        address: controller.addressController.text.trim(),
        region: controller.regionController.text.trim(),
        clientType: controller.clientType.value,
        latitude: point.latitude,
        longitude: point.longitude,
        photoPath: _photo!.path,
      );
      controller.nameController.clear();
      controller.storeNameController.clear();
      controller.phoneController.clear();
      controller.addressController.clear();
      controller.regionController.clear();
      setState(() {
        _photo = null;
        _location = null;
      });
      Get.back();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackbarHelper.showSuccess(
            'تم حفظ بيانات العميل بنجاح. سيتم تفعيل الحساب بعد موافقة الإدارة.');
        controller.loadCustomers();
      });
    } catch (e) {
      SnackbarHelper.handleApiError(e, 'فشل إضافة العميل');
    } finally {
      controller.isActing.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل عميل جديد',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.registerFormKey,
          child: Column(
            children: [
              CustomTextField(
                controller: controller.nameController,
                label: 'الاسم الكامل',
                prefixIcon: Icons.person,
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.storeNameController,
                label: 'اسم المتجر',
                prefixIcon: Icons.store,
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.phoneController,
                label: 'رقم الهاتف',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.addressController,
                label: 'العنوان',
                prefixIcon: Icons.location_on,
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.regionController,
                label: 'المنطقة',
                prefixIcon: Icons.map,
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
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
                          selected: controller.clientType.value == 'Retail',
                          onSelected: (_) =>
                              controller.clientType.value = 'Retail',
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: const Text('جملة'),
                          selected:
                              controller.clientType.value == 'Wholesale',
                          onSelected: (_) =>
                              controller.clientType.value = 'Wholesale',
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              Text('صورة المتجر',
                  style: GoogleFonts.cairo(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (_photo != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_photo!.path),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Icon(Icons.storefront_outlined,
                      size: 48, color: Colors.grey.shade400),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickPhoto(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: Text('التقاط', style: GoogleFonts.cairo()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickPhoto(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: Text('المعرض', style: GoogleFonts.cairo()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LocationPickerMap(
                key: _mapKey,
                initialLatitude: _location?.latitude,
                initialLongitude: _location?.longitude,
                onLocationChanged: (p) => setState(() => _location = p),
              ),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    text: 'تسجيل العميل',
                    onPressed: _submit,
                    isLoading: controller.isActing.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
