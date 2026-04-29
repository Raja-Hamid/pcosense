import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/auth/controllers/forgot_password_controller.dart';
import 'package:pcosense/src/features/auth/widgets/auth_input.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Reset Password',
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Enter your email address and we will send you instructions to reset your password.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              AuthInput(
                controller: controller.emailController,
                label: 'Email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 32.h),
              PrimaryButton(
                text: controller.sent.value ? 'Reset Link Sent' : 'Send Reset Link',
                onTap: controller.sendReset,
                enabled: !controller.sent.value,
              ),
              if (controller.sent.value) ...[
                SizedBox(height: 24.h),
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Back to Login',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
