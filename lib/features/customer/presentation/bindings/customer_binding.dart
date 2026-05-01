// ربط متحكمات العميل
import 'package:get/get.dart';
import '../controllers/customer_controllers.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CustomerHomeController());
    Get.lazyPut(() => CartController(), fenix: true);
    Get.lazyPut(() => ProductsController());
    Get.lazyPut(() => OrdersController());
    Get.lazyPut(() => DebtsController());
  }
}
