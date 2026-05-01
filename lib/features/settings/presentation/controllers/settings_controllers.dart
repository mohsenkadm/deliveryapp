import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/services/auth_service.dart';

class SettingsController extends GetxController {
  final themeController = Get.find<ThemeController>();
  final authService = Get.find<AuthService>();
}

class ProfileController extends GetxController {
  final isLoading = false.obs;
  final isEditing = false.obs;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void loadProfile() {
    final user = Get.find<AuthService>().currentUser;
    if (user != null) {
      nameController.text = user['fullName'] ?? '';
      phoneController.text = user['phone'] ?? '';
      addressController.text = user['address'] ?? '';
    }
  }

  Future<void> updateProfile() async {
    // TODO: API call
    isEditing.value = false;
  }
}
