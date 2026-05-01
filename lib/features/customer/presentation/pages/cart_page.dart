import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controllers/customer_controllers.dart';
import '../widgets/cart_item_tile.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السلة')),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return const EmptyState(title: 'السلة فارغة', subtitle: 'أضف منتجات إلى السلة لبدء الطلب', icon: Icons.shopping_cart_outlined);
        }
        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final item = controller.cartItems[index];
                  return CartItemTile(
                    cartItem: item,
                    onQuantityChanged: (qty) => controller.updateQuantity(item.product.id, qty),
                    onRemove: () => controller.removeFromCart(item.product.id),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: Column(
                children: [
                  _buildRow('المجموع الفرعي', Formatters.currency(controller.subtotal), context),
                  const SizedBox(height: 8),
                  _buildRow('رسوم التوصيل', Formatters.currency(controller.deliveryFee), context),
                  const Divider(height: 20),
                  _buildRow('الإجمالي', Formatters.currency(controller.total), context, isBold: true),
                  const SizedBox(height: 16),
                  CustomButton(text: 'إتمام الطلب', onPressed: () => Get.toNamed(AppRoutes.checkout)),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRow(String label, String value, BuildContext context, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        Text(value, style: GoogleFonts.cairo(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, color: isBold ? Theme.of(context).colorScheme.primary : null)),
      ],
    );
  }
}
