import 'package:get/get.dart';
import 'package:pcosense/src/features/assessment/controllers/assessment_controller.dart';
import 'package:pcosense/src/features/questionnaire/controllers/questionnaire_controller.dart';

class QuestionnaireBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AssessmentController>()) {
      Get.put(AssessmentController(), permanent: true);
    }
    Get.lazyPut(() => QuestionnaireController());
  }
}
