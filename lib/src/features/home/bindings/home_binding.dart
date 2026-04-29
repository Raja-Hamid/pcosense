import 'package:get/get.dart';
import 'package:pcosense/src/features/assessment/controllers/assessment_controller.dart';
import 'package:pcosense/src/features/auth/controllers/auth_controller.dart';
import 'package:pcosense/src/features/content/controllers/prediction_controller.dart';
import 'package:pcosense/src/features/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<AssessmentController>()) {
      Get.put(AssessmentController(), permanent: true);
    }
    if (!Get.isRegistered<PredictionController>()) {
      Get.put(PredictionController(), permanent: true);
    }
    Get.lazyPut(() => HomeController());
  }
}
