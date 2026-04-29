import 'package:get/get.dart';
import 'package:pcosense/src/features/assessment/controllers/assessment_controller.dart';
import 'package:pcosense/src/features/auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  final auth = Get.find<AuthController>();
  final assessments = Get.find<AssessmentController>();
}
