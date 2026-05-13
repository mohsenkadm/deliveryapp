// ربط متحكمات السائق
import 'package:get/get.dart';
import '../controllers/driver_controllers.dart';

class DriverBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DriverHomeController>()) {
      Get.lazyPut(() => DriverHomeController());
    }
  }
}
