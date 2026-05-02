// صفحة إشعارات المندوب
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';

class RepresentativeNotificationsPage extends StatelessWidget {
  const RepresentativeNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.find<NotificationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          Obx(() {
            final hasUnread =
                service.notifications.any((n) => n['isRead'] != true);
            if (!hasUnread) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: () async {
                for (final n in service.notifications
                    .where((n) => n['isRead'] != true)
                    .toList()) {
                  await service.markAsRead(n['id'].toString());
                }
              },
              icon: const Icon(Icons.done_all, size: 16),
              label: Text('قراءة الكل', style: GoogleFonts.cairo(fontSize: 13)),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (service.notifications.isEmpty) {
          return const EmptyState(
            title: 'لا توجد إشعارات',
            subtitle: 'ستظهر إشعاراتك هنا',
            icon: Icons.notifications_off_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: service.fetchNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: service.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final n = service.notifications[i];
              final isRead = n['isRead'] == true;
              final createdAt =
                  DateTime.tryParse(n['createdAt']?.toString() ?? '') ??
                      DateTime.now();
              return GestureDetector(
                onTap: () => service.markAsRead(n['id'].toString()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isRead
                        ? Theme.of(context).cardTheme.color
                        : AppColors.primaryLight.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isRead
                          ? AppColors.dividerLight
                          : AppColors.primaryLight.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color:
                              AppColors.primaryLight.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.notifications_outlined,
                            color: AppColors.primaryLight, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n['title']?.toString() ?? '',
                              style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              n['body']?.toString() ??
                                  n['message']?.toString() ??
                                  '',
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4),
                            ),
                            const SizedBox(height: 6),
                            Text(Formatters.timeAgo(createdAt),
                                style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4, right: 4),
                          decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
