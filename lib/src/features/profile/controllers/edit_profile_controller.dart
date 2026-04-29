import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/features/auth/controllers/auth_controller.dart';

class EditProfileController extends GetxController {
  final auth = Get.find<AuthController>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    nameController.text = auth.user.value?.name ?? '';
    phoneController.text = auth.user.value?.phone ?? '';
  }

  Future<void> save() async {
    await auth.updateUser(name: nameController.text.trim(), phone: phoneController.text.trim());
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
