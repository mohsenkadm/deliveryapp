import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/representative_controllers.dart';

class CollectPaymentPage extends GetView<RepresentativeHomeController> {
  const CollectPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customer = Get.arguments as Map<String, dynamic>? ?? {};
    final customerId = customer['id']?.toString() ?? '';
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('تحصيل دفعة', style: GoogleFonts.cairo(fontWeight: FontWeight.w700))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (customer.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 40),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer['fullName'] ?? '', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600)),
                            Text(customer['phone'] ?? '', style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: amountController,
                label: 'المبلغ (د.ع)',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: notesController,
                label: 'ملاحظات (اختياري)',
                prefixIcon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    text: 'تأكيد التحصيل',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final amount = double.tryParse(amountController.text.trim()) ?? 0;
                        controller.collectPayment(
                          customerId: customerId.isEmpty ? null : customerId,
                          amount: amount,
                          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                        );
                      }
                    },
                    isLoading: controller.isActing.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
