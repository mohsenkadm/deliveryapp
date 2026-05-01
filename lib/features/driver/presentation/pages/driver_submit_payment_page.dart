// صفحة تسليم نقدية للشركة — السائق
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/driver_controllers.dart';

class DriverSubmitPaymentPage extends StatefulWidget {
  const DriverSubmitPaymentPage({super.key});

  @override
  State<DriverSubmitPaymentPage> createState() =>
      _DriverSubmitPaymentPageState();
}

class _DriverSubmitPaymentPageState extends State<DriverSubmitPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _invoiceIdCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _invoiceIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DriverHomeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('تسليم نقدية للشركة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تسليم مبلغ نقدي',
                          style: AppTextStyles.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'سيتم تسجيل المبلغ المُسلَّم للمحاسب في سجلات الشركة.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _invoiceIdCtrl,
                label: 'رقم الفاتورة (اختياري)',
                hint: 'اتركه فارغاً إذا كان إجمالياً',
                prefixIcon: Icons.receipt_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _amountCtrl,
                label: 'المبلغ المُسلَّم',
                hint: 'أدخل المبلغ الإجمالي',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.payments_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'الرجاء إدخال المبلغ';
                  if (double.tryParse(v) == null || double.parse(v) <= 0) {
                    return 'الرجاء إدخال مبلغ صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notesCtrl,
                label: 'ملاحظات (اختياري)',
                hint: 'أي ملاحظات',
                maxLines: 3,
                prefixIcon: Icons.note_outlined,
              ),
              const SizedBox(height: 32),
              Obx(() => CustomButton(
                    text: 'تأكيد التسليم',
                    isLoading: ctrl.isActing.value,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      await ctrl.submitPayment(
                        invoiceId: _invoiceIdCtrl.text.isEmpty
                            ? null
                            : _invoiceIdCtrl.text,
                        amount: double.parse(_amountCtrl.text),
                        notes: _notesCtrl.text.isEmpty
                            ? null
                            : _notesCtrl.text,
                      );
                      if (!ctrl.isActing.value) Get.back();
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
