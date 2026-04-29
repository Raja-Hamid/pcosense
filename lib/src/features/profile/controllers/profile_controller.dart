import 'package:get/get.dart';
import 'package:pcosense/src/features/assessment/controllers/assessment_controller.dart';
import 'package:pcosense/src/features/auth/controllers/auth_controller.dart';
import 'package:pcosense/src/features/tracker/controllers/tracker_controller.dart';

class ProfileController extends GetxController {
  final auth = Get.find<AuthController>();
  final assessments = Get.find<AssessmentController>();
  final tracker = Get.find<TrackerController>();
}
