import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/representative_controllers.dart';

class RegisterCustomerPage extends GetView<RepresentativeHomeController> {
  const RegisterCustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل عميل جديد', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
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
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    text: 'تسجيل العميل',
                    onPressed: controller.addCustomer,
                    isLoading: controller.isActing.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
