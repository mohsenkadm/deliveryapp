import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/driver_controllers.dart';

class DriverPaymentsPage extends StatefulWidget {
  const DriverPaymentsPage({super.key});

  @override
  State<DriverPaymentsPage> createState() => _DriverPaymentsPageState();
}

class _DriverPaymentsPageState extends State<DriverPaymentsPage> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DriverHomeController>().loadDriverPayments();
    });
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
      appBar: AppBar(
        title: const Text('تسليم المبالغ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ctrl.loadDriverPayments(),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoadingDriverPayments.value &&
            ctrl.driverPayments.isEmpty) {
          return const LoadingIndicator();
        }
        return RefreshIndicator(
          onRefresh: () => ctrl.loadDriverPayments(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('تسليم للشركة',
                          style: GoogleFonts.cairo(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _amountCtrl,
                        label: 'المبلغ (د.ع)',
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _notesCtrl,
                        label: 'ملاحظات (اختياري)',
                        prefixIcon: Icons.note,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Obx(() => CustomButton(
                            text: 'تأكيد التسليم',
                            isLoading: ctrl.isActing.value,
                            onPressed: () {
                              final amount =
                                  double.tryParse(_amountCtrl.text.trim()) ??
                                      0;
                              if (amount <= 0) return;
                              ctrl.submitDriverPayments(
                                amount: amount,
                                notes: _notesCtrl.text.trim().isEmpty
                                    ? null
                                    : _notesCtrl.text.trim(),
                              );
                            },
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('سجل المدفوعات',
                  style: GoogleFonts.cairo(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              if (ctrl.driverPayments.isEmpty)
                const EmptyState(
                  icon: Icons.payments_outlined,
                  title: 'لا توجد مدفوعات',
                )
              else
                ...ctrl.driverPayments.map((p) {
                  final verified = p['isVerified'] == true;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        Formatters.currency(
                            (p['amount'] as num?)?.toDouble() ?? 0),
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        p['createdAt']?.toString().substring(0, 10) ?? '',
                        style: GoogleFonts.cairo(fontSize: 12),
                      ),
                      trailing: Chip(
                        label: Text(verified ? 'مُحقّق' : 'قيد التحقق',
                            style: GoogleFonts.cairo(fontSize: 11)),
                        backgroundColor: verified
                            ? AppColors.success.withValues(alpha: 0.12)
                            : Colors.orange.withValues(alpha: 0.12),
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      }),
    );
  }
}
