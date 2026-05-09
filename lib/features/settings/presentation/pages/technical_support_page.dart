import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

class TechnicalSupportPage extends StatelessWidget {
  const TechnicalSupportPage({super.key});

  static const String _whatsappNumber = '9647700000000';
  static const String _emailAddress = 'support@deliveryapp.com';
  static const String _phoneNumber = '+9647700000000';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'الدعم الفني',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _buildHeroCard()
                .animate()
                .fadeIn(duration: 420.ms)
                .slideY(begin: -0.05),
            const SizedBox(height: 14),
            _SupportCard(
              icon: Icons.chat_rounded,
              iconColor: const Color(0xFF25D366),
              title: 'واتساب',
              subtitle: 'تواصل فوري مع فريق الدعم',
              action: 'بدء المحادثة',
              onTap: _openWhatsApp,
            ).animate().fadeIn(delay: 80.ms),
            const SizedBox(height: 10),
            _SupportCard(
              icon: Icons.email_rounded,
              iconColor: const Color(0xFF2E7DFF),
              title: 'البريد الإلكتروني',
              subtitle: _emailAddress,
              action: 'إرسال بريد',
              onTap: _openEmail,
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 10),
            _SupportCard(
              icon: Icons.phone_rounded,
              iconColor: const Color(0xFF1565C0),
              title: 'الاتصال الهاتفي',
              subtitle: _phoneNumber,
              action: 'اتصال مباشر',
              onTap: _openPhone,
            ).animate().fadeIn(delay: 220.ms),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ساعات العمل: يومياً من 9:00 صباحاً حتى 9:00 مساءً',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: const Color(0xFF0F8F66),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 290.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نحن هنا لمساعدتك',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'اختر طريقة التواصل المناسبة وسنخدمك بأسرع وقت.',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/$_whatsappNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEmail() async {
    final uri = Uri(scheme: 'mailto', path: _emailAddress, queryParameters: {
      'subject': 'طلب دعم فني - تطبيق التوصيل',
    });
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openPhone() async {
    final uri = Uri(scheme: 'tel', path: _phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String action;
  final Future<void> Function() onTap;

  const _SupportCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: iconColor.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                action,
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  color: iconColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
