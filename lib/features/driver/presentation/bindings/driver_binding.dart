// ربط متحكمات السائق
import 'package:get/get.dart';
import '../controllers/driver_controllers.dart';

class DriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DriverHomeController());
  }
}
