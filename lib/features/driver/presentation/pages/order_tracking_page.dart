import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/driver_entities.dart';
import '../controllers/driver_controllers.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments['order'] as DeliveryOrder;
    final controller = Get.find<DriverHomeController>();

    return Scaffold(
      appBar: AppBar(title: Text('تتبع الطلب #${order.orderNumber}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('حالة الطلب', style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Helpers.getStatusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(Helpers.getStatusText(order.status), style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: Helpers.getStatusColor(order.status))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('معلومات العميل'),
            _infoTile(Icons.person, 'الاسم', order.customerName, context),
            _infoTile(Icons.phone, 'الهاتف', order.customerPhone, context),
            _infoTile(Icons.location_on, 'العنوان', order.customerAddress, context),
            const SizedBox(height: 20),
            _sectionTitle('تفاصيل الطلب'),
            _infoTile(Icons.receipt, 'رقم الطلب', order.orderNumber, context),
            _infoTile(Icons.attach_money, 'المبلغ', Formatters.currency(order.totalAmount), context),
            _infoTile(Icons.calendar_today, 'التاريخ', Formatters.dateTime(order.createdAt), context),
            if (order.notes != null) _infoTile(Icons.note, 'ملاحظات', order.notes!, context),
            const SizedBox(height: 32),
            if (order.status == 'Approved')
              CustomButton(
                text: 'بدء التوصيل',
                icon: Icons.local_shipping,
                backgroundColor: const Color(0xFF2563EB),
                onPressed: () => controller.updateStatus(order.id, 'Shipped'),
              ),
            if (order.status == 'Shipped')
              CustomButton(
                text: 'تأكيد التوصيل',
                icon: Icons.check_circle,
                backgroundColor: const Color(0xFF059669),
                onPressed: () => controller.updateStatus(order.id, 'Delivered'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
              Text(value, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
