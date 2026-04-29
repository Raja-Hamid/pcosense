import 'package:get/get.dart';
import 'package:pcosense/src/features/auth/controllers/auth_controller.dart';
import 'package:pcosense/src/features/auth/controllers/signup_controller.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    Get.lazyPut(() => SignupController());
  }
}
