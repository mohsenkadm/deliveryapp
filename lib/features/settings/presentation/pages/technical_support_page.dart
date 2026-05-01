import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// صفحة الدعم الفني — واتساب، بريد إلكتروني، هاتف
class TechnicalSupportPage extends StatelessWidget {
  const TechnicalSupportPage({super.key});

  // غيّر هذه القيم لبيانات التواصل الخاصة بك
  static const String _whatsappNumber = '9647700000000';
  static const String _emailAddress = 'support@deliveryapp.com';
  static const String _phoneNumber = '+9647700000000';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'الدعم الفني',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Icon(
                Icons.support_agent_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'كيف يمكننا مساعدتك؟',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'تواصل معنا عبر أي من الطرق التالية وسنرد عليك في أقرب وقت',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 40),
              _SupportCard(
                icon: Icons.chat_rounded,
                iconColor: const Color(0xFF25D366),
                title: 'واتساب',
                subtitle: 'تحدث معنا مباشرة',
                onTap: () => _openWhatsApp(),
              ),
              const SizedBox(height: 16),
              _SupportCard(
                icon: Icons.email_rounded,
                iconColor: theme.colorScheme.primary,
                title: 'البريد الإلكتروني',
                subtitle: _emailAddress,
                onTap: () => _openEmail(),
              ),
              const SizedBox(height: 16),
              _SupportCard(
                icon: Icons.phone_rounded,
                iconColor: const Color(0xFF1565C0),
                title: 'الهاتف',
                subtitle: _phoneNumber,
                onTap: () => _openPhone(),
              ),
              const Spacer(),
              Text(
                'ساعات العمل: ٩ صباحاً - ٩ مساءً',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
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
  final VoidCallback onTap;

  const _SupportCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
