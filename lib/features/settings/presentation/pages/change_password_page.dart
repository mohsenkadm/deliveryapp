import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/snackbar_helper.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تغيير كلمة المرور')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(controller: _currentCtrl, label: 'كلمة المرور الحالية', obscureText: true, validator: Validators.required),
              const SizedBox(height: 16),
              CustomTextField(controller: _newCtrl, label: 'كلمة المرور الجديدة', obscureText: true, validator: Validators.password),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmCtrl,
                label: 'تأكيد كلمة المرور',
                obscureText: true,
                validator: (v) => v != _newCtrl.text ? 'كلمة المرور غير متطابقة' : null,
              ),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    text: 'تغيير',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        SnackbarHelper.showSuccess('تم تغيير كلمة المرور');
                        Get.back();
                      }
                    },
                    isLoading: _isLoading.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
