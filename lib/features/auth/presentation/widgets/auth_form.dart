import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';

class AuthForm extends GetView<AuthController> {
  final bool showPasswordToggle;

  const AuthForm({super.key, this.showPasswordToggle = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'اسم المستخدم أو رقم الهاتف',
          hint: 'أدخل اسم المستخدم أو 07XXXXXXXX',
          controller: controller.usernameController,
          validator: Validators.required,
          keyboardType: TextInputType.text,
          prefixIcon: Icons.person_outlined,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Obx(() => CustomTextField(
              label: 'كلمة المرور',
              hint: 'أدخل كلمة المرور',
              controller: controller.passwordController,
              validator: Validators.password,
              obscureText: controller.obscurePassword.value,
              prefixIcon: Icons.lock_outlined,
              textInputAction: TextInputAction.done,
              suffixIcon: showPasswordToggle
                  ? IconButton(
                      icon: Icon(
                        controller.obscurePassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          controller.obscurePassword.toggle(),
                    )
                  : null,
            )),
      ],
    );
  }
}
