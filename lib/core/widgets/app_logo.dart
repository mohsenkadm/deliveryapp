import 'package:flutter/material.dart';
import '../constants/asset_paths.dart';

/// شعار التطبيق الافتراضي من الأصول المحلية.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 72,
    this.borderRadius = 20,
    this.backgroundColor,
    this.padding = 8,
  });

  final double size;
  final double borderRadius;
  final Color? backgroundColor;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Image.asset(
        AssetPaths.logo,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.storefront_rounded,
          size: size * 0.45,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
