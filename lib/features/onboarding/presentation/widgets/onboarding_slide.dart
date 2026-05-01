import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final String lottieAsset;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.description,
    required this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 260,
            height: 260,
            child: Lottie.asset(
              lottieAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1, 1),
              ),
          const SizedBox(height: 40),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
        ],
      ),
    );
  }
}
