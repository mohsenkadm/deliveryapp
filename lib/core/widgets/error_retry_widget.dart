// ويدجت خطأ مع زر إعادة المحاولة
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorRetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  const ErrorRetryWidget({
    super.key,
    this.message = 'حدث خطأ أثناء تحميل البيانات',
    required this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colorScheme.error.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: colorScheme.onSurface.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }
}
