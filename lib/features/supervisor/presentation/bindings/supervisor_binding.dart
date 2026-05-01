import 'package:get/get.dart';
import '../controllers/supervisor_controller.dart';

class SupervisorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupervisorController>(() => SupervisorController());
  }
}
