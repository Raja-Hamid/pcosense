import 'package:get/get.dart';
import 'package:pcosense/src/features/content/controllers/recommendation_controller.dart';

class ContentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RecommendationController());
  }
}
