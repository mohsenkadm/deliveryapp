// ربط متحكمات المدير
import 'package:get/get.dart';
import '../controllers/admin_controllers.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminDashboardController());
    Get.lazyPut(() => AdminCustomersController());
    Get.lazyPut(() => AdminProductsController());
    Get.lazyPut(() => AdminOrdersController());
    Get.lazyPut(() => AdminDebtsController());
    Get.lazyPut(() => AdminInventoryController());
  }
}
