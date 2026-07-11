import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/representative_controllers.dart';

class CollectPaymentPage extends GetView<RepresentativeHomeController> {
  const CollectPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final isInvoiceContext = args.containsKey('totalAmount') ||
        args.containsKey('remainingAmount') ||
        args.containsKey('invoiceNumber');
    final invoiceId =
        isInvoiceContext ? args['id']?.toString() : null;
    final customerId = args['customerId']?.toString() ??
        args['customer']?['id']?.toString() ??
        (isInvoiceContext ? null : args['id']?.toString()) ??
        '';
    final customerName = args['fullName'] ??
        args['customerName'] ??
        args['customer']?['fullName'] ??
        '';
    final customerPhone =
        args['phone'] ?? args['customerPhone'] ?? args['customer']?['phone'];
    final totalDebt = (args['totalDebt'] as num?)?.toDouble();
    final remaining = (args['remainingAmount'] as num?)?.toDouble();
    final suggestedAmount = remaining ?? totalDebt;
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(
      text: suggestedAmount != null && suggestedAmount > 0
          ? suggestedAmount.toStringAsFixed(0)
          : '',
    );
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
              if (args.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customerName,
                                  style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              if (customerPhone != null)
                                Text(customerPhone.toString(),
                                    style: GoogleFonts.cairo(
                                        fontSize: 13, color: Colors.grey)),
                              if (invoiceId != null)
                                Text('فاتورة #$invoiceId',
                                    style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: Colors.grey)),
                              if (suggestedAmount != null &&
                                  suggestedAmount > 0)
                                Text(
                                  isInvoiceContext
                                      ? 'المتبقي: ${Formatters.formatCurrency(suggestedAmount)}'
                                      : 'المديونية: ${Formatters.formatCurrency(suggestedAmount)}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                            ],
                          ),
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
                          invoiceId:
                              invoiceId?.isEmpty == true ? null : invoiceId,
                          customerId: customerId.isEmpty ? null : customerId,
                          amount: amount,
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
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
