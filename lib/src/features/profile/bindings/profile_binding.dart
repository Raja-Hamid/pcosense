import 'package:get/get.dart';
import 'package:pcosense/src/features/assessment/controllers/assessment_controller.dart';
import 'package:pcosense/src/features/auth/controllers/auth_controller.dart';
import 'package:pcosense/src/features/profile/controllers/profile_controller.dart';
import 'package:pcosense/src/features/tracker/controllers/tracker_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) Get.put(AuthController(), permanent: true);
    if (!Get.isRegistered<AssessmentController>()) Get.put(AssessmentController(), permanent: true);
    if (!Get.isRegistered<TrackerController>()) Get.put(TrackerController(), permanent: true);
    Get.lazyPut(() => ProfileController());
  }
}
