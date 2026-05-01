import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// صفحة سياسة الخصوصية
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'سياسة الخصوصية',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(theme, 'مقدمة'),
              _sectionBody(theme,
                  'نحن نقدر خصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح هذه السياسة كيفية جمع واستخدام وحماية معلوماتك عند استخدام تطبيق التوصيل.'),
              const SizedBox(height: 20),
              _sectionTitle(theme, 'البيانات التي نجمعها'),
              _bulletPoint(theme, 'الاسم الكامل وبيانات التواصل (البريد الإلكتروني، رقم الهاتف)'),
              _bulletPoint(theme, 'عنوان التوصيل'),
              _bulletPoint(theme, 'سجل الطلبات والفواتير'),
              _bulletPoint(theme, 'بيانات الموقع الجغرافي (للسائقين فقط أثناء التوصيل)'),
              const SizedBox(height: 20),
              _sectionTitle(theme, 'كيف نستخدم بياناتك'),
              _bulletPoint(theme, 'معالجة الطلبات وتوصيلها'),
              _bulletPoint(theme, 'إرسال إشعارات حول حالة الطلب'),
              _bulletPoint(theme, 'تحسين خدماتنا وتجربة المستخدم'),
              _bulletPoint(theme, 'التواصل معك بخصوص حسابك'),
              const SizedBox(height: 20),
              _sectionTitle(theme, 'حماية البيانات'),
              _sectionBody(theme,
                  'نستخدم تقنيات تشفير متقدمة لحماية بياناتك. يتم تخزين كلمات المرور بشكل مشفر ولا يمكن لأي شخص الوصول إليها. نلتزم بأعلى معايير الأمان لحماية خصوصيتك.'),
              const SizedBox(height: 20),
              _sectionTitle(theme, 'حقوقك'),
              _bulletPoint(theme, 'يمكنك طلب حذف حسابك وبياناتك في أي وقت'),
              _bulletPoint(theme, 'يمكنك تعديل بياناتك الشخصية من الإعدادات'),
              _bulletPoint(theme, 'يمكنك إلغاء الاشتراك في الإشعارات'),
              const SizedBox(height: 20),
              _sectionTitle(theme, 'التواصل'),
              _sectionBody(theme,
                  'إذا كان لديك أي استفسار حول سياسة الخصوصية، يرجى التواصل معنا عبر صفحة الدعم الفني في التطبيق.'),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'آخر تحديث: 2025',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _sectionBody(ThemeData theme, String text) {
    return Text(
      text,
      style: GoogleFonts.cairo(
        fontSize: 14,
        height: 1.8,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _bulletPoint(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 14,
                height: 1.7,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
