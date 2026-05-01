// صفحة سجل المدفوعات — المندوب
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/representative_controllers.dart';

class RepPaymentsPage extends StatefulWidget {
  const RepPaymentsPage({super.key});

  @override
  State<RepPaymentsPage> createState() => _RepPaymentsPageState();
}

class _RepPaymentsPageState extends State<RepPaymentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Get.find<RepresentativeHomeController>().loadPayments());
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RepresentativeHomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المدفوعات'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: ctrl.loadPayments),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubmitPaymentSheet(context, ctrl),
        icon: const Icon(Icons.upload),
        label: const Text('تسليم للمحاسب'),
      ),
      body: Obx(() {
        if (ctrl.isLoadingPayments.value) return const LoadingIndicator();
        if (ctrl.payments.isEmpty) {
          return const EmptyState(
            icon: Icons.payments_outlined,
            title: 'لا توجد مدفوعات',
            subtitle: 'لم يتم تسجيل أي مدفوعات بعد',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.payments.length,
          itemBuilder: (ctx, i) {
            final p = ctrl.payments[i];
            final amount =
                ((p['amount'] as num?) ?? 0).toDouble();
            final date = p['createdAt'] != null
                ? Formatters.formatDate(
                    DateTime.tryParse(p['createdAt']) ?? DateTime.now())
                : '';
            final type = p['paymentType'] ?? p['type'] ?? '';
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.success.withOpacity(0.15),
                  child: Icon(Icons.payments, color: AppColors.success),
                ),
                title: Text(
                  Formatters.formatCurrency(amount),
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.success),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (type.isNotEmpty) Text(type, style: AppTextStyles.bodySmall),
                    if (date.isNotEmpty) Text(date, style: AppTextStyles.bodySmall),
                    if (p['notes'] != null && p['notes'].toString().isNotEmpty)
                      Text(p['notes'], style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showSubmitPaymentSheet(
      BuildContext ctx, RepresentativeHomeController ctrl) {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final invoiceIdCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('تسليم مبلغ للمحاسب',
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              CustomTextField(
                controller: invoiceIdCtrl,
                label: 'رقم الفاتورة (اختياري)',
                hint: 'اتركه فارغاً للتسليم الإجمالي',
                prefixIcon: Icons.receipt_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: amountCtrl,
                label: 'المبلغ',
                hint: 'أدخل المبلغ',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.payments_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'الرجاء إدخال المبلغ';
                  if (double.tryParse(v) == null || double.parse(v) <= 0) {
                    return 'مبلغ غير صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: notesCtrl,
                label: 'ملاحظات',
                hint: 'اختياري',
                prefixIcon: Icons.note_outlined,
              ),
              const SizedBox(height: 20),
              Obx(() => CustomButton(
                    text: 'تأكيد التسليم',
                    isLoading: ctrl.isActing.value,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      await ctrl.submitPayment(
                        invoiceId: invoiceIdCtrl.text.isEmpty
                            ? null
                            : invoiceIdCtrl.text,
                        amount: double.parse(amountCtrl.text),
                        notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
                      );
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
