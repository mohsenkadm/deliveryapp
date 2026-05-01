import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/customer_entities.dart';
import '../controllers/customer_controllers.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final product = Get.arguments['product'] as Product;
    final cartController = Get.find<CartController>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: product.imageUrl != null
                  ? CachedNetworkImage(imageUrl: product.imageUrl!, fit: BoxFit.cover)
                  : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 60, color: Colors.grey)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(product.name, style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.isAvailable ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.isAvailable ? 'متوفر' : 'غير متوفر',
                          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: product.isAvailable ? Colors.green : Colors.red),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: 8),
                  if (product.categoryName != null)
                    Text(product.categoryName!, style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (product.discountPrice != null) ...[
                        Text(Formatters.currency(product.price), style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 12),
                        Text(Formatters.currency(product.discountPrice!), style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                      ] else
                        Text(Formatters.currency(product.price), style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('الوصف', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    product.description ?? 'لا يوجد وصف لهذا المنتج',
                    style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600], height: 1.6),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'أضف إلى السلة',
                    icon: Icons.add_shopping_cart,
                    onPressed: product.isAvailable ? () => cartController.addToCart(product) : null,
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
