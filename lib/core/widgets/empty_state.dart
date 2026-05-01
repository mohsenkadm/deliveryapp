import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final String? lottieAsset;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottieAsset != null)
              SizedBox(
                width: 180,
                height: 180,
                child: Lottie.asset(
                  lottieAsset!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    icon,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms)
            else
              Icon(
                icon,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
            ],
          ],
        ),
      ),
    );
  }
}
