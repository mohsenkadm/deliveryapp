import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'سياسة الخصوصية',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _heroCard().animate().fadeIn(duration: 450.ms).slideY(begin: -0.06),
            const SizedBox(height: 14),
            ..._policySections.asMap().entries.map((entry) {
              final index = entry.key;
              final section = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SectionCard(
                  icon: section.icon,
                  color: section.color,
                  title: section.title,
                  content: section.content,
                  bullets: section.bullets,
                ).animate().fadeIn(delay: (120 + index * 70).ms),
              );
            }),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'آخر تحديث: مايو 2026',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF2E7DFF)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'خصوصيتك أولوية لدينا. نستخدم بياناتك فقط لتحسين الخدمة وتقديم تجربة آمنة.',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 13.5,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _policySections = <_PolicySection>[
    _PolicySection(
      icon: Icons.storage_rounded,
      color: Color(0xFF2E7DFF),
      title: 'البيانات التي نجمعها',
      bullets: [
        'الاسم الكامل وبيانات التواصل (البريد الإلكتروني، رقم الهاتف)',
        'عنوان التوصيل',
        'سجل الطلبات والفواتير',
        'بيانات الموقع الجغرافي للسائقين أثناء التوصيل فقط',
      ],
    ),
    _PolicySection(
      icon: Icons.settings_suggest_rounded,
      color: Color(0xFF10B981),
      title: 'كيف نستخدم البيانات',
      bullets: [
        'معالجة الطلبات وتوصيلها بدقة',
        'إرسال إشعارات حول حالة الطلب',
        'تحسين الأداء وتجربة الاستخدام',
        'التواصل معك بخصوص حسابك وخدماتنا',
      ],
    ),
    _PolicySection(
      icon: Icons.security_rounded,
      color: Color(0xFF8B5CF6),
      title: 'حماية البيانات',
      content:
          'نستخدم تشفيراً حديثاً لحماية البيانات الحساسة، وتخزن كلمات المرور بشكل مشفر وفق أفضل ممارسات الأمان.',
    ),
    _PolicySection(
      icon: Icons.rule_rounded,
      color: Color(0xFFFF7A00),
      title: 'حقوقك',
      bullets: [
        'طلب حذف الحساب والبيانات في أي وقت',
        'تعديل البيانات الشخصية من صفحة الملف الشخصي',
        'إدارة الإشعارات حسب رغبتك',
      ],
    ),
    _PolicySection(
      icon: Icons.support_agent_rounded,
      color: Color(0xFFEF4444),
      title: 'التواصل',
      content:
          'لأي استفسار بخصوص سياسة الخصوصية يمكنك التواصل عبر صفحة الدعم الفني داخل التطبيق.',
    ),
  ];
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? content;
  final List<String> bullets;

  const _SectionCard({
    required this.icon,
    required this.color,
    required this.title,
    this.content,
    this.bullets = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 9),
            Text(
              content!,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.7,
              ),
            ),
          ],
          if (bullets.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...bullets.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PolicySection {
  final IconData icon;
  final Color color;
  final String title;
  final String? content;
  final List<String> bullets;

  const _PolicySection({
    required this.icon,
    required this.color,
    required this.title,
    this.content,
    this.bullets = const [],
  });
}
