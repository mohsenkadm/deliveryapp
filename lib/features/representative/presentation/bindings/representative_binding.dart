// ربط متحكمات المندوب
import 'package:get/get.dart';
import '../controllers/representative_controllers.dart';

class RepresentativeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RepresentativeHomeController());
  }
}
