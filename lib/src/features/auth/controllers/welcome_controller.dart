import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/features/auth/controllers/auth_controller.dart';

class WelcomeController extends GetxController {
  final auth = Get.find<AuthController>();

  @override
  void onReady() {
    super.onReady();
    
    ever(auth.user, (user) {
      if (user != null) {
        Get.offAllNamed(AppRoutes.home);
      }
    });

    if (auth.user.value != null) {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}
