import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controllers.dart';
import '../../../../core/widgets/custom_text_field.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          Obx(() => TextButton(
                onPressed: () {
                  if (controller.isEditing.value) {
                    controller.updateProfile();
                  } else {
                    controller.isEditing.value = true;
                  }
                },
                child: Text(controller.isEditing.value ? 'حفظ' : 'تعديل'),
              )),
        ],
      ),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: controller.nameController,
                label: 'الاسم الكامل',
                readOnly: !controller.isEditing.value,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.phoneController,
                label: 'رقم الهاتف',
                readOnly: !controller.isEditing.value,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.addressController,
                label: 'العنوان',
                readOnly: !controller.isEditing.value,
              ),
            ],
          )),
    );
  }
}
