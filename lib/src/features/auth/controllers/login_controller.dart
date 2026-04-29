import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/features/auth/controllers/auth_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final showPass = false.obs;
  final loading = false.obs;
  final error = ''.obs;
  final auth = Get.find<AuthController>();

  Future<void> submit() async {
    loading.value = true;
    final msg = await auth.login(emailController.text.trim(), passwordController.text.trim());
    loading.value = false;
    error.value = msg ?? '';
    if (msg == null) Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
