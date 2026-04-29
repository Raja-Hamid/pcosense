import 'package:get/get.dart';
import 'package:pcosense/src/features/auth/controllers/auth_controller.dart';
import 'package:pcosense/src/features/auth/controllers/welcome_controller.dart';

class WelcomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    Get.lazyPut(() => WelcomeController());
  }
}
