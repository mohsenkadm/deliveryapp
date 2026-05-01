// صفحة تحصيل دفعة من العميل — السائق
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/driver_controllers.dart';

class DriverCollectPaymentPage extends StatefulWidget {
  const DriverCollectPaymentPage({super.key});

  @override
  State<DriverCollectPaymentPage> createState() =>
      _DriverCollectPaymentPageState();
}

class _DriverCollectPaymentPageState extends State<DriverCollectPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late final String _orderId;

  @override
  void initState() {
    super.initState();
    _orderId = Get.arguments as String? ?? '';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DriverHomeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('تحصيل دفعة من العميل')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text('رقم الطلب: $_orderId',
                        style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _amountCtrl,
                label: 'المبلغ المحصّل',
                hint: 'أدخل المبلغ',
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
                hint: 'أي ملاحظات عن الدفعة',
                maxLines: 3,
                prefixIcon: Icons.note_outlined,
              ),
              const SizedBox(height: 32),
              Obx(() => CustomButton(
                    text: 'تأكيد تحصيل الدفعة',
                    isLoading: ctrl.isActing.value,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      await ctrl.collectPayment(
                        _orderId,
                        double.parse(_amountCtrl.text),
                        _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
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
