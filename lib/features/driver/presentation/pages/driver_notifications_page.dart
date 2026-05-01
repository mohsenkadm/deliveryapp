import 'package:flutter/material.dart';
import '../../../customer/presentation/pages/customer_notifications_page.dart';

class DriverNotificationsPage extends StatelessWidget {
  const DriverNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuses shared notification UI
    return const CustomerNotificationsPage();
  }
}
