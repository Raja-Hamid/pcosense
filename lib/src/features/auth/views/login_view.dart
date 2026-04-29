import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/auth/controllers/login_controller.dart';
import 'package:pcosense/src/features/auth/widgets/auth_input.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          Container(
            height: 240.h,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_rounded, color: Colors.white, size: 48.sp),
                  SizedBox(height: 16.h),
                  Text(
                    'Welcome Back',
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Sign in to continue your journey',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: Obx(
                () => ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    AuthInput(
                      controller: controller.emailController,
                      label: 'Email',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 20.h),
                    AuthInput(
                      controller: controller.passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: !controller.showPass.value,
                      textInputAction: TextInputAction.done,
                      suffix: IconButton(
                        onPressed: () => controller.showPass.value = !controller.showPass.value,
                        icon: Icon(
                          controller.showPass.value ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),
                    if (controller.error.value.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          controller.error.value,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                        ),
                      ),
                    SizedBox(height: 12.h),
                    PrimaryButton(
                      text: 'Sign In',
                      isLoading: controller.loading.value,
                      onTap: controller.submit,
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.signup),
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
