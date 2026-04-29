import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';

class OnboardingController extends GetxController {
  final index = 0.obs;

  void next() {
    if (index.value < 2) {
      index.value += 1;
    } else {
      Get.toNamed(AppRoutes.signup);
    }
  }
}
