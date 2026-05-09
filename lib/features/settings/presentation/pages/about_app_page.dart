import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('حول التطبيق',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── App Header ──
            _buildAppHeader()
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.85, 0.85)),
            const SizedBox(height: 32),

            // ── Features ──
            _FeatureCard(
              icon: Icons.local_shipping_rounded,
              color: const Color(0xFF2E7DFF),
              title: 'توصيل سريع وموثوق',
              description: 'نوصّل طلباتك في أسرع وقت مع تتبع مباشر لكل مرحلة',
            ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.08),
            const SizedBox(height: 12),
            _FeatureCard(
              icon: Icons.security_rounded,
              color: const Color(0xFF10B981),
              title: 'آمن وموثوق تماماً',
              description: 'بياناتك محمية بتشفير عالي المستوى ومعايير أمان حديثة',
            ).animate().fadeIn(delay: 180.ms).slideX(begin: 0.08),
            const SizedBox(height: 12),
            _FeatureCard(
              icon: Icons.notifications_active_rounded,
              color: const Color(0xFFFF7A00),
              title: 'إشعارات فورية',
              description: 'ابقَ على اطلاع دائم بحالة طلباتك وآخر العروض',
            ).animate().fadeIn(delay: 260.ms).slideX(begin: 0.08),
            const SizedBox(height: 12),
            _FeatureCard(
              icon: Icons.headset_mic_rounded,
              color: const Color(0xFF8B5CF6),
              title: 'دعم على مدار الساعة',
              description: 'فريقنا متاح دائماً لمساعدتك في أي وقت تحتاج',
            ).animate().fadeIn(delay: 340.ms).slideX(begin: 0.08),
            const SizedBox(height: 32),

            // ── Info tiles ──
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'الإصدار', value: '1.0.0'),
                  Divider(height: 1, indent: 16, color: AppColors.dividerLight),
                  _InfoRow(label: 'تاريخ الإصدار', value: 'يناير 2025'),
                  Divider(height: 1, indent: 16, color: AppColors.dividerLight),
                  _InfoRow(label: 'جهة التطوير', value: 'DeliverySystem'),
                  Divider(height: 1, indent: 16, color: AppColors.dividerLight),
                  _InfoRow(label: 'المنصة', value: 'iOS & Android'),
                ],
              ),
            ).animate().fadeIn(delay: 420.ms),
            const SizedBox(height: 32),

            Center(
              child: Text(
                'جميع الحقوق محفوظة © 2025',
                style: GoogleFonts.cairo(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7DFF), Color(0xFF7BB8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7DFF).withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.local_shipping_rounded,
              size: 52, color: Colors.white),
        ),
        const SizedBox(height: 18),
        Text('تطبيق التوصيل',
            style: GoogleFonts.cairo(
                fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7DFF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('الإصدار 1.0.0',
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: const Color(0xFF2E7DFF),
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 25, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.cairo(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(description,
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 13.5, color: AppColors.textSecondary)),
          Text(value,
              style: GoogleFonts.cairo(
                  fontSize: 13.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
