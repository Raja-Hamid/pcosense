import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/features/auth/controllers/auth_controller.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final showPass = false.obs;
  final agree = false.obs;
  final error = ''.obs;
  final isLoading = false.obs;
  final auth = Get.find<AuthController>();

  Future<void> submit() async {
    error.value = '';
    if (passwordController.text != confirmController.text) {
      error.value = "Passwords don't match";
      return;
    }
    if (!agree.value) {
      error.value = 'Please agree to terms';
      return;
    }
    isLoading.value = true;
    try {
      final msg = await auth.signup(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      error.value = msg ?? '';
      if (msg == null) Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      error.value = 'Unable to create account right now. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}
