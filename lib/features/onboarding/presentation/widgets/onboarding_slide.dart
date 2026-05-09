import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final String lottieAsset;
  final IconData icon;
  final List<IconData> highlightIcons;
  final List<String> highlightLabels;
  final Color color;
  final Color gradientStart;
  final Color gradientEnd;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.icon,
    required this.highlightIcons,
    required this.highlightLabels,
    required this.color,
    required this.gradientStart,
    required this.gradientEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIllustration(),
          const SizedBox(height: 48),
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
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: List.generate(highlightIcons.length, (index) {
              final label =
                  index < highlightLabels.length ? highlightLabels[index] : '';
              return _FeatureChip(
                color: color,
                icon: highlightIcons[index],
                label: label,
              ).animate().fadeIn(delay: (460 + (index * 90)).ms);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing ring
          Container(
            width: 262,
            height: 262,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.14), width: 1.5),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 2800.ms,
                curve: Curves.easeInOut,
              ),

          // Middle soft ring
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.07),
              border: Border.all(color: color.withValues(alpha: 0.18), width: 1),
            ),
          ),

          // Main gradient circle with icon
          Container(
            width: 158,
            height: 158,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [gradientStart, gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.38),
                  blurRadius: 34,
                  offset: const Offset(0, 14),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Icon(icon, size: 80, color: Colors.white),
          ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.55, 0.55)),

          // Chip — top right
          Positioned(
            top: 28,
            right: 26,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.18),
              ),
              child: Icon(icon, size: 20, color: color),
            ).animate(delay: 350.ms).fadeIn().scale(begin: const Offset(0.0, 0.0)),
          ),

          // Orbit icon - top left
          Positioned(
            top: 26,
            left: 22,
            child: _buildOrbitIcon(
              highlightIcons.isNotEmpty ? highlightIcons.first : icon,
            ),
          ),

          // Orbit icon - right center
          Positioned(
            top: 116,
            right: 10,
            child: _buildOrbitIcon(highlightIcons.length > 1 ? highlightIcons[1] : icon),
          ),

          // Orbit icon - bottom center
          Positioned(
            bottom: 18,
            left: 110,
            child: _buildOrbitIcon(highlightIcons.length > 2 ? highlightIcons[2] : icon),
          ),

          // Floating dot — bottom left (animated)
          Positioned(
            bottom: 38,
            left: 22,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.25),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                  begin: 0, end: -7, duration: 2200.ms, curve: Curves.easeInOut),
          ),

          // Tiny dot — top left
          Positioned(
            top: 54,
            left: 32,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.3),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                  begin: 0, end: 9, duration: 1900.ms, curve: Curves.easeInOut),
          ),

          // Small dot — bottom right
          Positioned(
            bottom: 28,
            right: 38,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.2),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                  begin: 0, end: -10, duration: 2600.ms, curve: Curves.easeInOut),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildOrbitIcon(IconData orbitIcon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(orbitIcon, size: 18, color: color),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).moveY(
          begin: 0,
          end: -6,
          duration: 1800.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _FeatureChip extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
