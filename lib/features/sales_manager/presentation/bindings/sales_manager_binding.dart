import 'package:get/get.dart';
import '../controllers/sales_manager_controller.dart';

class SalesManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SalesManagerController>(() => SalesManagerController());
  }
}
