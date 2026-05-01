import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/customer_entities.dart';
import '../../../../core/utils/formatters.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({super.key, required this.product, this.onTap, this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: product.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                        errorWidget: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 40, color: Colors.grey)),
                      )
                    : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 40, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (product.categoryName != null)
                    Text(product.categoryName!, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey), maxLines: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.discountPrice != null) ...[
                              Text(Formatters.currency(product.price), style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                              Text(Formatters.currency(product.discountPrice!), style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                            ] else
                              Text(Formatters.currency(product.price), style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                          ],
                        ),
                      ),
                      if (onAddToCart != null)
                        GestureDetector(
                          onTap: product.isAvailable ? onAddToCart : null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: product.isAvailable ? Theme.of(context).colorScheme.primary : Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
