import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';

class CustomerNotificationsPage extends StatelessWidget {
  const CustomerNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.find<NotificationService>();
    service.fetchNotifications();

    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: Obx(() {
        if (service.notifications.isEmpty) return const EmptyState(title: 'لا توجد إشعارات', icon: Icons.notifications_off_outlined);

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: service.notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final n = service.notifications[index];
            final isRead = n['isRead'] == true;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRead ? Theme.of(context).cardTheme.color : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: isRead ? null : Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: InkWell(
                onTap: () => service.markAsRead(n['id'].toString()),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n['title'] ?? '', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(n['body'] ?? n['message'] ?? '', style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(Formatters.timeAgo(DateTime.tryParse(n['createdAt'] ?? '') ?? DateTime.now()), style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    if (!isRead) Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
