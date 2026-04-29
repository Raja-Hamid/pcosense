import 'package:get/get.dart';
import 'package:pcosense/src/features/tracker/controllers/tracker_controller.dart';

class TrackerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TrackerController>()) {
      Get.put(TrackerController(), permanent: true);
    }
  }
}
