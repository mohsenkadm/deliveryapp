import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/customer_controllers.dart';

class CustomerNotificationsPage extends GetView<CustomerNotificationsController> {
  const CustomerNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          Obx(() {
            final hasUnread = controller.unreadCount > 0;
            if (!hasUnread) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: controller.markAllRead,
              icon: const Icon(Icons.done_all, size: 16),
              label: Text('قراءة الكل', style: GoogleFonts.cairo(fontSize: 13)),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingIndicator();
        if (controller.notifications.isEmpty) {
          return const EmptyState(
            title: 'لا توجد إشعارات',
            subtitle: 'ستظهر إشعاراتك هنا',
            icon: Icons.notifications_off_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final n = controller.notifications[index];
              final isRead = n.isRead;
              return GestureDetector(
                onTap: () => controller.markRead(n.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isRead
                        ? Theme.of(context).cardTheme.color
                        : AppColors.primary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isRead
                          ? AppColors.dividerLight
                          : AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // أيقونة الإشعار
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isRead
                              ? AppColors.primary.withValues(alpha: 0.07)
                              : AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // المحتوى
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              n.body,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              Formatters.timeAgo(n.createdAt),
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // نقطة غير مقروء
                      if (!isRead)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, right: 4),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
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
