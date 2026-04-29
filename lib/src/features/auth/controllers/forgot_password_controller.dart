import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/features/auth/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final sent = false.obs;
  final error = ''.obs;
  final isLoading = false.obs;

  final _authService = Get.find<AuthService>();

  Future<void> sendReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;
    
    isLoading.value = true;
    error.value = '';

    try {
      final msg = await _authService.resetPassword(email);
      if (msg == null) {
        sent.value = true;
      } else {
        error.value = msg;
      }
    } catch (e) {
      error.value = 'Failed to send reset email. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}

