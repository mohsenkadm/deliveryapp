import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/datasources/customer_remote_datasource.dart';
import '../../domain/entities/customer_entities.dart';
import '../controllers/customer_controllers.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late final Product _product;
  late final CartController _cartController;
  late final CustomerRemoteDataSource _ds;
  List<Map<String, dynamic>> _offers = const [];
  bool _loadingOffers = true;

  @override
  void initState() {
    super.initState();
    _product = Get.arguments['product'] as Product;
    _cartController = Get.find<CartController>();
    _ds = CustomerRemoteDataSource(Get.find<DioClient>());
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    try {
      final list = await _ds.checkOffers(productId: _product.id.toString());
      if (mounted) setState(() => _offers = list);
    } catch (_) {}
    if (mounted) setState(() => _loadingOffers = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _product.imageUrl != null
                  ? CachedNetworkImage(imageUrl: _product.imageUrl!, fit: BoxFit.cover)
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
                        child: Text(_product.name, style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _product.isAvailable ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _product.isAvailable ? 'متوفر' : 'غير متوفر',
                          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: _product.isAvailable ? Colors.green : Colors.red),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: 8),
                  if (_product.categoryName != null)
                    Text(_product.categoryName!, style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_product.discountPrice != null) ...[
                        Text(Formatters.currency(_product.price), style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 12),
                        Text(Formatters.currency(_product.discountPrice!), style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                      ] else
                        Text(Formatters.currency(_product.price), style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  // ── العروض الفعّالة ──
                  if (!_loadingOffers && _offers.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text('العروض الفعّالة',
                        style: GoogleFonts.cairo(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ..._offers.map((o) => _OfferTile(offer: o)),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('الوصف', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    _product.description ?? 'لا يوجد وصف لهذا المنتج',
                    style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600], height: 1.6),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'أضف إلى السلة',
                    icon: Icons.add_shopping_cart,
                    onPressed: _product.isAvailable ? () => _cartController.addToCart(_product) : null,
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

class _OfferTile extends StatelessWidget {
  final Map<String, dynamic> offer;
  const _OfferTile({required this.offer});

  @override
  Widget build(BuildContext context) {
    final name = (offer['name'] ?? offer['title'] ?? 'عرض').toString();
    final desc = (offer['description'] ?? '').toString();
    final code = (offer['promoCode'] ?? '').toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.warningLight.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_outlined,
              color: AppColors.warningLight, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.cairo(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                if (desc.isNotEmpty)
                  Text(desc,
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: AppColors.textSecondary)),
                if (code.isNotEmpty)
                  Text('كود: $code',
                      style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
