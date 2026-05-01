import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/datasources/customer_remote_datasource.dart';
import '../../data/repositories/customer_repository.dart';
import '../controllers/customer_controllers.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final notesController = TextEditingController();
    final isLoading = false.obs;

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ملخص الطلب', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...cartController.cartItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${item.product.name} × ${item.quantity}', style: GoogleFonts.cairo(fontSize: 14))),
                      Text(Formatters.currency(item.total), style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
            const Divider(),
            _row('المجموع الفرعي', Formatters.currency(cartController.subtotal)),
            _row('رسوم التوصيل', Formatters.currency(cartController.deliveryFee)),
            const Divider(),
            _row('الإجمالي', Formatters.currency(cartController.total), isBold: true),
            const SizedBox(height: 24),
            CustomTextField(label: 'ملاحظات (اختياري)', hint: 'أضف ملاحظات للطلب...', controller: notesController, maxLines: 3),
            const SizedBox(height: 32),
            Obx(() => CustomButton(
                  text: 'تأكيد الطلب',
                  isLoading: isLoading.value,
                  onPressed: () async {
                    isLoading.value = true;
                    final ds = CustomerRemoteDataSource(Get.find<DioClient>());
                    final repo = CustomerRepository(ds);
                    final items = cartController.cartItems
                        .map((e) => {'productId': e.product.id, 'quantity': e.quantity})
                        .toList();
                    final result = await repo.createOrder(items: items, notes: notesController.text.trim().isEmpty ? null : notesController.text.trim());
                    isLoading.value = false;
                    result.fold(
                      (f) => SnackbarHelper.showError(f.message),
                      (_) {
                        cartController.clearCart();
                        SnackbarHelper.showSuccess('تم تأكيد الطلب بنجاح');
                        Get.back();
                        Get.back();
                      },
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
          Text(value, style: GoogleFonts.cairo(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w600)),
        ],
      ),
    );
  }
}
