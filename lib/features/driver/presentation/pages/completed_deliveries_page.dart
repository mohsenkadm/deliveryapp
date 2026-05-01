import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/driver_controllers.dart';
import '../widgets/delivery_card.dart';

class CompletedDeliveriesPage extends GetView<DriverHomeController> {
  const CompletedDeliveriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadCompletedDeliveries();

    return Scaffold(
      appBar: AppBar(title: const Text('التوصيلات المكتملة')),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingIndicator();
        if (controller.completedOrders.isEmpty) return const EmptyState(title: 'لا توجد توصيلات مكتملة', icon: Icons.check_circle_outline);

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.completedOrders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) => DeliveryCard(order: controller.completedOrders[index]),
        );
      }),
    );
  }
}
