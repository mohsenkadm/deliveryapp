import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/customer_entities.dart';
import '../../../../core/utils/formatters.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final void Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemTile({super.key, required this.cartItem, required this.onQuantityChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 70, height: 70,
              child: cartItem.product.imageUrl != null
                  ? CachedNetworkImage(imageUrl: cartItem.product.imageUrl!, fit: BoxFit.cover)
                  : Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cartItem.product.name, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(Formatters.currency(cartItem.product.discountPrice ?? cartItem.product.price), style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QuantityButton(icon: Icons.remove, onTap: () => onQuantityChanged(cartItem.quantity - 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${cartItem.quantity}', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    _QuantityButton(icon: Icons.add, onTap: () => onQuantityChanged(cartItem.quantity + 1)),
                    const Spacer(),
                    Text(Formatters.currency(cartItem.total), style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
