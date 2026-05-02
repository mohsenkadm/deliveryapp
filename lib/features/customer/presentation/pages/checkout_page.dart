import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/customer_controllers.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final notesController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ملخص المنتجات ──
            Text('المنتجات', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ...cartController.cartItems.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.product.name} × ${item.quantity}',
                                  style: GoogleFonts.cairo(fontSize: 14),
                                ),
                              ),
                              Text(
                                Formatters.currency(item.total),
                                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        if (i < cartController.cartItems.length - 1)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── الإجماليات ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _row('المجموع الفرعي', Formatters.currency(cartController.subtotal)),
                  const SizedBox(height: 8),
                  _row('رسوم التوصيل', Formatters.currency(cartController.deliveryFee)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: AppColors.dividerLight),
                  ),
                  _row('الإجمالي', Formatters.currency(cartController.total), isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── العنوان (اختياري) ──
            CustomTextField(
              label: 'عنوان التوصيل (اختياري)',
              hint: 'أدخل عنوان التوصيل',
              controller: addressController,
              prefixIcon: Icons.location_on_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // ── ملاحظات ──
            CustomTextField(
              label: 'ملاحظات (اختياري)',
              hint: 'أضف ملاحظات للطلب...',
              controller: notesController,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // ── زر التأكيد ──
            Obx(() => CustomButton(
                  text: 'تأكيد الطلب',
                  icon: Icons.check_circle_outline,
                  isLoading: cartController.isSubmitting.value,
                  onPressed: () => cartController.checkout(
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                    address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                  ),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        Text(value,
            style: GoogleFonts.cairo(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: isBold ? AppColors.primary : null)),
      ],
    );
  }
}
